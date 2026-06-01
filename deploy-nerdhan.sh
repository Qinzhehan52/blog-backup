#!/usr/bin/env bash
# Deploy this Hexo blog to the self-hosted nginx mirror at https://nerdhan.top/
#
# This is a SECOND, manual deploy target. Pushing to `master` only updates
# GitHub Pages (qinzhehan52.github.io) via Actions; nerdhan.top is a static
# mirror that must be synced by running this script. It only replaces static
# files — nginx config and TLS on the server are already set up.
#
# Requires SSH host `racknerd` to be reachable (configured in ~/.ssh/config).
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Building site with nerdhan.top URL..."
npx hexo clean
npx hexo generate --config _config.yml,_config.nerdhan.yml

echo "==> Syncing public/ to racknerd web root..."
rsync -av --delete public/ racknerd:/var/www/nerdhan.top/html/

echo "==> Done. Verifying https://nerdhan.top/ ..."
curl -sS -o /dev/null -w "HTTP %{http_code}\n" https://nerdhan.top/
