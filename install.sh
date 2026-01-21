#!/bin/bash

# Vercel Web Interface Guidelines installer
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
  mkdir -p "$HOME/.config/opencode/commands"
  curl -sL -o "$HOME/.config/opencode/commands/$INSTALL_NAME" "$REPO_URL/$COMMAND_FILE"
  printf "${GREEN}✓${RESET} OpenCode Commands\n"
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

# Antigravity - uses SKILL.md format in global_skills folder
if command -v agy &> /dev/null || [ -d "$HOME/.gemini/antigravity" ]; then
  SKILL_DIR="$HOME/.gemini/antigravity/global_skills/web-interface-guidelines"
  mkdir -p "$SKILL_DIR"

  # Download markdown and convert frontmatter to SKILL.md format
  # Add name field before description, remove argument-hint
  curl -sL "$REPO_URL/$COMMAND_FILE" | sed 's/^description:/name: web-interface-guidelines\
description:/' | grep -v "^argument-hint:" > "$SKILL_DIR/SKILL.md"

  printf "${GREEN}✓${RESET} Antigravity Skill\n"
  INSTALLED=$((INSTALLED + 1))
fi

# Gemini CLI - uses TOML command format
if command -v gemini &> /dev/null || [ -d "$HOME/.gemini" ]; then
  mkdir -p "$HOME/.gemini/commands"
  TOML_FILE="$HOME/.gemini/commands/web-interface-guidelines.toml"
  TEMP_FILE=$(mktemp)

  # Download markdown file to temp file and normalize line endings
  curl -sL "$REPO_URL/$COMMAND_FILE" | tr -d '\r' > "$TEMP_FILE"

  # Extract description from frontmatter (handle possible trailing spaces on ---)
  DESC=$(awk '/^---[[:space:]]*$/{if(f){exit}else{f=1;next}} f{print}' "$TEMP_FILE" | grep '^description:' | sed 's/^description:[[:space:]]*//')

  # Write TOML header
  printf 'description = "%s"\n' "$DESC" > "$TOML_FILE"
  printf 'prompt = """\n' >> "$TOML_FILE"

  # Extract content after frontmatter using awk, escape backslashes for TOML
  # awk: skip until we've seen two --- lines, then print everything after
  awk '
    /^---[[:space:]]*$/ { count++; next }
    count >= 2 { print }
  ' "$TEMP_FILE" | sed 's/\\/\\\\/g' >> "$TOML_FILE"

  # Close the multi-line string
  printf '"""\n' >> "$TOML_FILE"

  # Cleanup
  rm -f "$TEMP_FILE"

  printf "${GREEN}✓${RESET} Gemini CLI Command\n"
  INSTALLED=$((INSTALLED + 1))
fi

echo ""

if [ $INSTALLED -eq 0 ]; then
  echo "No supported tools detected."
  echo ""
  echo "Install one of these first:"
  echo "  • Amp Code: https://ampcode.com"
  echo "  • Antigravity: https://antigravity.google"
  echo "  • Claude Code: https://claude.ai/code"
  echo "  • Cursor: https://cursor.com"
  echo "  • Gemini CLI: https://github.com/google-gemini/gemini-cli"
  echo "  • OpenCode: https://opencode.ai"
  echo "  • Windsurf: https://codeium.com/windsurf"
  echo ""
  echo "For Codex CLI, add the guidelines to your project's AGENTS.md."
  exit 1
fi

echo "Done! Run /web-interface-guidelines <file> to review."
