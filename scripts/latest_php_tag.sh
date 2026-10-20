#!/usr/bin/env bash
# Print the newest matching php-src tag from the tags Atom feed.
#
# Usage: latest_php_tag.sh [feed-file]
#   With no argument the feed is fetched from GitHub. A file path (or "-" for
#   stdin) is read instead, which is handy for dry runs.
#
# INCLUDE_PRERELEASES=true also matches php-X.Y.ZalphaN / betaN / RCN tags.
set -euo pipefail

FEED_URL="https://github.com/php/php-src/tags.atom"
INCLUDE_PRERELEASES="${INCLUDE_PRERELEASES:-false}"

STABLE_RE='^php-[0-9]+\.[0-9]+\.[0-9]+$'
PRERELEASE_RE='^php-[0-9]+\.[0-9]+\.[0-9]+((alpha|beta|RC)[0-9]+)?$'

if [ "$INCLUDE_PRERELEASES" = "true" ]; then
  TAG_RE="$PRERELEASE_RE"
else
  TAG_RE="$STABLE_RE"
fi

case "${1:-}" in
  "")  feed=$(curl -fsSL --retry 3 --retry-delay 2 "$FEED_URL") ;;
  "-") feed=$(cat) ;;
  *)   feed=$(cat "$1") ;;
esac

# Entries are ordered newest first; each links to .../releases/tag/<tag>.
# Take the first one that matches (|| true: grep exits 1 on no match, and
# head closing the pipe early can SIGPIPE it under pipefail).
tag=$(printf '%s\n' "$feed" \
  | { grep -oE '/php/php-src/releases/tag/[^"<]+' || true; } \
  | sed 's|.*/tag/||' \
  | { grep -E "$TAG_RE" || true; } \
  | head -n1)

if [ -z "$tag" ]; then
  echo "No matching tag found in feed" >&2
  exit 1
fi

echo "$tag"
