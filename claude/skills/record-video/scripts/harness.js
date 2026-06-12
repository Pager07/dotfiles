/*
 * Reusable harness for recording headless browser videos of TutorCruncher flows.
 *
 * Usage from a flow script:
 *   const { record } = require(process.env.HOME + '/.claude/skills/record-video/scripts/harness.js');
 *   record(async (page, h) => {
 *     await page.goto(h.baseUrl + '/trans/view/');
 *     await h.pause(800);
 *     // ... flow steps ...
 *   }, { port: 8003, videoName: 'my-flow' });
 *
 * Prints "VIDEO: <path>" on success.
 */
const fs = require('fs');
const path = require('path');
const os = require('os');

function resolvePlaywrightCore() {
  // 1. project-local or globally resolvable install
  for (const name of ['playwright-core', 'playwright']) {
    try {
      return require.resolve(name, { paths: [process.cwd(), __dirname] });
    } catch {}
  }
  // 2. the npx cache used by `npx @playwright/mcp` (hash dir varies per machine/version)
  const npxCache = path.join(os.homedir(), '.npm', '_npx');
  if (fs.existsSync(npxCache)) {
    for (const dir of fs.readdirSync(npxCache)) {
      const candidate = path.join(npxCache, dir, 'node_modules', 'playwright-core');
      if (fs.existsSync(candidate)) return candidate;
    }
  }
  throw new Error(
    'playwright-core not found. Either `npm i playwright-core` in the project, ' +
      'or run the Playwright MCP once (`npx -y @playwright/mcp@latest --version`) to populate the npx cache.'
  );
}

const { chromium } = require(resolvePlaywrightCore());

async function uploadFile(page, triggerSelector, filePath) {
  // Click a button that opens a native file chooser and feed it a file.
  const [chooser] = await Promise.all([page.waitForEvent('filechooser'), page.click(triggerSelector)]);
  await chooser.setFiles(filePath);
}

async function login(page, { baseUrl, agency, email, password }) {
  await page.goto(`${baseUrl}/${agency}/login/`);
  await page.fill('input[type=email], input[name=email]', email);
  await page.fill('input[type=password]', password);
  await page.click('[data-test-id="btn-sign-in-with-email"]');
  await page.waitForURL((url) => !url.pathname.endsWith('/login/'), { timeout: 20000 });
  if (page.url().includes('/login-choice/')) {
    // shown when the user can access multiple branches; first branch is preselected
    await page.click('[data-test-id="btn-continue"]');
    await page.waitForURL((url) => !url.pathname.includes('/login-choice/'), { timeout: 20000 });
  }
  // hide the django debug toolbar - it overlays page buttons and breaks clicks;
  // the hide state is stored in a cookie so it persists for the whole context
  const hide = page.locator('#djHideToolBarButton');
  if (await hide.count()) await hide.click().catch(() => {});
}

async function record(flow, opts = {}) {
  const port = opts.port || 8003;
  const {
    baseUrl = `http://localhost:${port}`,
    email = 'testing+owner@tutorcruncher.com', // Billy Holiday, owner admin on local dev DB
    password = 'testing123',
    agency = 'testagency',
    videoName = 'flow',
    outDir = path.resolve('.playwright-mcp/videos'),
    viewport = { width: 1280, height: 720 },
    headless = true,
    doLogin = true,
  } = opts;

  fs.mkdirSync(outDir, { recursive: true });
  const browser = await chromium.launch({ channel: 'chrome', headless });
  const context = await browser.newContext({ viewport, recordVideo: { dir: outDir, size: viewport } });
  const page = await context.newPage();
  page.on('dialog', (d) => d.accept()); // e.g. beforeunload guards on form-submit navigations

  let failure = null;
  try {
    if (doLogin) await login(page, { baseUrl, agency, email, password });
    await flow(page, {
      baseUrl,
      pause: (ms = 1000) => page.waitForTimeout(ms),
      uploadFile: (trigger, file) => uploadFile(page, trigger, file),
    });
  } catch (e) {
    failure = e;
  } finally {
    await context.close(); // flushes the video to disk
    await browser.close();
  }

  const raw = await page.video().path();
  const dest = path.join(outDir, `${videoName}${failure ? '-FAILED' : ''}.webm`);
  fs.renameSync(raw, dest);
  console.log('VIDEO:', dest);
  if (failure) {
    console.error('FLOW FAILED (video kept for debugging):', failure.message);
    process.exit(1);
  }
  return dest;
}

module.exports = { record, uploadFile };
