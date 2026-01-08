#!/bin/bash
# Script to submit task completion to scoreboard
# Usage: submit_completion.sh <username> <task_name> [flag]

USERNAME="$1"
TASK_NAME="$2"
FLAG="${3:-}"

if [ -z "$USERNAME" ] || [ -z "$TASK_NAME" ]; then
    echo "Usage: $0 <username> <task_name> [flag]"
    exit 1
fi

# Try to submit to scoreboard API
SCOREBOARD_HOST="${SCOREBOARD_HOST:-localhost:5000}"

curl -s -X POST "http://${SCOREBOARD_HOST}/api/complete_task" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"${USERNAME}\",\"task_name\":\"${TASK_NAME}\",\"flag\":\"${FLAG}\"}" \
    2>/dev/null

# Return success regardless of API response to not break task flow
exit 0
