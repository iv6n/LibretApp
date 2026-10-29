// Reuse the approved vector identity; no screenshots or product claims invented.
const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('./branding/node_modules/sharp');
const root = path.resolve(__dirname, '..');
async function main() {
  const out = path.join(root, 'docs/publicacion-connected/assets');
  await fs.mkdir(out, { recursive: true });
  const background = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="500">
    <rect width="1024" height="500" fill="#F6F1E8"/>
    <path d="M700 0H1024V500H700Z" fill="#18362D"/>
    <text x="64" y="255" font-family="Arial,sans-serif" font-size="45" font-weight="700" fill="#18362D">Tu libreta de campo.</text>
    <text x="67" y="312" font-family="Arial,sans-serif" font-size="23" fill="#2F5D50">Registros, fotografías y respaldos</text>
    <text x="67" y="409" font-family="Arial,sans-serif" font-size="16" letter-spacing="3" fill="#7B4B2A">MÉXICO · ANDROID</text>
    <rect x="765" y="105" width="180" height="280" rx="18" fill="#F6F1E8"/>
    <rect x="751" y="105" width="24" height="280" rx="10" fill="#2F5D50"/>
    <path d="M800 165H907M800 205H907M800 245H907M800 285H870" stroke="#BBCBBC" stroke-width="4"/>
    <path d="M891 106V192L908 179L925 192V106" fill="#7B4B2A"/>
  </svg>`);
  const logo = await sharp(path.join(root, 'assets/branding/logo-light.svg')).resize(320).png().toBuffer();
  await sharp(background).composite([{input: logo, left:64, top:68}]).png()
    .toFile(path.join(out, 'feature-graphic-1024x500.png'));
  await fs.copyFile(path.join(root,'design/branding/exports/android/play-store-512.png'), path.join(out,'icon-512.png'));
  console.log(out);
}
main().catch(e => { console.error(e.message); process.exitCode=1; });
