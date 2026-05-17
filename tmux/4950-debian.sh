#!/bin/bash

# tmux initialization script for session 'normal'
SESSION_NAME="normal"

# Check if session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? == 0 ]; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t $SESSION_NAME
    exit 0
fi

# Create new session with first window named 'main'
tmux new-session -d -s $SESSION_NAME -n main -x "$(tput cols)" -y "$(tput lines)"

# Attach to the session
tmux attach-session -t $SESSION_NAME

# Window 1: main - Create the layout
# Split horizontally first (left | right)
tmux split-window -h -t $SESSION_NAME:main

# Split left pane vertically (top and bottom)
tmux select-pane -t $SESSION_NAME:main.1
tmux split-window -v -t $SESSION_NAME:main.1

# Split right pane vertically (top and bottom)
tmux select-pane -t $SESSION_NAME:main.3
tmux split-window -v -t $SESSION_NAME:main.3

# Adjust pane sizes to match your specifications
tmux select-window -t $SESSION_NAME:main
tmux select-pane -t $SESSION_NAME:main.1
tmux resize-pane -t $SESSION_NAME:main.1 -x 122
tmux resize-pane -t $SESSION_NAME:main.1 -y 35
tmux resize-pane -t $SESSION_NAME:main.3 -y 17

# Execute commands in each pane
# Pane 1: No command needed
# Pane 2: sudo iotop -oP
tmux send-keys -t $SESSION_NAME:main.2 'sudo iotop -oP' C-m

# Pane 3: zpool iostat watch command
tmux send-keys -t $SESSION_NAME:main.3 'pools="zroot Hikvision_C2000Pro_Stripe Intel_750_RAID-Z1" ; watch -t -n 0.1 "zpool iostat -L -yv ${pools} 1 1"' C-m

# Pane 4: sudo iotop -oPa
tmux send-keys -t $SESSION_NAME:main.4 'sudo iotop -oPa' C-m

# Window 2: btop
tmux new-window -t $SESSION_NAME -n btop
tmux send-keys -t $SESSION_NAME:btop 'btop' C-m

# Window 3: codec
tmux new-window -t $SESSION_NAME -n codec

# Window 4: fuzzing
tmux new-window -t $SESSION_NAME -n fuzzing

# Select the first window and first pane
tmux select-window -t $SESSION_NAME:main
tmux select-pane -t $SESSION_NAME:main.1
