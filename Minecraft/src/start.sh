#!/bin/bash

# Load variables from .env - GPT Stuff
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

cd "$MINECRAFT_DIR/src" || exit

SESSION="Server"

tmux kill-session -t $SESSION 2>/dev/null
tmux new-session -d -s $SESSION
tmux split-window -v -t $SESSION
tmux send-keys -t $SESSION:0.0 "source .venv/bin/activate && uv run main.py" C-m

tmux send-keys -t $SESSION:0.1 "ngrok http --url=$NGROK_URL 5000" C-m
tmux attach-session -t $SESSION

