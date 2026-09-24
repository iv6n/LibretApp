"""Legacy SVG generator retained for historical reference.

Production assets now come from the generated PNG masters in
``assets/icons_25d_source`` and are exported with
``tool/export_generated_25d_icons.py``. This script is intentionally not part
of the production pipeline.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "icons_2d"

GRADIENTS = """\
<defs>
  <linearGradient id="gGreen" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#71947E"/><stop offset="0.52" stop-color="#547663"/><stop offset="1" stop-color="#3F6551"/>
  </linearGradient>
  <linearGradient id="gTerra" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#E18B5F"/><stop offset="0.52" stop-color="#C66B45"/><stop offset="1" stop-color="#A95436"/>
  </linearGradient>
  <linearGradient id="gGold" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#F2C765"/><stop offset="0.52" stop-color="#DAA54A"/><stop offset="1" stop-color="#B9822E"/>
  </linearGradient>
  <linearGradient id="gCream" gradientUnits="userSpaceOnUse" x1="18" y1="16" x2="95" y2="112">
    <stop offset="0" stop-color="#FFF7E7"/><stop offset="0.58" stop-color="#EAD8B8"/><stop offset="1" stop-color="#D4BE99"/>
  </linearGradient>
  <linearGradient id="gPaper" gradientUnits="userSpaceOnUse" x1="20" y1="18" x2="98" y2="110">
    <stop offset="0" stop-color="#FFFDF3"/><stop offset="0.62" stop-color="#FFF5DF"/><stop offset="1" stop-color="#E9D9B8"/>
  </linearGradient>
  <linearGradient id="gBlue" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#A4C2C3"/><stop offset="0.56" stop-color="#7E9DA2"/><stop offset="1" stop-color="#5D858B"/>
  </linearGradient>
  <linearGradient id="gMuted" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#B2C0A8"/><stop offset="1" stop-color="#90A18A"/>
  </linearGradient>
  <linearGradient id="gDark" gradientUnits="userSpaceOnUse" x1="18" y1="18" x2="108" y2="108">
    <stop offset="0" stop-color="#3E5C4B"/><stop offset="1" stop-color="#263E33"/>
  </linearGradient>
  <filter id="contactShadow" x="-30%" y="-30%" width="160%" height="175%">
    <feDropShadow dx="1.4" dy="3" stdDeviation="2.2" flood-color="#263E33" flood-opacity=".22"/>
  </filter>
</defs>
"""

COLOR_TO_GRADIENT = {
    "#547663": "url(#gGreen)",
    "#345848": "url(#gDark)",
    "#C66B45": "url(#gTerra)",
    "#DAA54A": "url(#gGold)",
    "#EAD8B8": "url(#gCream)",
    "#FFF5DF": "url(#gPaper)",
    "#7E9DA2": "url(#gBlue)",
    "#90A18A": "url(#gMuted)",
    "#263E33": "url(#gDark)",
}


def apply_25d(source: str) -> str:
    if 'id="contactShadow"' in source:
        cleaned = source.replace(
            '<desc>Ilustración 2.5D con degradados cortos, sombra suave y brillo puntual.</desc>',
            '<desc>Ilustración 2.5D con degradados cortos, sombra suave y brillo integrado.</desc>',
        ).replace(
            '<path d="M27 28c15-11 32-14 49-10" stroke="#FFFFFF" stroke-width="3.5" stroke-linecap="round" opacity=".20"/>',
            '',
        )
        for color, gradient in COLOR_TO_GRADIENT.items():
            cleaned = cleaned.replace(f'stroke="{color}"', f'stroke="{gradient}"')
        return cleaned
    title_end = source.find("</title>")
    svg_end = source.rfind("</svg>")
    if title_end < 0 or svg_end < 0:
        raise ValueError("SVG is missing title or closing tag")
    head = source[: title_end + len("</title>")]
    body = source[title_end + len("</title>") : svg_end]
    for color, gradient in COLOR_TO_GRADIENT.items():
        body = body.replace(f'fill="{color}"', f'fill="{gradient}"')
        body = body.replace(f'stroke="{color}"', f'stroke="{gradient}"')
    # The bright first stop in each gradient acts as the highlight. A
    # floating overlay would sit outside irregular silhouettes, so highlights
    # stay embedded in the surfaces rather than being drawn at fixed coords.
    highlight = ""
    return (
        f"{head}\n{GRADIENTS}"
        '<desc>Ilustración 2.5D con degradados cortos, sombra suave y brillo integrado.</desc>\n'
        f'<g filter="url(#contactShadow)">{body}{highlight}</g>\n</svg>\n'
    )


def main() -> None:
    files = sorted(SOURCE.glob("*.svg"))
    if len(files) != 64:
        raise RuntimeError(f"Expected 64 icon sources, found {len(files)}")
    for file in files:
        file.write_text(apply_25d(file.read_text(encoding="utf-8")), encoding="utf-8")
    print(f"Applied 2.5D gradients, contact shadows, and highlights to {len(files)} SVG icons.")


if __name__ == "__main__":
    main()
