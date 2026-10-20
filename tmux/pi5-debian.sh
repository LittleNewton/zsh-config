#!/bin/bash

# tmux initialization script for session 'normal'
SESSION_NAME="normal"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Window 1: main - shell
tmux new-session -d -s "$SESSION_NAME" -n main -c "$HOME" -x "$(tput cols)" -y "$(tput lines)"
shell_pane=$(tmux display-message -p -t "$SESSION_NAME:main" "#{pane_id}")

# Window 2: btop
tmux new-window -t "$SESSION_NAME" -n btop -c "$HOME"
tmux send-keys -t "$SESSION_NAME:btop" 'btop' C-m

# Select the main window and shell pane
tmux select-window -t "$SESSION_NAME:main"
tmux select-pane -t "$shell_pane"

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
