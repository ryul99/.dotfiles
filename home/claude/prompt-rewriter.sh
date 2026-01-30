#!/bin/bash

INPUT_PROMPT="$(cat | jq '.prompt')"

if [[ -n "$REWRITER_LOCK" ]]; then
    exit 0
fi

JSON_SCHEMA='
{
    "type": "object",
    "properties": {
        "enhanced_prompt": { "type": "string" }
    }
}
'

INPUT_PROMPT="\
Rewrite the following prompt in English to make it more grammatically correct and clear, while preserving its original meaning.
<PROMPT>
$INPUT_PROMPT
</PROMPT>\
"

ENHANCED_PROMPT="$( \
    REWRITER_LOCK=1 claude \
    --model sonnet \
    --output-format json \
    --json-schema "$JSON_SCHEMA" \
    -p "$INPUT_PROMPT"
)"

ENHANCED_PROMPT="$(echo "$ENHANCED_PROMPT" | jq -r '.structured_output.enhanced_prompt')"

if [[ -z "$ENHANCED_PROMPT" ]]; then
    exit 0
fi

ENHANCED_PROMPT="\
Below is the enhanced version of the original prompt:
---
$ENHANCED_PROMPT\
"

echo "$ENHANCED_PROMPT"
exit 0
