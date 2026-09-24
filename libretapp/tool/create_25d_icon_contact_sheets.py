"""Create light, dark, and 24 px review sheets for the 2.5D WEBPs."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "images"
OUTPUT = ROOT / "docs" / "design" / "icons-25d-v2"
PREFIXES = ("crop_", "health_", "inventory_", "record_", "status_", "task_")


def font(size: int) -> ImageFont.ImageFont:
    try:
        return ImageFont.truetype("arial.ttf", size)
    except OSError:
        return ImageFont.load_default()


def files_for_scope(scope: str) -> list[Path]:
    if scope == "catalog":
        files = sorted(
            path for path in SOURCE.glob("*.webp")
            if path.stem.startswith(PREFIXES)
        )
        expected = 64
    else:
        files = sorted(SOURCE.glob("location_*.webp"))
        expected = 53
    if len(files) != expected:
        raise RuntimeError(f"Expected {expected} {scope} icons, found {len(files)}")
    return files


def create_sheet(
    files: list[Path], name: str, background: str, card: str, text: str
) -> None:

    cell = 164
    margin = 22
    rows = (len(files) + 7) // 8
    sheet = Image.new("RGB", (cell * 8, cell * rows), background)
    draw = ImageDraw.Draw(sheet)
    label_font = font(12)

    for index, path in enumerate(files):
        column, row = index % 8, index // 8
        x, y = column * cell, row * cell
        draw.rounded_rectangle(
            (x + 8, y + 8, x + cell - 8, y + cell - 8),
            radius=20,
            fill=card,
        )
        with Image.open(path) as opened:
            icon = opened.convert("RGBA").resize((112, 112), Image.Resampling.LANCZOS)
        sheet.paste(icon, (x + 26, y + 15), icon)
        label = path.stem.replace("_", " ")
        box = draw.textbbox((0, 0), label, font=label_font)
        draw.text(
            (x + (cell - (box[2] - box[0])) / 2, y + cell - margin - 5),
            label,
            fill=text,
            font=label_font,
        )

    sheet.save(OUTPUT / name, optimize=True)


def create_small_size_sheet(files: list[Path], name: str) -> None:
    cell = 40
    rows = (len(files) + 7) // 8
    sheet = Image.new("RGB", (cell * 8, cell * rows), "#FFFDF8")
    for index, path in enumerate(files):
        column, row = index % 8, index // 8
        with Image.open(path) as opened:
            icon = opened.convert("RGBA").resize((24, 24), Image.Resampling.LANCZOS)
        sheet.paste(icon, (column * cell + 8, row * cell + 8), icon)
    sheet.save(OUTPUT / name, optimize=True)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    catalog = files_for_scope("catalog")
    locations = files_for_scope("locations")
    create_sheet(catalog, "catalogo-64-claro.png", "#EFE7D8", "#FFFDF8", "#263E33")
    create_sheet(catalog, "catalogo-64-oscuro.png", "#1F3029", "#2C4137", "#FFF5DF")
    create_small_size_sheet(catalog, "catalogo-64-24px.png")
    create_sheet(locations, "ubicaciones-53-claro.png", "#EFE7D8", "#FFFDF8", "#263E33")
    create_sheet(locations, "ubicaciones-53-oscuro.png", "#1F3029", "#2C4137", "#FFF5DF")
    create_small_size_sheet(locations, "ubicaciones-53-24px.png")
    print("Created light, dark, and 24 px sheets for 64 catalog and 53 location icons.")


if __name__ == "__main__":
    main()
