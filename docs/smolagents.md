ref: https://github.com/huggingface/smolagents

# Web Agent

```bash
uv tool install 'smolagents[toolkit,litellm]' --with=helium
webagent "Please go to google" --model-type "LiteLLMModel" --model-id "openrouter/openai/gpt-5.2"
```
