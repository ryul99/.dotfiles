#!/bin/bash
# acknowledge: https://github.com/crescent-stdio for prompt

if [[ -n "$REWRITER_LOCK" ]]; then
    exit 0
fi

INPUT_PROMPT="$(cat | jq '.prompt')"
TARGET_LANGUAGE="Korean"

JSON_SCHEMA='
{
    "type": "object",
    "properties": {
        "enhanced_prompt": {
            "type": "string",
            "description": "The improved prompt preserving original meaning"
        },
        "has_corrections": {
            "type": "boolean",
            "description": "Whether the original prompt had any issues to improve"
        },
        "corrections": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "original": { "type": "string" },
                    "suggestion": { "type": "string" },
                    "category": {
                        "type": "string",
                        "enum": ["grammar", "vocabulary", "style", "spelling", "word_order"]
                    },
                    "explanation": { "type": "string" }
                },
                "required": ["original", "suggestion", "category", "explanation"]
            },
            "description": "Gentle improvement suggestions, max 3 items"
        },
        "tip": {
            "type": "string",
            "description": "One concise learning tip"
        }
    },
    "required": ["enhanced_prompt", "has_corrections", "corrections", "tip"]
}
'

INPUT_PROMPT="\
You are a supportive, encouraging English coach for a $TARGET_LANGUAGE developer. Analyze the prompt below and return structured JSON.

Rules:
1. enhanced_prompt: Rewrite to be clear, natural, professional English. Preserve the original intent exactly. If the prompt is code-only or already perfect English, return it unchanged.
2. has_corrections: true if you made any meaningful improvements, false if the prompt was already correct or is pure code/commands.
3. corrections: List up to 3 gentle improvement suggestions. Each must have:
   - original: the phrase from the original prompt
   - suggestion: the improved phrase
   - category: one of grammar, vocabulary, style, spelling, word_order
   - explanation: brief explanation in $TARGET_LANGUAGE (1 sentence, max 20 words).
4. tip: One memorable tip in $TARGET_LANGUAGE (1 sentence, max 30 words) about the most useful pattern. If no corrections, share a useful English expression tip.

Focus on patterns $TARGET_LANGUAGE speakers commonly struggle with: articles (a/the), prepositions, singular/plural, tense consistency, word order.

<PROMPT>
$INPUT_PROMPT
</PROMPT>\
"

RESPONSE="$( \
    REWRITER_LOCK=1 claude \
    --no-session-persistence \
    --model sonnet \
    --output-format json \
    --json-schema "$JSON_SCHEMA" \
    -p "$INPUT_PROMPT"
)"

STRUCTURED_OUTPUT="$(echo "$RESPONSE" | jq -r '.structured_output')"

# echo 'This is lesson message for user. Assistant should dismiss it.'

if [[ -z "$STRUCTURED_OUTPUT" || "$STRUCTURED_OUTPUT" == "null" ]]; then
    OUTPUT_PROMPT="Failed to generate lesson."
    exit 0
fi

ENHANCED="$(echo "$STRUCTURED_OUTPUT" | jq -r '.enhanced_prompt')"
HAS_CORRECTIONS="$(echo "$STRUCTURED_OUTPUT" | jq -r '.has_corrections')"
TIP="$(echo "$STRUCTURED_OUTPUT" | jq -r '.tip')"

OUTPUT_PROMPT="$ENHANCED"

if [[ "$HAS_CORRECTIONS" == "true" ]]; then
    CORRECTIONS_DISPLAY="$(echo "$STRUCTURED_OUTPUT" | jq -r '
        .corrections[] |
        "- ✅ \(.category): \(.original) → \(.suggestion)\n  - \(.explanation)\n"
    ')"
    OUTPUT_PROMPT="$OUTPUT_PROMPT

$CORRECTIONS_DISPLAY"
fi

OUTPUT_PROMPT="
$OUTPUT_PROMPT

✨ $TIP"

# escape newlines
OUTPUT_PROMPT="${OUTPUT_PROMPT//$'\n'/\\n}"
# escape double quotes
OUTPUT_PROMPT="${OUTPUT_PROMPT//\"/\\\"}"
echo "{ \"suppressOutput\": false, \"systemMessage\": \"$OUTPUT_PROMPT\" }"
exit 0
