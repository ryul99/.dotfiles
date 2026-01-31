# Claude Code Hooks

## english-lecturer.sh

A Claude Code hook that automatically rewrites your prompts to be more grammatically correct and clear, while providing English grammar lessons.

### Setup

1. Copy or symlink the script to your Claude config directory:
   ```bash
   cp english-lecturer.sh ~/.claude/english-lecturer.sh
   chmod +x ~/.claude/english-lecturer.sh
   ```

2. Configure it as a Claude Code hook in your `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/english-lecturer.sh"
             }
           ]
         }
       ]
     }
   }
   ```

3. The hook will automatically run on every prompt you submit to Claude Code.

### Customization

You can modify the following variables in the script:

- `TARGET_LANGUAGE`: The language for grammar lessons (default: "Korean")
- `JSON_SCHEMA`: The structure of the response from Claude
- The model used (default: "sonnet")
