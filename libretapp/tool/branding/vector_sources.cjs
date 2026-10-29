const fs = require('node:fs');
const path = require('node:path');

// A single set of traced outlines keeps Flutter, native launchers and exports
// faithful to the approved reference. All lettering remains vector artwork.
function vectorSources(branding) {
  const artwork = JSON.parse(fs.readFileSync(path.join(branding, 'artwork.json'), 'utf8'));
  const forest = '#2F5D50';
  const cream = '#F6F1E8';
  const leather = '#7B4B2A';
  const deep = '#18362D';
  const paths = (parts, ink, bookmark = ink) => parts.map(({ id, d }) =>
    `    <path id="${id}" fill="${id === 'bookmark' ? bookmark : ink}" fill-rule="evenodd" d="${d}"/>`).join('\n');
  const symbol = (ink, bookmark = leather) => paths(artwork.symbol, ink, bookmark);
  const svg = (viewBox, body, label = 'LibretApp') =>
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" role="img" aria-label="${label}">\n${body}\n</svg>\n`;
  const logo = (dark) => svg(artwork.logoViewBox,
    `${dark ? '' : '  <defs>\n    <linearGradient id="wordmark-ink" gradientUnits="userSpaceOnUse" x1="147" y1="39" x2="635" y2="143">\n      <stop stop-color="#2F5D50"/>\n      <stop offset="1" stop-color="#285246"/>\n    </linearGradient>\n  </defs>\n'}  <g id="symbol">\n${symbol(dark ? cream : forest, dark ? '#B08968' : leather)}\n  </g>\n  <g id="wordmark">\n${paths(artwork.wordmark, dark ? cream : 'url(#wordmark-ink)')}\n  </g>`);
  const iconBody = (dark, background = true) => {
    const ink = dark ? forest : cream;
    const shadow = dark ? '#E2D9CB' : '#153329';
    const cover = artwork.symbol.find(({ id }) => id === 'cover').d;
    return `${background ? `  <rect width="512" height="512" fill="${dark ? cream : deep}"/>\n` : ''}  <g transform="translate(94 47) scale(2.48)">\n    <path fill="${shadow}" fill-rule="evenodd" d="${cover}" transform="translate(2 2)"/>\n${symbol(ink)}\n  </g>`;
  };
  const android = (ink, bookmark, adaptive = false, splash = false) => {
    const body = artwork.symbol.map(({ id, d }) =>
      `    <path android:fillColor="${id === 'bookmark' ? bookmark : ink}" android:fillType="evenOdd" android:pathData="${d}" />`).join('\n');
    return `<?xml version="1.0" encoding="utf-8"?>\n<vector xmlns:android="http://schemas.android.com/apk/res/android"\n    android:width="${adaptive || splash ? 108 : 120}dp"\n    android:height="${adaptive || splash ? 108 : 160}dp"\n    android:viewportWidth="${adaptive || splash ? 108 : 128}"\n    android:viewportHeight="${adaptive || splash ? 108 : 168}">\n${adaptive ? `    <group android:scaleX="0.35" android:scaleY="0.35" android:translateX="31.6" android:translateY="24.6">\n${body}\n    </group>` : splash ? `    <group android:scaleX="0.35" android:scaleY="0.35" android:translateX="41.6" android:translateY="25.6">\n${body}\n    </group>` : body}\n</vector>\n`;
  };
  return {
    'symbol-light.svg': svg(artwork.symbolViewBox, symbol(forest)),
    'symbol-dark.svg': svg(artwork.symbolViewBox, symbol(cream, '#B08968')),
    'logo-light.svg': logo(false),
    'logo-dark.svg': logo(true),
    'monochrome.svg': svg(artwork.symbolViewBox, symbol('currentColor', 'currentColor')),
    'app-icon.svg': svg('0 0 512 512', iconBody(false)),
    'app-icon-dark.svg': svg('0 0 512 512', iconBody(true)),
    'app-icon-maskable.svg': svg('0 0 512 512', `  <rect width="512" height="512" fill="${deep}"/>\n  <g transform="translate(138 99) scale(1.85)">\n${symbol(cream)}\n  </g>`),
    'favicon.svg': svg('0 0 128 128', `  <rect width="128" height="128" rx="27" fill="${cream}"/>\n  <g transform="translate(9 -1) scale(.86)">\n${paths(artwork.symbol.filter(({ id }) => id !== 'bookmark'), forest)}\n  </g>`),
    'macOS/foreground.svg': svg('0 0 512 512', iconBody(false, false)),
    'macOS/monochrome.svg': svg(artwork.symbolViewBox, symbol('currentColor', 'currentColor')),
    'android/ic_launcher_foreground.xml': android(cream, leather, true),
    'android/ic_launcher_monochrome.xml': android('#FFFFFFFF', '#FFFFFFFF', true),
    'android/brand_splash.xml': android(forest, leather, false, true),
    'android/brand_splash_cream.xml': android(cream, '#B08968', false, true),
  };
}

function writeVectorSources(branding) {
  for (const [name, source] of Object.entries(vectorSources(branding))) {
    const target = path.join(branding, name);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, source);
  }
}

function verifyVectorSources(branding) {
  for (const [name, expected] of Object.entries(vectorSources(branding))) {
    const actual = fs.readFileSync(path.join(branding, name), 'utf8').replaceAll('\r\n', '\n');
    if (actual !== expected) throw new Error(`${name} differs from artwork.json; regenerate the brand assets.`);
  }
}

module.exports = { writeVectorSources, verifyVectorSources };
