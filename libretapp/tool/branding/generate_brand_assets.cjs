const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');
const { writeVectorSources, verifyVectorSources } = require('./vector_sources.cjs');

const project = path.resolve(__dirname, '../..');
const branding = path.join(project, 'assets', 'branding');

function mkdir(file) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
}

function copy(source, destination) {
  mkdir(destination);
  fs.copyFileSync(path.join(branding, source), destination);
}

async function render(svg, destination, size) {
  mkdir(destination);
  await sharp(Buffer.from(svg)).resize(size, size, { fit: 'contain' }).png().toFile(destination);
}

function pngIco(pngs) {
  const header = Buffer.alloc(6 + pngs.length * 16);
  header.writeUInt16LE(0, 0);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(pngs.length, 4);
  let offset = header.length;
  const chunks = [header];
  pngs.forEach(({ size, png }, index) => {
    const entry = 6 + index * 16;
    header[entry] = size === 256 ? 0 : size;
    header[entry + 1] = size === 256 ? 0 : size;
    header[entry + 2] = 0;
    header[entry + 3] = 0;
    header.writeUInt16LE(1, entry + 4);
    header.writeUInt16LE(32, entry + 6);
    header.writeUInt32LE(png.length, entry + 8);
    header.writeUInt32LE(offset, entry + 12);
    chunks.push(png);
    offset += png.length;
  });
  return Buffer.concat(chunks);
}

function icnsEntry(type, png) {
  const result = Buffer.alloc(8 + png.length);
  result.write(type, 0, 4, 'ascii');
  result.writeUInt32BE(result.length, 4);
  png.copy(result, 8);
  return result;
}

async function verifyPng(file, size) {
  const info = await sharp(file).metadata();
  if (info.width !== size || info.height !== size) {
    throw new Error(`${path.relative(project, file)} must be ${size}x${size}; got ${info.width}x${info.height}`);
  }
  if (info.format !== 'png') throw new Error(`${path.relative(project, file)} is not PNG`);
  return info;
}

async function verifyOpaquePng(file) {
  const { data, info } = await sharp(file).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  for (let offset = 3; offset < data.length; offset += info.channels) {
    if (data[offset] !== 255) throw new Error(`${path.relative(project, file)} has transparent pixels; iOS icons must be opaque and square.`);
  }
}

async function verifyIco(file, expectedSizes) {
  const data = fs.readFileSync(file);
  if (data.readUInt16LE(0) !== 0 || data.readUInt16LE(2) !== 1) throw new Error(`${path.relative(project, file)} is not an ICO file.`);
  const count = data.readUInt16LE(4);
  const sizes = [];
  for (let index = 0; index < count; index++) {
    const entry = 6 + index * 16;
    const width = data[entry] || 256;
    const height = data[entry + 1] || 256;
    const byteLength = data.readUInt32LE(entry + 8);
    const offset = data.readUInt32LE(entry + 12);
    if (offset + byteLength > data.length) throw new Error(`${path.relative(project, file)} has an invalid image offset.`);
    const image = await sharp(data.subarray(offset, offset + byteLength)).metadata();
    if (image.format !== 'png' || image.width !== width || image.height !== height) throw new Error(`${path.relative(project, file)} contains an invalid ${width}x${height} image.`);
    sizes.push(width);
  }
  if (sizes.length !== expectedSizes.length || expectedSizes.some((size) => !sizes.includes(size))) {
    throw new Error(`${path.relative(project, file)} must include ${expectedSizes.join(', ')} px entries; got ${sizes.join(', ')}.`);
  }
}

function icnsTypes(file) {
  const data = fs.readFileSync(file);
  if (data.toString('ascii', 0, 4) !== 'icns' || data.readUInt32BE(4) !== data.length) throw new Error(`${path.relative(project, file)} is not a complete ICNS file.`);
  const types = [];
  for (let offset = 8; offset < data.length;) {
    const type = data.toString('ascii', offset, offset + 4);
    const length = data.readUInt32BE(offset + 4);
    if (length < 8 || offset + length > data.length) throw new Error(`${path.relative(project, file)} contains an invalid ${type} entry.`);
    types.push(type);
    offset += length;
  }
  return types;
}

