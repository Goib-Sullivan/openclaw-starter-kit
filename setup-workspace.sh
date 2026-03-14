#!/usr/bin/env bash
# setup-workspace.sh — Copy starter workspace templates to ~/.openclaw/workspace/
# This script ONLY copies files. It does NOT install OpenClaw, modify config, or touch openclaw.json.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DEST="$HOME/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/workspace"

echo ""
echo "📁 OpenClaw Workspace Setup"
echo "Destination: $DEST"
echo "-----------------------------------"

# Check that the workspace directory exists
if [ ! -d "$DEST" ]; then
  echo -e "${RED}✗ Workspace directory not found: $DEST${NC}"
  echo "  Make sure OpenClaw is installed first. See INSTALL-GUIDE.md"
  exit 1
fi

# Check that our source templates exist
if [ ! -d "$SRC" ]; then
  echo -e "${RED}✗ Template directory not found: $SRC${NC}"
  echo "  Make sure you're running this script from inside the openclaw-starter-kit folder."
  exit 1
fi

FILES=(SOUL.md USER.md IDENTITY.md AGENTS.md TOOLS.md MEMORY.md HEARTBEAT.md)

for FILE in "${FILES[@]}"; do
  if [ ! -f "$SRC/$FILE" ]; then
    echo -e "${YELLOW}⚠ Skipping $FILE (not found in templates)${NC}"
    continue
  fi
  if [ -f "$DEST/$FILE" ]; then
    cp "$DEST/$FILE" "$DEST/$FILE.backup"
    echo -e "${YELLOW}↩ Backed up existing $FILE → $FILE.backup${NC}"
  fi
  cp "$SRC/$FILE" "$DEST/$FILE"
  echo -e "${GREEN}✓ Copied $FILE${NC}"
done

echo ""
echo -e "${GREEN}✅ Workspace templates installed to $DEST/${NC}"
echo ""
echo "📝 Next: Fill in your details"
echo "   nano $DEST/USER.md   ← Your name, timezone, preferences"
echo "   nano $DEST/SOUL.md   ← Your assistant's personality"
echo ""
