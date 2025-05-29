#!/bin/sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_FILES="$HOME/.zshrc $HOME/.bashrc $HOME/.tmux.conf"
SNIPPET_DIR="$REPO_DIR/append_snippets"

# Append new lines to each config file
for TARGET in $TARGET_FILES; do
  SNIPPET_FILE="$SNIPPET_DIR/$(basename "$TARGET")"
  [ -f "$SNIPPET_FILE" ] || continue

  echo "🔧 Updating $TARGET..."
  touch "$TARGET"

  while IFS= read -r LINE || [ -n "$LINE" ]; do
    grep -Fxq "$LINE" "$TARGET" || echo "$LINE" >> "$TARGET"
  done < "$SNIPPET_FILE"
done

# Source shell config
if [ -n "$ZSH_VERSION" ]; then
  echo "🔄 Sourcing .zshrc"
  . "$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  echo "🔄 Sourcing .bashrc"
  . "$HOME/.bashrc"
fi

# Reload tmux config
if command -v tmux >/dev/null 2>&1; then
  echo "🔄 Reloading tmux config"
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
fi

# Cleanup: delete cloned repo
cd ~
echo "🧹 Removing repo at $REPO_DIR"
rm -rf "$REPO_DIR"

echo "✅ All done."
# git clone --depth 1 https://github.com/kjtakke/tmux /tmp/kjtakke_tmux && bash /tmp/kjtakke_tmux/install.sh
