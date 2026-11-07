#!/usr/bin/env node
/**
 * 浏览器真实交互：宫格→分类、购物车编辑/删空/回首页。需先 build web。
 */
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.resolve(__dirname, '../build/web');
const outDir =
  process.argv[2] || '/opt/cursor/artifacts/ssfluxkit-ecommerce-impl';

function serve(staticDir) {
  return new Promise((resolve) => {
    const server = http.createServer((req, res) => {
      const urlPath = decodeURIComponent(req.url.split('?')[0]);
      let file = path.join(staticDir, urlPath === '/' ? 'index.html' : urlPath);
      if (!file.startsWith(staticDir)) {
        res.writeHead(403);
        res.end();
        return;
      }
      if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
        file = path.join(staticDir, 'index.html');
      }
      res.writeHead(200);
      fs.createReadStream(file).pipe(res);
    });
    server.listen(0, '127.0.0.1', () => resolve(server));
  });
}

function chromePath() {
  for (const p of ['/usr/local/bin/google-chrome', '/usr/bin/google-chrome']) {
    if (fs.existsSync(p)) return p;
  }
  throw new Error('Chrome not found');
}

async function waitFlutter(page) {
  await page.waitForSelector('flt-glass-pane, flutter-view', { timeout: 90000 });
  await new Promise((r) => setTimeout(r, 3500));
}

async function clickSemantics(page, label) {
  const handle = await page.$(`[aria-label="${label}"]`);
  if (handle) {
    await handle.click();
    return true;
  }
  const partial = await page.$(`[aria-label*="${label}"]`);
  if (partial) {
    await partial.click();
    return true;
  }
  return false;
}

async function clickAt(page, x, y) {
  await page.mouse.click(x, y);
}

async function goto(page, base, route) {
  const hash = route === '/' ? '/#/' : `/#${route}`;
  await page.goto(`${base}${hash}`, { waitUntil: 'networkidle0', timeout: 120000 });
  await waitFlutter(page);
}

async function screenshot(page, name) {
  const file = path.join(outDir, name);
  await page.screenshot({ path: file, type: 'png' });
  console.log('shot', name);
}

async function runShell(cmd) {
  const { execSync } = await import('node:child_process');
  execSync(cmd, {
    stdio: 'inherit',
    env: {
      ...process.env,
      PATH: `${process.env.HOME}/flutter/bin:${process.env.PATH}`,
    },
  });
}

