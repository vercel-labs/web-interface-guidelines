#!/bin/bash

# Web Interface Guidelines installer
# https://vercel.com/design/guidelines

set -e

REPO_URL="https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main"
COMMAND_FILE="command.md"
INSTALL_NAME="web-interface-guidelines.md"
INSTALLED=0

echo "Installing Web Interface Guidelines…"
echo ""

# Claude Code
if [ -d "$HOME/.claude" ]; then
  mkdir -p "$HOME/.claude/commands"
  curl -sL -o "$HOME/.claude/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  echo "✓ Claude Code"
  INSTALLED=$((INSTALLED + 1))
fi

# Cursor (1.6+)
if [ -d "$HOME/.cursor" ]; then
  mkdir -p "$HOME/.cursor/commands"
  curl -sL -o "$HOME/.cursor/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  echo "✓ Cursor"
  INSTALLED=$((INSTALLED + 1))
fi

# OpenCode
if command -v opencode &> /dev/null || [ -d "$HOME/.config/opencode" ]; then
  mkdir -p "$HOME/.config/opencode/command"
  curl -sL -o "$HOME/.config/opencode/command/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  echo "✓ OpenCode"
  INSTALLED=$((INSTALLED + 1))
fi

# Windsurf - appends to global_rules.md
MARKER="# Web Interface Guidelines"
if [ -d "$HOME/.codeium" ] || [ -d "$HOME/Library/Application Support/Windsurf" ]; then
  mkdir -p "$HOME/.codeium/windsurf/memories"
  RULES_FILE="$HOME/.codeium/windsurf/memories/global_rules.md"
  if [ -f "$RULES_FILE" ] && grep -q "$MARKER" "$RULES_FILE"; then
    echo "✓ Windsurf (already installed)"
  else
    if [ -f "$RULES_FILE" ]; then
      echo "" >> "$RULES_FILE"
    fi
    echo "$MARKER" >> "$RULES_FILE"
    echo "" >> "$RULES_FILE"
    curl -sL "$REPO_URL/$COMMAND_FILE" >> "$RULES_FILE"
    echo "✓ Windsurf"
  fi
  INSTALLED=$((INSTALLED + 1))
fi

# Gemini CLI - uses TOML command format
if command -v gemini &> /dev/null || [ -d "$HOME/.gemini" ]; then
  mkdir -p "$HOME/.gemini/commands"
  TOML_FILE="$HOME/.gemini/commands/web-interface-guidelines.toml"

  # Download markdown and convert to TOML
  CONTENT=$(curl -sL "$REPO_URL/$COMMAND_FILE" | sed '1,/^---$/d' | sed '1,/^---$/d')
  cat > "$TOML_FILE" << 'TOMLEOF'
description = "Review UI code for Web Interface Guidelines compliance"
prompt = """
TOMLEOF
  echo "$CONTENT" >> "$TOML_FILE"
  echo '"""' >> "$TOML_FILE"

  echo "✓ Gemini CLI"
  INSTALLED=$((INSTALLED + 1))
fi

echo ""

if [ $INSTALLED -eq 0 ]; then
  echo "No supported tools detected."
  echo ""
  echo "Install one of these first:"
  echo "  • Claude Code: https://claude.ai/code"
  echo "  • Cursor: https://cursor.com"
  echo "  • OpenCode: https://opencode.ai"
  echo "  • Windsurf: https://codeium.com/windsurf"
  echo "  • Gemini CLI: https://github.com/google-gemini/gemini-cli"
  echo ""
  echo "For Codex CLI, add the guidelines to your project's AGENTS.md."
  exit 1
fi

echo "Done! Run /web-interface-guidelines <file> to review."
