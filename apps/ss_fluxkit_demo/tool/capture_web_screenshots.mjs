#!/usr/bin/env node
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.resolve(__dirname, '../build/web');
const outDir =
  process.argv[2] || '/opt/cursor/artifacts/ssfluxkit-ecommerce-impl';

const routes = [
  { path: '/', name: 'impl-home' },
  { path: '/category', name: 'impl-category' },
  { path: '/cart', name: 'impl-cart' },
  { path: '/profile', name: 'impl-profile' },
];

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

async function main() {
  fs.mkdirSync(outDir, { recursive: true });
  const server = await serve(webRoot);
  const port = server.address().port;
  const base = `http://127.0.0.1:${port}`;

  const browser = await puppeteer.launch({
    executablePath: chromePath(),
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  for (const { path: route, name } of routes) {
    const page = await browser.newPage();
    await page.setViewport({
      width: 390,
      height: 844,
      deviceScaleFactor: 2,
    });
    const hashRoute = route === '/' ? '/#/' : `/#${route}`;
    await page.goto(`${base}${hashRoute}`, {
      waitUntil: 'networkidle0',
      timeout: 120000,
    });
    await page.waitForSelector('flt-glass-pane, flutter-view', {
      timeout: 90000,
    });
    await new Promise((r) => setTimeout(r, 4500));
    await page.screenshot({
      path: path.join(outDir, `${name}.png`),
      type: 'png',
    });
    console.log('captured', name);
    await page.close();
  }

  await browser.close();
  server.close();

  // stitch overview
  const sharp = (await import('sharp')).default;
  const imgs = await Promise.all(
    routes.map((r) =>
      sharp(path.join(outDir, `${r.name}.png`)).metadata(),
    ),
  );
  const gap = 48;
  const pad = 40;
  const titleH = 100;
  const w = imgs[0].width * 4 + gap * 3 + pad * 2;
  const h = titleH + imgs[0].height + 60 + pad;
  const composites = [];
  let x = pad;
  const labels = ['首页', '分类', '购物车', '我的'];
  for (let i = 0; i < routes.length; i++) {
    composites.push({
      input: path.join(outDir, `${routes[i].name}.png`),
      left: x,
      top: titleH,
    });
    const label = Buffer.from(
      `<svg width="${imgs[0].width}" height="40"><text x="50%" y="28" text-anchor="middle" font-size="22" font-family="sans-serif" fill="#37474f">${labels[i]}</text></svg>`,
    );
    composites.push({ input: label, left: x, top: titleH + imgs[0].height + 8 });
    x += imgs[0].width + gap;
  }
  const title = Buffer.from(
    `<svg width="${w}" height="${titleH}"><text x="50%" y="42" text-anchor="middle" font-size="34" font-weight="bold" font-family="sans-serif" fill="#263238">SSFluxKit 电商实现 · Flutter Web</text><text x="50%" y="78" text-anchor="middle" font-size="18" font-family="sans-serif" fill="#607d8b">Phase 2 · 演示数据 · Mock 模式</text></svg>`,
  );
  await sharp({
    create: {
      width: w,
      height: h,
      channels: 4,
      background: { r: 223, g: 227, b: 232 },
    },
  })
    .composite([{ input: title, left: 0, top: 0 }, ...composites])
    .png()
    .toFile(path.join(outDir, 'overview-four-tabs-impl.png'));
  console.log('wrote overview');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