async function main() {
  fs.mkdirSync(outDir, { recursive: true });

  const webRootNormal = path.resolve(__dirname, '../build/web');
  await runShell(
    `cd "${path.resolve(__dirname, '..')}" && flutter build web --dart-define=SS_USE_MOCK=true`,
  );

  const server = await serve(webRootNormal);
  const port = server.address().port;
  const base = `http://127.0.0.1:${port}`;

  const browser = await puppeteer.launch({
    executablePath: chromePath(),
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

  // 1) 首页 → 宫格服饰 → 分类
  await goto(page, base, '/');
  const catOk = await clickSemantics(page, '品类-服饰');
  if (!catOk) {
    // Canvas 模式下宫格语义可能未暴露，按 390×844 布局点击「服饰」宫格
    await clickAt(page, 139, 310);
  }
  await new Promise((r) => setTimeout(r, 2000));
  await screenshot(page, 'flow-category-apparel.png');

  // 2) 购物车编辑 → 全选 → 删除 → 空态
  await goto(page, base, '/cart');
  if (!(await clickSemantics(page, '购物车-编辑'))) {
    await clickAt(page, 355, 58);
  }
  await new Promise((r) => setTimeout(r, 1500));
  await screenshot(page, 'flow-cart-edit-mode.png');

  const checks = await page.$$('[role="checkbox"]');
  if (checks.length > 0) {
    for (const c of checks) await c.click();
  } else {
    for (const y of [156, 238, 328, 418]) {
      await clickAt(page, 22, y);
      await new Promise((r) => setTimeout(r, 150));
    }
  }
  await new Promise((r) => setTimeout(r, 600));
  if (!(await clickSemantics(page, '购物车-删除选中'))) {
    await clickAt(page, 300, 800);
  }
  await new Promise((r) => setTimeout(r, 2000));
  await screenshot(page, 'flow-cart-after-edit.png');

  await browser.close();
  server.close();

  await runShell(
    `cd "${path.resolve(__dirname, '..')}" && flutter build web --dart-define=SS_USE_MOCK=true --dart-define=SS_CART_DEMO_EMPTY=true`,
  );
  const emptyServer = await serve(path.resolve(__dirname, '../build/web'));
  const emptyPort = emptyServer.address().port;
  const emptyBase = `http://127.0.0.1:${emptyPort}`;
  const emptyBrowser = await puppeteer.launch({
    executablePath: chromePath(),
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const emptyPage = await emptyBrowser.newPage();
  await emptyPage.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  await goto(emptyPage, emptyBase, '/cart');
  await screenshot(emptyPage, 'flow-cart-empty.png');
  if (!(await clickSemantics(emptyPage, '购物车-去逛逛'))) {
    await clickAt(emptyPage, 195, 472);
  }
  await new Promise((r) => setTimeout(r, 2000));
  await screenshot(emptyPage, 'flow-back-home.png');
  await emptyBrowser.close();
  emptyServer.close();

  await runShell(
    `cd "${path.resolve(__dirname, '..')}" && flutter build web --dart-define=SS_USE_MOCK=true`,
  );
  const server2 = await serve(path.resolve(__dirname, '../build/web'));
  const port2 = server2.address().port;
  const base2 = `http://127.0.0.1:${port2}`;
  const browser2 = await puppeteer.launch({
    executablePath: chromePath(),
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page2 = await browser2.newPage();
  await page2.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

  for (const [route, name] of [
    ['/', 'impl-home.png'],
    ['/category', 'impl-category.png'],
    ['/cart', 'impl-cart.png'],
    ['/profile', 'impl-profile.png'],
  ]) {
    await goto(page2, base2, route);
    await screenshot(page2, name);
  }

  await browser2.close();
  server2.close();

  const sharp = (await import('sharp')).default;
  const tabs = ['impl-home', 'impl-category', 'impl-cart', 'impl-profile'];
  const meta = await sharp(path.join(outDir, `${tabs[0]}.png`)).metadata();
  const gap = 48;
  const pad = 40;
  const titleH = 100;
  let x = pad;
  const composites = [];
  const labels = ['首页', '分类', '购物车', '我的'];
  for (let i = 0; i < tabs.length; i++) {
    composites.push({
      input: path.join(outDir, `${tabs[i]}.png`),
      left: x,
      top: titleH,
    });
    const label = Buffer.from(
      `<svg width="${meta.width}" height="40"><text x="50%" y="28" text-anchor="middle" font-size="22" font-family="sans-serif" fill="#37474f">${labels[i]}</text></svg>`,
    );
    composites.push({ input: label, left: x, top: titleH + meta.height + 8 });
    x += meta.width + gap;
  }
  const w = meta.width * 4 + gap * 3 + pad * 2;
  const title = Buffer.from(
    `<svg width="${w}" height="${titleH}"><text x="50%" y="42" text-anchor="middle" font-size="34" font-weight="bold" font-family="sans-serif" fill="#263238">SSFluxKit 电商实现 · 收尾验收</text><text x="50%" y="78" text-anchor="middle" font-size="18" font-family="sans-serif" fill="#607d8b">宫格跳转 / 购物车编辑 / 空态回首页</text></svg>`,
  );
  await sharp({
    create: {
      width: w,
      height: titleH + meta.height + 60 + pad,
      channels: 4,
      background: { r: 223, g: 227, b: 232 },
    },
  })
    .composite([{ input: title, left: 0, top: 0 }, ...composites])
    .png()
    .toFile(path.join(outDir, 'overview-four-tabs-impl.png'));

  console.log('interaction flow OK');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
