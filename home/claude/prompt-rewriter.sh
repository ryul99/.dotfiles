#!/bin/bash

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
$1
</PROMPT>\
"

echo "$PROMPT"

claude --output-format json --model sonnet --json-schema "$JSON_SCHEMA" -p "$PROMPT" | jq .structured_output
