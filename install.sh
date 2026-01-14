#!/bin/bash

# Web Interface Guidelines installer
# https://vercel.com/design/guidelines

set -e

# Colors (only if stdout is a TTY)
if [ -t 1 ]; then
  GREEN='\033[32m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  GREEN=''
  DIM=''
  RESET=''
fi

REPO_URL="https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main"
COMMAND_FILE="command.md"
INSTALL_NAME="web-interface-guidelines.md"
INSTALLED=0

echo "▲ Installing Vercel's Web Interface Guidelines…"
echo ""

# Amp Code
if [ -d "$HOME/.amp" ]; then
  mkdir -p "$HOME/.config/amp/commands"
  curl -sL -o "$HOME/.config/amp/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  printf "${GREEN}✓${RESET} Amp Code Skill\n"
  INSTALLED=$((INSTALLED + 1))
fi

# Claude Code
if [ -d "$HOME/.claude" ]; then
  mkdir -p "$HOME/.claude/commands"
  curl -sL -o "$HOME/.claude/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  printf "${GREEN}✓${RESET} Claude Code Skill\n"
  INSTALLED=$((INSTALLED + 1))
fi

# Cursor (1.6+)
if [ -d "$HOME/.cursor" ]; then
  mkdir -p "$HOME/.cursor/commands"
  curl -sL -o "$HOME/.cursor/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  printf "${GREEN}✓${RESET} Cursor Command\n"
  INSTALLED=$((INSTALLED + 1))
fi

# OpenCode
if command -v opencode &> /dev/null || [ -d "$HOME/.config/opencode" ]; then
  mkdir -p "$HOME/.config/opencode/command"
  curl -sL -o "$HOME/.config/opencode/command/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  printf "${GREEN}✓${RESET} OpenCode Command\n"
  INSTALLED=$((INSTALLED + 1))
fi

# Windsurf - appends to global_rules.md
MARKER="# Web Interface Guidelines"
if [ -d "$HOME/.codeium" ] || [ -d "$HOME/Library/Application Support/Windsurf" ]; then
  mkdir -p "$HOME/.codeium/windsurf/memories"
  RULES_FILE="$HOME/.codeium/windsurf/memories/global_rules.md"
  if [ -f "$RULES_FILE" ] && grep -q "$MARKER" "$RULES_FILE"; then
    printf "${GREEN}✓${RESET} Windsurf ${DIM}(already installed)${RESET}\n"
  else
    if [ -f "$RULES_FILE" ]; then
      echo "" >> "$RULES_FILE"
    fi
    echo "$MARKER" >> "$RULES_FILE"
    echo "" >> "$RULES_FILE"
    curl -sL "$REPO_URL/$COMMAND_FILE" >> "$RULES_FILE"
    printf "${GREEN}✓${RESET} Windsurf Command\n"
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

  printf "${GREEN}✓${RESET} Gemini CLI Command\n"
  INSTALLED=$((INSTALLED + 1))
fi

echo ""

if [ $INSTALLED -eq 0 ]; then
  echo "No supported tools detected."
  echo ""
  echo "Install one of these first:"
  echo "  • Amp Code: https://ampcode.com"
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
