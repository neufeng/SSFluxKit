#!/usr/bin/env node
/**
 * 从 design/docs HTML 渲染高分辨率 PNG（Puppeteer）。
 * 用法：node design/docs/scripts/capture-design-screenshots.mjs [输出目录]
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import puppeteer from "puppeteer-core";
import sharp from "sharp";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const docsRoot = path.resolve(__dirname, "..");
const outDir =
  process.argv[2] || "/opt/cursor/artifacts/ssfluxkit-ecommerce-design";

const screens = [
  { file: "screens/home.html", name: "tab-home" },
  { file: "screens/category.html", name: "tab-category" },
  { file: "screens/cart.html", name: "tab-cart" },
  { file: "screens/profile.html", name: "tab-profile" },
  { file: "screens/cart-empty.html", name: "tab-cart-empty" },
];

const chromePaths = [
  "/usr/local/bin/google-chrome",
  "/usr/bin/google-chrome",
  "/usr/bin/chromium",
  "/usr/bin/chromium-browser",
];

function resolveChrome() {
  for (const p of chromePaths) {
    if (fs.existsSync(p)) return p;
  }
  throw new Error("未找到 Chrome/Chromium，无法截图");
}

async function main() {
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: resolveChrome(),
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox", "--font-render-hinting=none"],
  });

  const deviceScale = 2;

  for (const { file, name } of screens) {
    const page = await browser.newPage();
    await page.setViewport({
      width: 480,
      height: 960,
      deviceScaleFactor: deviceScale,
    });
    const url = `file://${path.join(docsRoot, file)}`;
    await page.goto(url, { waitUntil: "networkidle0", timeout: 60000 });
    await page.waitForSelector("#screen");
    const el = await page.$("#screen");
    const outPath = path.join(outDir, `${name}.png`);
    await el.screenshot({ path: outPath, type: "png" });
    console.log("wrote", outPath);
    await page.close();
  }

  await browser.close();

  const tabNames = ["tab-home", "tab-category", "tab-cart", "tab-profile"];
  const labels = ["首页", "分类", "购物车", "我的"];
  const gap = 48 * deviceScale;
  const headerH = 120 * deviceScale;
  const labelH = 48 * deviceScale;
  const imgs = await Promise.all(
    tabNames.map((n) => sharp(path.join(outDir, `${n}.png`)).metadata())
  );
  const phoneW = imgs[0].width;
  const phoneH = imgs[0].height;
  const canvasW = phoneW * 4 + gap * 3 + 80 * deviceScale;
  const canvasH = headerH + phoneH + labelH + 40 * deviceScale;

  const composites = [];
  let x = 40 * deviceScale;
  for (let i = 0; i < tabNames.length; i++) {
    composites.push({
      input: path.join(outDir, `${tabNames[i]}.png`),
      left: x,
      top: headerH,
    });
    const labelSvg = Buffer.from(
      `<svg width="${phoneW}" height="${labelH}"><text x="50%" y="60%" text-anchor="middle" font-family="PingFang SC,Microsoft YaHei,sans-serif" font-size="${28 * deviceScale}" font-weight="600" fill="#37474f">${labels[i]}</text></svg>`
    );
    composites.push({ input: labelSvg, left: x, top: headerH + phoneH + 8 });
    x += phoneW + gap;
  }

  const titleSvg = Buffer.from(
    `<svg width="${canvasW}" height="${headerH}">
      <text x="50%" y="${45 * deviceScale}" text-anchor="middle" font-family="PingFang SC,Microsoft YaHei,sans-serif" font-size="${40 * deviceScale}" font-weight="700" fill="#263238">SSFluxKit 电商 UI · Phase 1 设计稿</text>
      <text x="50%" y="${88 * deviceScale}" text-anchor="middle" font-family="PingFang SC,Microsoft YaHei,sans-serif" font-size="${22 * deviceScale}" fill="#607d8b">首页 · 分类 · 购物车 · 我的 — 390×844 首屏 · 演示数据</text>
    </svg>`
  );

  const overviewPath = path.join(outDir, "overview-four-tabs.png");
  await sharp({
    create: {
      width: canvasW,
      height: canvasH,
      channels: 4,
      background: { r: 223, g: 227, b: 232 },
    },
  })
    .composite([{ input: titleSvg, left: 0, top: 0 }, ...composites])
    .png()
    .toFile(overviewPath);
  console.log("wrote", overviewPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
