#!/usr/bin/env bash
# Compare the newest PHP tag with state/last_tag.txt and notify via ntfy if it
# changed. Updates the state file but leaves committing to the workflow.
#
# Env: NTFY_TOPIC (required unless DRY_RUN=true), INCLUDE_PRERELEASES,
#      STATE_FILE (default state/last_tag.txt), FEED_FILE (optional feed path).
set -euo pipefail

STATE_FILE="${STATE_FILE:-state/last_tag.txt}"
here="$(dirname "$0")"

tag=$("$here/latest_php_tag.sh" ${FEED_FILE:+"$FEED_FILE"})
echo "Newest matching tag: $tag"

if [ ! -f "$STATE_FILE" ]; then
  echo "First run: recording $tag without notifying"
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$tag" > "$STATE_FILE"
  exit 0
fi

last=$(tr -d '[:space:]' < "$STATE_FILE")
if [ "$tag" = "$last" ]; then
  echo "No change (still $last)"
  exit 0
fi

echo "New tag: $last -> $tag"
if [ "${DRY_RUN:-false}" = "true" ]; then
  echo "DRY_RUN: would notify and update $STATE_FILE"
  exit 0
fi

: "${NTFY_TOPIC:?NTFY_TOPIC secret is not set}"
curl -fsS --retry 3 --retry-delay 2 \
  -H "Title: New PHP release" \
  -H "Priority: high" \
  -H "Tags: elephant" \
  -H "Click: https://www.php.net/releases/" \
  -d "$tag" \
  "https://ntfy.sh/$NTFY_TOPIC" > /dev/null

echo "$tag" > "$STATE_FILE"
