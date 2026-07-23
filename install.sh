#!/usr/bin/env bash
# Re-install the personal bashrc hook into /etc/bashrc.
#
# /etc/bashrc is the only system-wide spot that loads for EVERY user, including
# root (sudo -i / su -), via an absolute path. A major macOS upgrade can lay
# down a fresh default /etc/bashrc and drop this line, silently killing the
# prompt/functions in all shells. Re-run this after any macOS upgrade.
#
# Idempotent: safe to run any number of times. Needs sudo (edits /etc/bashrc).
set -euo pipefail

RC="/Users/celly/.git_prompt_and_bashrc/bashrc"
LINE="[ -r \"$RC\" ] && . \"$RC\""
TARGET="/etc/bashrc"

# 1. Remove any commented-out duplicate of the hook (BSD/macOS sed).
sudo sed -i '' "\\|^#\\[ -r \"$RC\"|d" "$TARGET"

# 2. Ensure exactly one active hook line is present.
if ! grep -qF "$LINE" "$TARGET"; then
  printf '%s\n' "$LINE" | sudo tee -a "$TARGET" >/dev/null
fi

echo "OK: /etc/bashrc hook installed. Active reference(s):"
grep -nF "$RC" "$TARGET"
