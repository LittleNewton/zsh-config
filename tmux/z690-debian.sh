#!/bin/bash

# tmux initialization script for session 'normal'
SESSION_NAME="normal"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Create new session with first window named 'main'
tmux new-session -d -s "$SESSION_NAME" -n main -c "$HOME" -x "$(tput cols)" -y "$(tput lines)"

# Window 1: main - shell/iotop on the left, zpool/iotop on the right
shell_pane=$(tmux display-message -p -t "$SESSION_NAME:main" "#{pane_id}")
zpool_pane=$(tmux split-window -h -p 28 -c "$HOME" -t "$shell_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$shell_pane" -x 136

left_iotop_pane=$(tmux split-window -v -p 36 -c "$HOME" -t "$shell_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$shell_pane" -y 36

right_iotop_pane=$(tmux split-window -v -p 88 -c "$HOME" -t "$zpool_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$zpool_pane" -y 6

# Pane 2: sudo iotop -oP
tmux send-keys -t "$left_iotop_pane" 'sudo iotop -oP' C-m

# Pane 3: zpool iostat watch command
tmux send-keys -t "$zpool_pane" 'watch -t -n 0.1 zpool iostat -L -yv zroot 1 1' C-m

# Pane 4: sudo iotop -oP
tmux send-keys -t "$right_iotop_pane" 'sudo iotop -oP' C-m

# Window 2: btop
tmux new-window -t "$SESSION_NAME" -n btop -c "$HOME"

# Window 3: nvitop
tmux new-window -t "$SESSION_NAME" -n nvitop -c "$HOME"
tmux send-keys -t "$SESSION_NAME:nvitop" "$HOME/.local/bin/nvitop" C-m

# Select the first window and shell pane, matching the current z690-debian session
tmux select-window -t "$SESSION_NAME:main"
tmux select-pane -t "$shell_pane"

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
