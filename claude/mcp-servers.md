# Claude Code — MCP servers to re-add

These were NOT committed with their tokens. Re-add them on the new machine with the
real tokens (sent separately, e.g. via Slack-to-self). Replace every `<...>` placeholder.

> Tip: `claude mcp list` shows what's already configured. `claude mcp remove <name>` undoes a bad add.

## Prerequisites
- Node.js (`npx`) — `brew install node`
- `uv` (`uvx`) for the logfire servers — `brew install uv`

---

## 1. GitHub — user scope (global, available everywhere)

```bash
claude mcp add github --scope user \
  --env GITHUB_PERSONAL_ACCESS_TOKEN=<GITHUB_PAT> \
  -- npx -y @modelcontextprotocol/server-github
```

## 2. TutorCruncher2 project servers

These were originally scoped to the `TutorCruncher2` repo. Run them **from inside that repo's
directory** on the Mac (default `local` scope), or add `--scope user` to make them global.

### Sentry (no token needed)
```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

### Logfire — TutorCruncher prod
```bash
claude mcp add logfire-tutorcruncher-prod \
  --env LOGFIRE_READ_TOKEN=<LOGFIRE_PROD_TOKEN> \
  -- uvx logfire-mcp@latest
```

### Logfire — TutorCruncher UI 2.0
```bash
# NB: server name must not contain a dot ('.') — the CLI only allows letters,
# numbers, hyphens and underscores. Use 'ui2', not 'ui2.0'.
claude mcp add logfire-tutorcruncher-ui2 \
  --env LOGFIRE_READ_TOKEN=<LOGFIRE_UI2_TOKEN> \
  -- uvx logfire-mcp@latest
```

### Logfire — Chronos prod
```bash
claude mcp add logfire-chronos-prod \
  --env LOGFIRE_READ_TOKEN=<LOGFIRE_CHRONOS_TOKEN> \
  -- uvx logfire-mcp@latest
```

### Logfire — Morpheus prod
```bash
claude mcp add logfire-morpheus-prod \
  --env LOGFIRE_READ_TOKEN=<LOGFIRE_MORPHEUS_TOKEN> \
  -- uvx logfire-mcp@latest
```

### CircleCI
```bash
claude mcp add circleci-mcp-server \
  --env CIRCLECI_TOKEN=<CIRCLECI_TOKEN> \
  --env CIRCLECI_BASE_URL=https://circleci.com \
  -- npx -y @circleci/mcp-server-circleci
```

---

## Placeholder → key map (fill from the Slack message)
| Placeholder | What it is |
|---|---|
| `<GITHUB_PAT>` | GitHub personal access token |
| `<CIRCLECI_TOKEN>` | CircleCI personal API token |
| `<LOGFIRE_PROD_TOKEN>` | Logfire read token — TutorCruncher prod |
| `<LOGFIRE_UI2_TOKEN>` | Logfire read token — UI 2.0 |
| `<LOGFIRE_CHRONOS_TOKEN>` | Logfire read token — Chronos prod |
| `<LOGFIRE_MORPHEUS_TOKEN>` | Logfire read token — Morpheus prod |