async function verifyMaskablePng(file) {
  const { data, info } = await sharp(file).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const background = [24, 54, 45];
  const center = (info.width - 1) / 2;
  let farthestMark = 0;
  for (let y = 0; y < info.height; y++) {
    for (let x = 0; x < info.width; x++) {
      const offset = (y * info.width + x) * info.channels;
      const pixel = [data[offset], data[offset + 1], data[offset + 2]];
      const isBackground = pixel.every((value, channel) => Math.abs(value - background[channel]) <= 3);
      if (data[offset + 3] !== 0 && !isBackground) {
        farthestMark = Math.max(farthestMark, Math.hypot(x - center, y - center));
      }
    }
  }
  if (farthestMark > info.width * 0.39) {
    throw new Error(`${path.relative(project, file)} artwork escapes the PWA maskable safe circle.`);
  }
}

async function verifyAndroidSafeZone() {
  const vector = fs.readFileSync(path.join(branding, 'android/ic_launcher_foreground.xml'), 'utf8');
  const viewportMatch = vector.match(/android:viewportWidth="([\d.]+)"[^>]*android:viewportHeight="([\d.]+)"/);
  const groupMatch = vector.match(/<group\b[^>]*android:scaleX="([\d.]+)"[^>]*android:scaleY="([\d.]+)"[^>]*android:translateX="([\d.]+)"[^>]*android:translateY="([\d.]+)"/);
  if (!viewportMatch || !groupMatch) throw new Error('Android adaptive foreground needs a measurable centered transform.');
  const viewportWidth = Number(viewportMatch[1]);
  const viewportHeight = Number(viewportMatch[2]);
  const [scaleX, scaleY, translateX, translateY] = groupMatch.slice(1).map(Number);
  const { data, info } = await sharp(path.join(branding, 'symbol-light.svg')).resize(128, 168).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const centerX = viewportWidth / 2;
  const centerY = viewportHeight / 2;
  let farthestMark = 0;
  for (let y = 0; y < info.height; y++) {
    for (let x = 0; x < info.width; x++) {
      const offset = (y * info.width + x) * info.channels;
      if (data[offset + 3] < 16) continue;
      const adaptiveX = x * scaleX + translateX;
      const adaptiveY = y * scaleY + translateY;
      farthestMark = Math.max(farthestMark, Math.hypot(adaptiveX - centerX, adaptiveY - centerY));
    }
  }
  if (farthestMark > 33) throw new Error(`Android adaptive foreground extends ${farthestMark.toFixed(1)} px beyond its 33 px safe radius.`);
}

