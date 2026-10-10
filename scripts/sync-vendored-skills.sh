#!/usr/bin/env bash
# Re-vendor the official ClickHouse sub-skills bundled with skills/data-analyst.
#
# Usage: scripts/sync-vendored-skills.sh [<commit-or-ref>]
#
# With no argument, re-copies the commit recorded in
# skills/data-analyst/skills/VENDORED.md (should produce no diff besides the date).
# Pass a commit SHA, tag, or branch (e.g. `main`) to update to that upstream revision.
# Review and commit the result.
set -euo pipefail

REPO_URL="https://github.com/ClickHouse/agent-skills"
SKILLS=(
  chdb-datastore
  chdb-sql
  clickhouse-architecture-advisor
  clickhouse-best-practices
  clickhouse-js-node-coding
  clickhouse-js-node-troubleshooting
  clickhousectl-cloud-deploy
  clickhousectl-local-dev
)

ROOT="$(git rev-parse --show-toplevel)"
DEST="$ROOT/skills/data-analyst/skills"
RECORD="$DEST/VENDORED.md"

REF="${1:-}"
if [ -z "$REF" ]; then
  REF="$(sed -n 's/^- Commit: `\([0-9a-f]\{40\}\)`.*/\1/p' "$RECORD" 2>/dev/null || true)"
  [ -n "$REF" ] || { echo "No commit given and none recorded in $RECORD" >&2; exit 1; }
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -C "$TMP" init -q
git -C "$TMP" config core.longpaths true   # deep rule paths exceed MAX_PATH on Windows
git -C "$TMP" remote add origin "$REPO_URL.git"
git -C "$TMP" fetch -q --depth 1 origin "$REF"
git -C "$TMP" checkout -q FETCH_HEAD
COMMIT="$(git -C "$TMP" rev-parse HEAD)"
COMMIT_DATE="$(git -C "$TMP" log -1 --format=%cs)"

for s in "${SKILLS[@]}"; do
  [ -f "$TMP/skills/$s/SKILL.md" ] || { echo "Upstream $COMMIT has no skills/$s/SKILL.md" >&2; exit 1; }
  rm -rf "${DEST:?}/$s"
  cp -R "$TMP/skills/$s" "$DEST/$s"
  # Repo/registry metadata and build templates; not read by the skills themselves.
  rm -f "$DEST/$s/README.md" "$DEST/$s/metadata.json" "$DEST/$s"/rules/_*.md
done

cp "$TMP/LICENSE" "$DEST/LICENSE-clickhouse-agent-skills"
if [ -f "$TMP/NOTICE" ]; then
  cp "$TMP/NOTICE" "$DEST/NOTICE-clickhouse-agent-skills"
else
  rm -f "$DEST/NOTICE-clickhouse-agent-skills"
fi

{
  cat <<MD
# Vendored third-party skills

The sub-skills listed below are copied from [ClickHouse/agent-skills]($REPO_URL).
They are committed as plain files (not a submodule or symlinks) so that every
installer that copies this repository (GitHub tarballs, \`npx skills\`, the Cline
marketplace) delivers them.

- Source: $REPO_URL
- Commit: \`$COMMIT\` (committed upstream $COMMIT_DATE)
- Licence: Apache License 2.0, see \`LICENSE-clickhouse-agent-skills\` and \`NOTICE-clickhouse-agent-skills\` in this directory
- Vendored on: $(date -u +%F)

Skills, each copied from \`skills/<name>/\` upstream:

MD
  for s in "${SKILLS[@]}"; do echo "- \`$s/\`"; done
  cat <<'MD'

Upstream files are unmodified. Omitted from each skill: its top-level `README.md`
and `metadata.json`, plus `rules/_*.md` (repo/registry metadata and build
templates that the skills do not read).

To refresh, run from the repository root:

```
scripts/sync-vendored-skills.sh          # re-copy the commit above
scripts/sync-vendored-skills.sh main     # update to the latest upstream
```
MD
} > "$RECORD"

echo "Vendored ClickHouse/agent-skills@$COMMIT into ${DEST#$ROOT/}"
