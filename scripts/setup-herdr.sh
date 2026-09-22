#!/usr/bin/env bash
# Install Herdr + herdr-radar and wire iTerm2 to JetBrains Mono Herdr.
set -euo pipefail

echo 'Install herdr'
echo '-------------'
if ! command -v herdr >/dev/null 2>&1; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
herdr --version

echo 'Install herdr-radar plugin'
echo '--------------------------'
if herdr plugin list 2>/dev/null | grep -q 'hhdebb.herdr-radar'; then
  echo 'herdr-radar already installed'
else
  herdr plugin install hhdebb/herdr-radar -y
fi

# Sidebar/tab-bar/theme blocks + icon font (ghostty/kitty mapping).
# Safe to re-run; configure may no-op if a server is not up yet.
herdr plugin action invoke configure --plugin hhdebb.herdr-radar || true
herdr plugin action invoke install-font --plugin hhdebb.herdr-radar || true

echo 'Install JetBrains Mono Herdr for iTerm2'
echo '--------------------------------------'
# iTerm has no codepoint map — use the merged font as the profile Normal Font.
MERGED_SRC=""
for candidate in \
  "${HOME}/.config/herdr/plugins/github"/hhdebb.herdr-radar-*/dist/JetBrainsMonoHerdr-Regular.ttf \
  ; do
  if [[ -f "$candidate" ]]; then
    MERGED_SRC="$candidate"
    break
  fi
done

if [[ -z "$MERGED_SRC" ]]; then
  echo 'JetBrainsMonoHerdr-Regular.ttf not found in plugin dist; downloading from GitHub…'
  MERGED_SRC="$(mktemp -t JetBrainsMonoHerdr-Regular.XXXXXX.ttf)"
  curl -fsSL -o "$MERGED_SRC" \
    'https://github.com/hhdebb/herdr-radar/raw/main/dist/JetBrainsMonoHerdr-Regular.ttf'
fi

mkdir -p "${HOME}/Library/Fonts"
cp -f "$MERGED_SRC" "${HOME}/Library/Fonts/JetBrainsMonoHerdr-Regular.ttf"
echo "font: ${HOME}/Library/Fonts/JetBrainsMonoHerdr-Regular.ttf"

HERDR_FONT='JetBrainsMonoHerdr-Regular 13'

set_iterm_font() {
  local plist="$1"
  [[ -f "$plist" ]] || return 0
  python3 - "$plist" "$HERDR_FONT" <<'PY'
import plistlib, sys
from pathlib import Path
path, font = Path(sys.argv[1]), sys.argv[2]
with path.open("rb") as f:
    data = plistlib.load(f)
changed = False
for bookmark in data.get("New Bookmarks", []):
    if bookmark.get("Normal Font") != font:
        bookmark["Normal Font"] = font
        changed = True
if changed:
    # Preserve XML vs binary based on existing file sniff
    raw = path.read_bytes()[:5]
    fmt = plistlib.FMT_XML if raw.startswith(b"<?xml") or raw.startswith(b"<plist") else plistlib.FMT_BINARY
    with path.open("wb") as f:
        plistlib.dump(data, f, fmt=fmt)
    print(f"updated Normal Font -> {font} in {path}")
else:
    print(f"already set in {path}")
PY
}

# Dotfiles copy (source of truth in this repo)
set_iterm_font "${HOME}/.dotfiles/misc/iterm/com.googlecode.iterm2.plist"

# Live prefs folder used on this machine (PrefsCustomFolder)
LIVE_PREFS="${HOME}/Documents/Work/iTerm/com.googlecode.iterm2.plist"
if [[ -f "$LIVE_PREFS" ]]; then
  set_iterm_font "$LIVE_PREFS"
else
  mkdir -p "${HOME}/Documents/Work/iTerm"
  if [[ -f "${HOME}/.dotfiles/misc/iterm/com.googlecode.iterm2.plist" ]]; then
    cp "${HOME}/.dotfiles/misc/iterm/com.googlecode.iterm2.plist" "$LIVE_PREFS"
    echo "seeded ${LIVE_PREFS}"
  fi
fi

# Library domain + custom-folder flags (matches current MacBook setup)
set_iterm_font "${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${HOME}/Documents/Work/iTerm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo 'Herdr + radar + iTerm font ready. Open a new iTerm2 window to pick up the font.'
