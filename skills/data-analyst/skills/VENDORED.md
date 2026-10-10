# Vendored third-party skills

The sub-skills listed below are copied from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills).
They are committed as plain files (not a submodule or symlinks) so that every
installer that copies this repository (GitHub tarballs, `npx skills`, the Cline
marketplace) delivers them.

- Source: https://github.com/ClickHouse/agent-skills
- Commit: `46ef08ccf32fa28587b64e0c79106ff437dc8fcb` (committed upstream 2026-05-26)
- Licence: Apache License 2.0, see `LICENSE-clickhouse-agent-skills` and `NOTICE-clickhouse-agent-skills` in this directory
- Vendored on: 2026-10-10

Skills, each copied from `skills/<name>/` upstream:

- `chdb-datastore/`
- `chdb-sql/`
- `clickhouse-architecture-advisor/`
- `clickhouse-best-practices/`
- `clickhouse-js-node-coding/`
- `clickhouse-js-node-troubleshooting/`
- `clickhousectl-cloud-deploy/`
- `clickhousectl-local-dev/`

Upstream files are unmodified. Omitted from each skill: its top-level `README.md`
and `metadata.json`, plus `rules/_*.md` (repo/registry metadata and build
templates that the skills do not read).

To refresh, run from the repository root:

```
scripts/sync-vendored-skills.sh          # re-copy the commit above
scripts/sync-vendored-skills.sh main     # update to the latest upstream
```
