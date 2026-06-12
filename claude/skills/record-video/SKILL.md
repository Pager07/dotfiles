---
name: record-video
description: Record a headless Playwright video (.webm) of a TutorCruncher browser flow on a local dev server — login, navigation, clicks, file uploads — for PR demos or verifying a change visually. Use when the user asks to "record a video", "make a demo/GIF of a flow", or "show the feature working" against localhost. The user usually supplies the dev-server port; logs in as Billy Holiday by default.
---

# record-video

Records a headless browser video of any flow on a local TutorCruncher dev server using
Playwright (no MCP needed — works even when the Playwright MCP isn't connected, and unlike
the MCP it supports video because recording must be enabled at context creation).

## Preconditions

- The dev server is running. **Ask the user for the port if not stated** (each worktree
  runs on its own port; 8003 is the default here).
- Node is installed. Playwright is resolved automatically by the harness (project
  `node_modules`, then the `npx @playwright/mcp` cache).
- One-off per machine: Playwright's bundled ffmpeg. If the run errors with
  "Video rendering requires ffmpeg", run:
  `node <resolved playwright-core dir>/cli.js install ffmpeg`
  (the error message includes the exact path; it's a ~1MB download).

## Default credentials

| | |
|---|---|
| Email | `testing+owner@tutorcruncher.com` |
| Password | `testing123` |
| User | Billy Holiday — owner Administrator, Test Agency (`testagency`), local dev DB |

If login fails (different DB / anon dump), use the **login-as** skill to set known
credentials first, then pass `email`/`password`/`agency` in opts.

## How to use

1. Write a small flow script (put it in `<repo>/.playwright-mcp/`, which is gitignored)
   that requires the harness and contains ONLY the flow steps:

```js
const { record } = require(process.env.HOME + '/.claude/skills/record-video/scripts/harness.js');

record(async (page, h) => {
  await page.goto(h.baseUrl + '/trans/view/');
  await h.pause(800);                                          // linger so the video is readable
  await h.uploadFile('[data-test-id="btn-import"]', '/abs/path/file.csv'); // button → file chooser
  await page.waitForURL('**/trans/import/preview/');
  await h.pause(1500);
  await page.click('[data-test-id="btn-confirm-import"]');
  await page.waitForURL('**/trans/view/');
  await h.pause(1500);
}, { port: 8003, videoName: 'translation-import-flow' });
```

2. Run it: `node <repo>/.playwright-mcp/my_flow.js` — it prints `VIDEO: <path>` on success.

## What the harness handles for you

- Headless Chrome (`channel: 'chrome'`, your installed browser — no browser download)
- 1280x720 context with `recordVideo`; video renamed to `<videoName>.webm` in
  `<cwd>/.playwright-mcp/videos/`
- Login (agency form → optional branch-choice page) and hiding the Django Debug Toolbar
  (it overlays buttons and intercepts clicks)
- Auto-accepting dialogs (`beforeunload` guards fire on form-submit navigations and will
  otherwise wedge the run)
- On flow error: video is kept as `<videoName>-FAILED.webm` for debugging, exit code 1

## Options (second argument to `record`)

| Option | Default | Notes |
|---|---|---|
| `port` | `8003` | ignored if `baseUrl` given |
| `baseUrl` | `http://localhost:<port>` | |
| `email` / `password` | Billy Holiday creds above | |
| `agency` | `testagency` | login URL slug |
| `videoName` | `flow` | output file name |
| `outDir` | `<cwd>/.playwright-mcp/videos` | |
| `viewport` | 1280x720 | also the video size |
| `headless` | `true` | set `false` to watch live |
| `doLogin` | `true` | set `false` for anonymous pages |

## Tips

- Sprinkle `h.pause(800–1500)` after navigations and before/after the money shot —
  without pauses the video is an unwatchable blur.
- Selector convention in this codebase: `[data-test-id="btn-..."]` on buttons.
- `.webm` plays in Chrome and uploads fine to GitHub PR comments. For `.mp4`/GIF,
  convert with system ffmpeg (`brew install ffmpeg`) — Playwright's bundled ffmpeg
  binary also works: `<ms-playwright cache>/ffmpeg-*/ffmpeg-mac -i in.webm out.mp4`.
- Verify any DB side effects of the flow afterwards via `manage.py shell`, and leave
  the DB clean (e.g. end the flow by undoing what it created).
