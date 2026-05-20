#!/bin/bash
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
BAR=$(printf "%0.s#" $(seq 1 $((USAGE/5))))
echo "$MODEL | $DIR"
echo "[$BAR] $USAGE%"

# #!/bin/bash
# input=$(cat)
# MODEL=$(echo "$input" | jq -r '.model.display_name')
# DIR=$(echo "$input" | jq -r '.workspace.current_dir')
# USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
# echo "[$MODEL] $DIR | $USAGE% context"
