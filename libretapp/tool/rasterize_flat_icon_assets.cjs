const fs = require('fs');
const path = require('path');
const sharp = require('C:/Users/Master/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');

const source = path.resolve(__dirname, '..', 'assets', 'icons_2d');
const destination = path.resolve(__dirname, '..', 'assets', 'images');

(async () => {
  const files = fs.readdirSync(source).filter((name) => name.endsWith('.svg')).sort();
  for (const name of files) {
    const input = path.join(source, name);
    const output = path.join(destination, name.replace(/\.svg$/, '.webp'));
    await sharp(input, { density: 192 })
      .resize(256, 256, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
      .ensureAlpha()
      .webp({ quality: 92, alphaQuality: 100 })
      .toFile(output);
  }
  console.log(`Rasterized ${files.length} 2.5D SVG icons to 256px transparent WEBP assets.`);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
