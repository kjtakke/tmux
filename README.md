`~/.bashrc` or `~/.zshrc`
```bash
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
```


`~/.tmux.conf`
```
set -g mouse on
setw -g mode-keys vi
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-selection
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -selection clipboard -in"

```
`tmux source-file ~/.tmux.conf`
