#!/usr/bin/env bash
# Screenshots of the real build with headless Chrome (needs a built build/web and a free port 8123).
# Writes assets/screenshots/01-title.png and so on (240x192 logical, scaled 3x). The #level=N&keys=... hash is
# the page's QA hook: jump to a level, then press pad buttons (U D L R walk, C crank).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p assets/screenshots
python3 -m http.server -d build/web 8123 >/dev/null 2>&1 &
srv=$!
trap 'kill $srv' EXIT
sleep 1
shot() { # name url virtual-time-ms
	google-chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size=720,576 \
		--virtual-time-budget="$3" --screenshot="assets/screenshots/$1.png" "$2" >/dev/null 2>&1
}
shot 01-title "http://localhost:8123/" 3000
shot 02-seen "http://localhost:8123/#level=3" 3000
shot 03-tour "http://localhost:8123/#level=10&keys=DRRRRRRRRRRC" 3000
shot 04-won "http://localhost:8123/#level=1&keys=RRRRRRRRRC" 3000
shot 05-two-tables "http://localhost:8123/#level=7" 3000
ls -l assets/screenshots
