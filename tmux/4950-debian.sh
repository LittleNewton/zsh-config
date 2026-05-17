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
zpool_pane=$(tmux split-window -h -p 36 -c "$HOME" -t "$shell_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$shell_pane" -x 122

left_iotop_pane=$(tmux split-window -v -p 36 -c "$HOME" -t "$shell_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$shell_pane" -y 34

right_iotop_pane=$(tmux split-window -v -p 70 -c "$HOME" -t "$zpool_pane" -P -F "#{pane_id}")
tmux resize-pane -t "$zpool_pane" -y 18

# Pane 2: sudo iotop -oP
tmux send-keys -t "$left_iotop_pane" 'sudo iotop -oP' C-m

# Pane 3: zpool iostat watch command
pools="zroot Hikvision_C2000Pro_Stripe Intel_750_RAID-Z1"
tmux send-keys -t "$zpool_pane" "watch -t -n 0.1 zpool iostat -L -yv $pools 1 1" C-m

# Pane 4: sudo iotop -oPa
tmux send-keys -t "$right_iotop_pane" 'sudo iotop -oPa' C-m

# Window 2: btop
tmux new-window -t "$SESSION_NAME" -n btop -c "$HOME"
tmux send-keys -t "$SESSION_NAME:btop" 'btop' C-m

# Window 3: codec
tmux new-window -t "$SESSION_NAME" -n codec -c "$HOME"

# Window 4: fuzzing
tmux new-window -t "$SESSION_NAME" -n fuzzing -c "$HOME"

# Select the first window and shell pane, matching the current 4950-debian session
tmux select-window -t "$SESSION_NAME:main"
tmux select-pane -t "$shell_pane"

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
