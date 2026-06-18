#!/bin/bash

# ref: https://github.com/fatih/dotfiles/blob/main/claude/statusline-git.sh

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Extract context window information
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

# Calculate context percentage
if [ "$current_usage" != "null" ]; then
    current_tokens=$(echo "$current_usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    context_percent=$((current_tokens * 100 / context_size))
else
    context_percent=0
fi

# Build context progress bar
bar_width=15
filled=$((context_percent * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# Extract cost information
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ "$session_cost" != "empty" ] && session_cost=$(printf "%.4f" "$session_cost") || session_cost=""

# Get directory name (basename)
dir_name=$(basename "$current_dir")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# # Change to the current directory to get git info
# cd "$current_dir" 2>/dev/null || cd /

# # Get git branch
# if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#     branch=$(git branch --show-current 2>/dev/null || echo "detached")

#     # Get git status with file counts
#     status_output=$(git status --porcelain 2>/dev/null)

#     if [ -n "$status_output" ]; then
#         # Count files and get basic line stats
#         total_files=$(echo "$status_output" | wc -l | xargs)
#         line_stats=$(git diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')

#         added=$(echo $line_stats | cut -d' ' -f1)
#         removed=$(echo $line_stats | cut -d' ' -f2)

#         # Build status display
#         git_info=" ${YELLOW}($branch${NC} ${YELLOW}|${NC} ${GRAY}${total_files} files${NC}"

#         [ "$added" -gt 0 ] && git_info="${git_info} ${GREEN}+${added}${NC}"
#         [ "$removed" -gt 0 ] && git_info="${git_info} ${RED}-${removed}${NC}"

#         git_info="${git_info} ${YELLOW})${NC}"
#     else
#         git_info=" ${YELLOW}($branch)${NC}"
#     fi
# else
#     git_info=""
# fi

# Add session cost if available
cost_info=""
if [ -n "$session_cost" ] && [ "$session_cost" != "null" ] && [ "$session_cost" != "empty" ]; then
    cost_info=" ${GRAY}[\$$session_cost]${NC}"
fi

# Build context bar display
context_info="ctx: ${GRAY}${bar}${NC} ${context_percent}%"

# Extract 5-hour rate limit information (Claude.ai subscription rolling limit)
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Build 5-hour rate limit gauge (same style as context gauge)
five_hour_info=""
if [ -n "$five_hour_pct" ]; then
    five_hour_int=$(printf "%.0f" "$five_hour_pct")
    fh_filled=$((five_hour_int * bar_width / 100))
    fh_empty=$((bar_width - fh_filled))
    fh_bar=""
    for ((i=0; i<fh_filled; i++)); do fh_bar+="█"; done
    for ((i=0; i<fh_empty; i++)); do fh_bar+="░"; done
    five_hour_info=" ${GRAY}|${NC} 5h: ${GRAY}${fh_bar}${NC} ${five_hour_int}%"
fi

# Extract 7-day rate limit information (Claude.ai subscription weekly limit)
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Build 7-day rate limit gauge (same style as context gauge)
seven_day_info=""
if [ -n "$seven_day_pct" ]; then
    seven_day_int=$(printf "%.0f" "$seven_day_pct")
    sd_filled=$((seven_day_int * bar_width / 100))
    sd_empty=$((bar_width - sd_filled))
    sd_bar=""
    for ((i=0; i<sd_filled; i++)); do sd_bar+="█"; done
    for ((i=0; i<sd_empty; i++)); do sd_bar+="░"; done
    seven_day_info=" ${GRAY}|${NC} 7d: ${GRAY}${sd_bar}${NC} ${seven_day_int}%"
fi

# Output the status line
echo -e "${BLUE}${dir_name}${NC} ${GRAY}|${NC} ${CYAN}${model_name}${NC} ${GRAY}|${NC} ${context_info}${cost_info}${git_info:+ ${GRAY}|${NC}}${five_hour_info}${seven_day_info}"
