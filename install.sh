#!/bin/sh

set -e

REPO_URL="https://github.com/kjtakke/tmux"
TEMP_DIR="$(mktemp -d)"
TARGET_FILES="$HOME/.zshrc $HOME/.bashrc $HOME/.tmux.conf"
SNIPPET_DIR="append_snippets"  # adjust if your repo stores lines elsewhere

# Clone the repo
git clone --depth 1 "$REPO_URL" "$TEMP_DIR"

# Loop over each target config file
for TARGET in $TARGET_FILES; do
  SNIPPET_FILE="$TEMP_DIR/$SNIPPET_DIR/$(basename "$TARGET")"
  [ -f "$SNIPPET_FILE" ] || continue

  echo "🔧 Updating $TARGET..."
  touch "$TARGET"

  # Append missing lines from snippet
  while IFS= read -r LINE || [ -n "$LINE" ]; do
    grep -Fxq "$LINE" "$TARGET" || echo "$LINE" >> "$TARGET"
  done < "$SNIPPET_FILE"
done

# Apply changes
if [ -n "$ZSH_VERSION" ]; then
  echo "🔄 Sourcing .zshrc"
  . "$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  echo "🔄 Sourcing .bashrc"
  . "$HOME/.bashrc"
fi

if command -v tmux >/dev/null 2>&1; then
  echo "🔄 Reloading tmux config"
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
fi

# Clean up
echo "🧹 Removing temporary directory"
rm -rf "$TEMP_DIR"

echo "✅ Installation or update complete."
