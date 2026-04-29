#!/bin/bash

# ─────────────────────────────────────────
#   Minecraft Whitelist Manager
#   Offline Mode | Fabric 1.21.11
# ─────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WHITELIST="$SCRIPT_DIR/data/whitelist.json"
PLAYER_NAME="$1"

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║      Minecraft Whitelist Manager     ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════╝${RESET}"
echo ""

if [ -z "$PLAYER_NAME" ]; then
  echo -e "${RED}${BOLD}  ✗  No player name provided.${RESET}"
  echo -e "${DIM}     Usage: $0 <PlayerName>${RESET}"
  echo ""
  exit 1
fi

echo -e "${DIM}  →  Target player  : ${RESET}${BOLD}$PLAYER_NAME${RESET}"
echo -e "${DIM}  →  Whitelist file : ${RESET}${DIM}$WHITELIST${RESET}"
echo ""

# ── Generate offline UUID ──────────────────
echo -e "${YELLOW}  ⚙  Generating offline UUID...${RESET}"

UUID=$(python3 -c "
import hashlib

name = 'OfflinePlayer:$PLAYER_NAME'
digest = hashlib.md5(name.encode('utf-8')).digest()

b = list(digest)
b[6] = (b[6] & 0x0F) | 0x30
b[8] = (b[8] & 0x3F) | 0x80

h = ''.join(f'{x:02x}' for x in b)
print(f'{h[0:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:32]}')
")

echo -e "${DIM}  →  UUID           : ${RESET}${CYAN}$UUID${RESET}"
echo ""

# ── Update whitelist.json ──────────────────
echo -e "${YELLOW}  ⚙  Updating whitelist.json...${RESET}"

RESULT=$(python3 -c "
import json

with open('$WHITELIST', 'r') as f:
    whitelist = json.load(f)

for entry in whitelist:
    if entry['name'].lower() == '$PLAYER_NAME'.lower():
        print('exists')
        exit(0)

whitelist.append({'uuid': '$UUID', 'name': '$PLAYER_NAME'})

with open('$WHITELIST', 'w') as f:
    json.dump(whitelist, f, indent=2)

print('added')
")

if [ "$RESULT" = "exists" ]; then
  echo -e "${YELLOW}  ⚠  ${BOLD}$PLAYER_NAME${RESET}${YELLOW} is already on the whitelist. Skipping.${RESET}"
  echo ""
  exit 0
fi

echo -e "${GREEN}  ✔  Added ${BOLD}$PLAYER_NAME${RESET}${GREEN} to whitelist.json${RESET}"
echo ""

# ── Reload via rcon ────────────────────────
echo -e "${YELLOW}  ⚙  Reloading whitelist via RCON...${RESET}"

docker exec minecraft-server rcon-cli whitelist reload

echo ""
echo -e "${GREEN}${BOLD}  ✔  Done! $PLAYER_NAME can now join the server.${RESET}"
echo ""
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════╝${RESET}"
echo ""

