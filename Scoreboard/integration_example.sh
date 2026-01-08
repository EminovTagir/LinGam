#!/bin/bash
# Example integration script for task containers
# This shows how to integrate scoreboard submission into task validation

# Function to submit task completion to scoreboard
submit_to_scoreboard() {
    local username="$1"
    local task_name="$2"
    local flag="$3"
    
    # Try to submit to scoreboard API (non-blocking)
    curl -s -X POST "http://host.docker.internal:5000/api/complete_task" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"${username}\",\"task_name\":\"${task_name}\",\"flag\":\"${flag}\"}" \
        > /dev/null 2>&1 &
}

# Example usage in a task entrypoint:
# When a user successfully completes the task, call this function
# 
# For example, in DeleteFile task:
# if [ ! -f /root/dontdelete ]; then
#     echo "flag: f3334634006f810113f4d18526d3ea11"
#     # Try to auto-submit (requires username from environment or prompt)
#     if [ -n "$LINGAM_USERNAME" ]; then
#         submit_to_scoreboard "$LINGAM_USERNAME" "deletefile" "f3334634006f810113f4d18526d3ea11"
#     fi
# fi