async function build() {
  writeVectorSources(branding);
  const iconSvg = fs.readFileSync(path.join(branding, 'app-icon.svg'), 'utf8');
  const darkIconSvg = fs.readFileSync(path.join(branding, 'app-icon-dark.svg'), 'utf8');
  const maskableSvg = fs.readFileSync(path.join(branding, 'app-icon-maskable.svg'), 'utf8');
  const faviconSvg = fs.readFileSync(path.join(branding, 'favicon.svg'), 'utf8');
  for (const [source, target] of [
    ['android/ic_launcher_foreground.xml', 'android/app/src/main/res/drawable/ic_launcher_foreground.xml'],
    ['android/ic_launcher_monochrome.xml', 'android/app/src/main/res/drawable/ic_launcher_monochrome.xml'],
    ['android/brand_splash.xml', 'android/app/src/main/res/drawable/brand_splash.xml'],
    ['android/brand_splash_cream.xml', 'android/app/src/main/res/drawable/brand_splash_cream.xml'],
  ]) copy(source, path.join(project, target));
  const iosSizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  for (const size of [48, 72, 96, 144, 192]) {
    await render(iconSvg, path.join(project, `android/app/src/main/res/mipmap-${({48:'mdpi',72:'hdpi',96:'xhdpi',144:'xxhdpi',192:'xxxhdpi'})[size]}/ic_launcher.png`), size);
  }
  for (const [name, size] of Object.entries(iosSizes)) {
    await render(iconSvg, path.join(project, 'ios/Runner/Assets.xcassets/AppIcon.appiconset', name), size);
    await render(iconSvg, path.join(project, 'design/branding/exports/ios', name), size);
  }
  await render(iconSvg, path.join(project, 'design/branding/exports/android/play-store-512.png'), 512);
  await render(iconSvg, path.join(project, 'web/icons/Icon-192.png'), 192);
  await render(iconSvg, path.join(project, 'web/icons/Icon-512.png'), 512);
  await render(maskableSvg, path.join(project, 'web/icons/Icon-maskable-192.png'), 192);
  await render(maskableSvg, path.join(project, 'web/icons/Icon-maskable-512.png'), 512);
  await verifyMaskablePng(path.join(project, 'web/icons/Icon-maskable-512.png'));
  await render(iconSvg, path.join(project, 'web/apple-touch-icon.png'), 180);
  await render(faviconSvg, path.join(project, 'web/favicon.png'), 32);

  const launchLight = await sharp(Buffer.from(fs.readFileSync(path.join(branding, 'symbol-light.svg')))).resize(120, 160, { fit: 'contain' }).png().toBuffer();
  const launchDark = await sharp(Buffer.from(fs.readFileSync(path.join(branding, 'symbol-dark.svg')))).resize(120, 160, { fit: 'contain' }).png().toBuffer();
  const densities = [['mdpi', 1], ['hdpi', 1.5], ['xhdpi', 2], ['xxhdpi', 3], ['xxxhdpi', 4]];
  for (const [density, scale] of densities) {
    for (const [appearance, png] of [['', launchLight], ['-night', launchDark]]) {
      const target = path.join(project, `android/app/src/main/res/drawable${appearance}-${density}/launch_image.png`);
      mkdir(target);
      await sharp(png).resize(Math.round(120 * scale), Math.round(160 * scale), { fit: 'contain' }).png().toFile(target);
    }
  }
  for (const [name, svg] of [
    ['LaunchImage.png', 'symbol-light.svg'], ['LaunchImage@2x.png', 'symbol-light.svg'], ['LaunchImage@3x.png', 'symbol-light.svg'],
    ['LaunchImage-dark.png', 'symbol-dark.svg'], ['LaunchImage-dark@2x.png', 'symbol-dark.svg'], ['LaunchImage-dark@3x.png', 'symbol-dark.svg'],
  ]) {
    const pixels = name.includes('@3x') ? [360, 420] : name.includes('@2x') ? [240, 280] : [120, 140];
    const target = path.join(project, 'ios/Runner/Assets.xcassets/LaunchImage.imageset', name);
    mkdir(target);
    await sharp(path.join(branding, svg)).resize(pixels[0], pixels[1], { fit: 'contain' }).png().toFile(target);
  }

  const icoEntries = [];
  for (const size of [16, 24, 32, 48, 256]) {
    icoEntries.push({ size, png: await sharp(Buffer.from(iconSvg)).resize(size, size).png().toBuffer() });
  }
  const icoPath = path.join(project, 'windows/runner/resources/app_icon.ico');
  mkdir(icoPath);
  fs.writeFileSync(icoPath, pngIco(icoEntries));
  const macSizes = [[16, 'icp4'], [32, 'icp5'], [64, 'icp6'], [128, 'ic07'], [256, 'ic08'], [512, 'ic09'], [1024, 'ic10'], [32, 'ic11'], [64, 'ic12'], [256, 'ic13'], [512, 'ic14']];
  const macChunks = [];
  for (const [size, type] of macSizes) {
    const png = await sharp(Buffer.from(iconSvg)).resize(size, size).png().toBuffer();
    macChunks.push(icnsEntry(type, png));
  }
  const icnsBody = Buffer.concat(macChunks);
  const icns = Buffer.alloc(8 + icnsBody.length);
  icns.write('icns', 0, 4, 'ascii');
  icns.writeUInt32BE(icns.length, 4);
  icnsBody.copy(icns, 8);
  const icnsPath = path.join(project, 'design/branding/exports/macos/LibretApp.icns');
  mkdir(icnsPath);
  fs.writeFileSync(icnsPath, icns);
  await render(iconSvg, path.join(project, 'design/branding/exports/macos/LibretApp-1024.png'), 1024);
  for (const [name, source] of [
    ['background-1024.png', 'macOS/background.svg'],
    ['foreground-1024.png', 'macOS/foreground.svg'],
    ['monochrome-1024.png', 'macOS/monochrome.svg'],
  ]) {
    const svg = fs.readFileSync(path.join(branding, source), 'utf8').replaceAll('currentColor', '#18362D');
    await render(svg, path.join(project, 'design/branding/exports/macos', name), 1024);
  }
  for (const size of [48, 128, 256, 512]) {
    await render(iconSvg, path.join(project, `design/branding/exports/linux/hicolor/${size}x${size}/apps/libretapp.png`), size);
    await render(darkIconSvg, path.join(project, `design/branding/exports/linux/hicolor/${size}x${size}/apps/libretapp-dark.png`), size);
    await render(fs.readFileSync(path.join(branding, 'monochrome.svg'), 'utf8').replaceAll('currentColor', '#2F5D50'), path.join(project, `design/branding/exports/linux/hicolor/${size}x${size}/apps/libretapp-monochrome.png`), size);
  }

  for (const [source, target] of [
    ['symbol-light.svg', 'web/branding/symbol-light.svg'],
    ['symbol-dark.svg', 'web/branding/symbol-dark.svg'],
    ['logo-light.svg', 'web/branding/logo-light.svg'],
    ['logo-dark.svg', 'web/branding/logo-dark.svg'],
    ['favicon.svg', 'web/favicon.svg'],
    ['app-icon.svg', 'design/branding/exports/linux/libretapp.svg'],
    ['app-icon-dark.svg', 'design/branding/exports/linux/libretapp-dark.svg'],
    ['monochrome.svg', 'design/branding/exports/linux/libretapp-symbolic.svg'],
  ]) copy(source, path.join(project, target));

  for (const [appearance, background] of [['light', '#F6F1E8'], ['dark', '#18362D']]) {
    const target = path.join(project, `design/branding/exports/logo-${appearance}.png`);
    mkdir(target);
    await sharp(path.join(branding, `logo-${appearance}.svg`))
      .resize(1280, 336).flatten({ background }).png().toFile(target);
  }

  const faviconEntries = [];
  for (const size of [16, 32, 48]) {
    faviconEntries.push({ size, png: await sharp(Buffer.from(faviconSvg)).resize(size, size).png().toBuffer() });
  }
  const ico = pngIco(faviconEntries);
  const faviconIco = path.join(project, 'web/favicon.ico');
  mkdir(faviconIco);
  fs.writeFileSync(faviconIco, ico);

  for (const [file, size] of [
    [path.join(project, 'design/branding/exports/android/play-store-512.png'), 512],
    [path.join(project, 'web/icons/Icon-192.png'), 192],
    [path.join(project, 'web/icons/Icon-512.png'), 512],
    [path.join(project, 'web/icons/Icon-maskable-192.png'), 192],
    [path.join(project, 'web/icons/Icon-maskable-512.png'), 512],
    [path.join(project, 'web/apple-touch-icon.png'), 180],
  ]) {
    await verifyPng(file, size);
  }
  console.log('Generated Android, iOS, Windows, web, macOS and Linux brand assets.');
}

