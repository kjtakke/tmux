#!/bin/bash

# alias tmux_atttach_session='tmux attach-session -t '
tmux_attach_session() {
  tmux attach-session -t "$1"
}


tmux_new_session() {
  if [[ -z "$1" ]]; then
    echo "❌ Please provide a session name."
    return 1
  fi

  local session_name="$1"

  # If inside tmux
  if [[ -n "$TMUX" ]]; then
    tmux new-session -d -s "$session_name"  # create detached session
    tmux switch-client -t "$session_name"   # switch to new session
  else
    tmux new-session -s "$session_name"     # create and attach
  fi
}
tmux_kill_session() {
  if [[ "$1" == "--all" ]]; then
    echo "⚠️  Killing all tmux sessions..."
    tmux list-sessions -F '#S' | while read -r session; do
      tmux kill-session -t "$session"
    done
    return
  fi

  if [[ -z "$1" && -n "$TMUX" ]]; then
    local current_session
    current_session=$(tmux display-message -p '#S')
    echo "🛑 Killing current tmux session: $current_session"
    tmux kill-session -t "$current_session"
    return
  fi

  if [[ -n "$1" ]]; then
    echo "🛑 Killing tmux session: $1"
    tmux kill-session -t "$1"
    return
  fi

  echo "❌ No session name provided and not inside a tmux session."
  return 1
}


ta() {
  # Check if tmux is installed
  if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Please install tmux first."
    return 1
  fi

  # If tmux sessions exist, attach to the first one
  local first_session
  first_session=$(tmux list-sessions -F "#S" 2>/dev/null | head -n 1)

  if [[ -n "$first_session" ]]; then
    echo "Attaching to tmux session: $first_session"
    tmux attach -t "$first_session"
  else
    echo "No tmux sessions found. Creating a new session 'term' in ~"
    tmux new-session -s term -c ~
  fi
}


alias tmux-n="tmux_new_session"
alias tmux-a="tmux_attach_session"
alias tmux-k="tmux_kill_session"

alias n="tmux_new_session"
alias a="tmux_attach_session"
alias k="tmux_kill_session"

