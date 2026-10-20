# php-update-notification

A GitHub Actions workflow that sends a push notification via [ntfy](https://ntfy.sh)
as soon as a new stable PHP release is tagged in
[php/php-src](https://github.com/php/php-src/tags).

It polls the tags feed every 5 minutes, compares the newest `php-X.Y.Z` tag with
`state/last_tag.txt`, and notifies (then commits the new tag) when it changes.
Alpha/beta/RC tags are ignored unless `INCLUDE_PRERELEASES` is set to `"true"`
in `.github/workflows/php-release.yml`. The first run only records the current
tag without notifying.

## Setup

1. Install the ntfy app ([Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy),
   [iOS](https://apps.apple.com/app/ntfy/id1625396347)) or open <https://ntfy.sh/app>.
2. Subscribe to a topic with a long, random name, e.g. `php-releases-k3j9x2v8q1m7`.
   Topics on ntfy.sh are public to anyone who knows the name, so treat it like a password.
3. In this repo go to **Settings → Secrets and variables → Actions → New repository secret**
   and add `NTFY_TOPIC` with that topic name.
4. Enable Actions, then run the workflow once via **Actions → PHP release notifier → Run workflow**
   to record the current tag.

## Scheduled workflows and the 60-day rule

GitHub disables scheduled workflows in a repo with no activity for 60 days. Two safeguards:

- The workflow commits a state update on every new release, which counts as activity.
- If the last commit is older than 45 days, it pushes a keepalive commit (`state/keepalive.txt`).

If the schedule is ever disabled anyway, re-enable it under the **Actions** tab. Note that
scheduled runs can be delayed or skipped under load, so "every 5 minutes" is best effort.