if (process.argv.includes('--check')) {
  const iosContents = JSON.parse(fs.readFileSync(path.join(project, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json')));
  const webManifest = JSON.parse(fs.readFileSync(path.join(project, 'web/manifest.json')));
  const sourceFiles = ['symbol-light.svg', 'symbol-dark.svg', 'logo-light.svg', 'logo-dark.svg', 'monochrome.svg', 'favicon.svg', 'app-icon.svg', 'app-icon-dark.svg', 'app-icon-maskable.svg'];
  Promise.all(sourceFiles.map(async (file) => {
    const result = await sharp(path.join(branding, file)).metadata();
    if (result.format !== 'svg' || !result.width || !result.height) throw new Error(`${file} is not a renderable SVG.`);
  })).then(async () => {
    verifyVectorSources(branding);
    await verifyAndroidSafeZone();
    for (const [density, size] of [['mdpi', 48], ['hdpi', 72], ['xhdpi', 96], ['xxhdpi', 144], ['xxxhdpi', 192]]) {
      await verifyPng(path.join(project, `android/app/src/main/res/mipmap-${density}/ic_launcher.png`), size);
    }
    const iosDirectory = path.join(project, 'ios/Runner/Assets.xcassets/AppIcon.appiconset');
    for (const { filename, size, scale } of iosContents.images) {
      const pixels = Math.round(Number.parseFloat(size) * Number.parseInt(scale, 10));
      const iconPath = path.join(iosDirectory, filename);
      await verifyPng(iconPath, pixels);
      await verifyOpaquePng(iconPath);
    }
    for (const icon of webManifest.icons) {
      const iconPath = path.join(project, 'web', icon.src);
      const iconSize = Number.parseInt(icon.sizes.split(' ')[0], 10);
      await verifyPng(iconPath, iconSize);
      if (icon.purpose === 'maskable') await verifyMaskablePng(iconPath);
    }
    for (const [file, expected] of [
      ['windows/runner/resources/app_icon.ico', [16, 24, 32, 48, 256]],
      ['web/favicon.ico', [16, 32, 48]],
    ]) {
      const fullPath = path.join(project, file);
      if (!fs.existsSync(fullPath) || fs.statSync(fullPath).size < 128) throw new Error(`${file} is missing or incomplete.`);
      await verifyIco(fullPath, expected);
    }
    const icnsPath = path.join(project, 'design/branding/exports/macos/LibretApp.icns');
    const expectedIcns = ['icp4', 'icp5', 'icp6', 'ic07', 'ic08', 'ic09', 'ic10', 'ic11', 'ic12', 'ic13', 'ic14'];
    const actualIcns = icnsTypes(icnsPath);
    if (expectedIcns.some((type) => !actualIcns.includes(type))) throw new Error(`macOS ICNS is missing entries: ${expectedIcns.filter((type) => !actualIcns.includes(type)).join(', ')}.`);
    await verifyPng(path.join(project, 'design/branding/exports/macos/LibretApp-1024.png'), 1024);
    for (const name of ['background-1024.png', 'foreground-1024.png', 'monochrome-1024.png']) await verifyPng(path.join(project, 'design/branding/exports/macos', name), 1024);
    for (const size of [48, 128, 256, 512]) {
      for (const variant of ['libretapp', 'libretapp-dark', 'libretapp-monochrome']) await verifyPng(path.join(project, `design/branding/exports/linux/hicolor/${size}x${size}/apps/${variant}.png`), size);
    }
    console.log('Brand SVGs, opaque iOS catalog, Play/PWA sizes, Android/PWA safe zones, ICO entries, ICNS and macOS PNG layers are valid.');
  }).catch((error) => { console.error(error); process.exitCode = 1; });
} else {
  build().catch((error) => { console.error(error); process.exitCode = 1; });
}
