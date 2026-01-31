#!/bin/bash

INPUT_PROMPT="$(cat | jq '.prompt')"

if [[ -n "$REWRITER_LOCK" ]]; then
    exit 0
fi

TARGET_LANGUAGE="Korean"
JSON_SCHEMA='
{
    "type": "object",
    "properties": {
        "enhanced_prompt": { "type": "string" },
        "lesson": { "type": "string" }
    }
}
'

INPUT_PROMPT="\
Rewrite the following prompt in English to make it more grammatically correct and clear, while preserving its original meaning.
Please let me know if there are any mistakes, and provide a brief explanation in $TARGET_LANGUAGE to help me learn.

Result should have two fields:
- enhanced_prompt: containing the improved prompt
- lesson: containing the brief explanation in $TARGET_LANGUAGE.

<PROMPT>
$INPUT_PROMPT
</PROMPT>\
"

RESPONSE="$( \
    REWRITER_LOCK=1 claude \
    --model sonnet \
    --output-format json \
    --json-schema "$JSON_SCHEMA" \
    -p "$INPUT_PROMPT"
)"

STRUCTURED_OUTPUT="$(echo "$RESPONSE" | jq -r '.structured_output')"

if [[ -z "$STRUCTURED_OUTPUT" ]]; then
    OUTPUT_PROMPT="Failed to generate lesson."
else
    OUTPUT_PROMPT="\
$(echo "$STRUCTURED_OUTPUT" | jq -r .enhanced_prompt)
---
$(echo "$STRUCTURED_OUTPUT" | jq -r .lesson)
"
fi

OUTPUT_PROMPT="\
This is lesson message for user. You should dismiss it.
---
$OUTPUT_PROMPT
"

echo -e "$OUTPUT_PROMPT"
exit 0
