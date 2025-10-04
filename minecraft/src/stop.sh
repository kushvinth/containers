# #!/bin/bash
# # stop.sh - gracefully stop Minecraft PaperMC server running in tmux

# SESSION_NAME="MCSERVER"

# # Check if the tmux session exists
# if tmux has-session -t $SESSION_NAME 2>/dev/null; then
#     echo "Stopping Minecraft server..."
#     tmux send-keys -t $SESSION_NAME "stop" ENTER
# else
#     echo "No Minecraft server tmux session found."
# fi
