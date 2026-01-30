#!/bin/bash

INPUT_PROMPT="$(cat $1 | jq .prompt)"

JSON_SCHEMA='
{
    "type": "object",
    "properties": {
        "enhanced_prompt": { "type": "string" },
        "reason": { "type": "string" }
    }
}
'

PROMPT="\
Rewrite the following prompt in English to make it more grammatically correct and clear, while preserving its original meaning.
When you rewrite the prompt, provide one or two lines explaining the changes you made.
<PROMPT>
$INPUT_PROMPT
</PROMPT>\
"

claude --model sonnet --output-format json --json-schema "$JSON_SCHEMA" -p "$PROMPT" | jq .structured_output
