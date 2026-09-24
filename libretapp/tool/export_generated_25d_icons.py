"""Normalize generated 2.5D masters and export production WEBPs.

Some image-generation results contain a rendered grey transparency grid rather
than an alpha channel.  Those grids are neutral grey, while the approved icon
palette is deliberately chromatic.  The cleanup below derives alpha only for
RGB inputs; masters that already contain transparency keep their original
alpha untouched.
"""

from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "icons_25d_source"
LOCATION_SOURCE = SOURCE / "locations"
DESTINATION = ROOT / "assets" / "images"
CATALOG_PREFIXES = ("crop_", "health_", "inventory_", "record_", "status_", "task_")
EXPECTED_FAMILIES = {
    "crop": 8,
    "health": 8,
    "inventory": 8,
    "record": 17,
    "status": 13,
    "task": 10,
}
GRID_CONTAMINATED_MASTERS = {
    "record_cost.png",
    "record_crop_health.png",
    "status_canceled.png",
    "status_overdue.png",
}
EXPECTED_LOCATION_NAMES = {
    "location_macro", "location_livestock", "location_handling",
    "location_agricultural", "location_natural", "location_infrastructure",
    "location_water", "location_ranch", "location_farm", "location_finca",
    "location_hacienda", "location_plantation", "location_ejido",
    "location_property", "location_homestead", "location_pasture",
    "location_corral", "location_feedlot", "location_barn", "location_stable",
    "location_pen", "location_chute", "location_quarantine_area",
    "location_loading_area", "location_weighing_area", "location_field",
    "location_plot", "location_milpa", "location_orchard",
    "location_greenhouse", "location_nursery", "location_garden",
    "location_monte", "location_forest", "location_lagoon", "location_river",
    "location_wetland", "location_protected_area", "location_warehouse",
    "location_workshop", "location_office", "location_house", "location_road",
    "location_water_tank", "location_gate", "location_well", "location_dam",
    "location_spring", "location_pond", "location_aguada", "location_trough",
    "location_canal", "location_reservoir",
}


def remove_rendered_transparency_grid(
    image: Image.Image, *, threshold: int = 6
) -> Image.Image:
    red, green, blue = image.convert("RGB").split()
    maximum = ImageChops.lighter(ImageChops.lighter(red, green), blue)
    minimum = ImageChops.darker(ImageChops.darker(red, green), blue)
    chroma = ImageChops.subtract(maximum, minimum)

    # Generated checkerboards are neutral (border chroma <= 6). Palette colors
    # reach full opacity at chroma 16, with a short ramp for anti-aliased edges.
    alpha_image = chroma.point(
        lambda value: max(0, min(255, (value - threshold) * 26))
    ).filter(ImageFilter.GaussianBlur(radius=0.45))

    rgba = image.convert("RGBA")
    if "A" in image.getbands():
        alpha_image = ImageChops.darker(image.getchannel("A"), alpha_image)
    rgba.putalpha(alpha_image)
    return rgba


def normalize_master(path: Path, *, force_cleanup: bool = False) -> Image.Image:
    with Image.open(path) as opened:
        image = opened.copy()

    has_alpha = "A" in image.getbands()
    border_has_content = False
    if has_alpha:
        alpha = image.getchannel("A")
        border_has_content = any(
            value > 0
            for value in (
                alpha.getpixel((0, 0)),
                alpha.getpixel((image.width - 1, 0)),
                alpha.getpixel((0, image.height - 1)),
                alpha.getpixel((image.width - 1, image.height - 1)),
            )
        )

    if not has_alpha or border_has_content or force_cleanup:
        image = remove_rendered_transparency_grid(
            image, threshold=14 if force_cleanup else 6
        )
        alpha = image.getchannel("A")
        draw = ImageDraw.Draw(alpha)
        draw.rectangle((0, 0, image.width - 1, 3), fill=0)
        draw.rectangle((0, image.height - 4, image.width - 1, image.height - 1), fill=0)
        draw.rectangle((0, 0, 3, image.height - 1), fill=0)
        draw.rectangle((image.width - 4, 0, image.width - 1, image.height - 1), fill=0)
        image.putalpha(alpha)
        temporary = path.with_suffix(".normalized.png")
        image.save(temporary, format="PNG", optimize=False)
        temporary.replace(path)
    else:
        image = image.convert("RGBA")
    return image


def fit_icon(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    # Ignore nearly invisible remnants left by generated checkerboards when
    # calculating visual size. The original soft edge remains in the crop.
    visible_alpha = alpha.point(lambda value: 255 if value >= 128 else 0)
    bbox = visible_alpha.getbbox()
    if bbox is None:
        raise ValueError("master is fully transparent")

    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    padding = round(max(width, height) * 0.04)
    bbox = (
        max(0, bbox[0] - padding),
        max(0, bbox[1] - padding),
        min(image.width, bbox[2] + padding),
        min(image.height, bbox[3] + padding),
    )
    cropped = image.crop(bbox)
    # Keep 11% clear space around the visible shape and center every silhouette.
    max_side = 202
    scale = min(max_side / cropped.width, max_side / cropped.height)
    size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((256 - size[0]) // 2, (256 - size[1]) // 2))
    return canvas


def export_files(files: list[Path], *, catalog: bool) -> None:
    for path in files:
        master = normalize_master(
            path,
            force_cleanup=catalog and path.name in GRID_CONTAMINATED_MASTERS,
        )
        exported = fit_icon(master)
        destination = DESTINATION / f"{path.stem}.webp"
        temporary = destination.with_suffix(".export.webp")
        exported.save(temporary, format="WEBP", lossless=True, method=0)
        temporary.replace(destination)


def catalog_files() -> list[Path]:
    files = sorted(SOURCE.glob("*.png"))
    family_counts = Counter(path.stem.split("_", 1)[0] for path in files)
    if len(files) != 64 or dict(family_counts) != EXPECTED_FAMILIES:
        raise RuntimeError(
            f"Expected 64 masters with {EXPECTED_FAMILIES}, found "
            f"{len(files)} with {dict(family_counts)}"
        )

    for path in files:
        if not path.stem.startswith(CATALOG_PREFIXES):
            raise RuntimeError(f"Unexpected catalog master: {path.name}")
    return files


def location_files() -> list[Path]:
    files = sorted(LOCATION_SOURCE.glob("location_*.png"))
    names = {path.stem for path in files}
    if names != EXPECTED_LOCATION_NAMES:
        missing = sorted(EXPECTED_LOCATION_NAMES - names)
        unexpected = sorted(names - EXPECTED_LOCATION_NAMES)
        raise RuntimeError(
            f"Expected 53 location masters; missing={missing}, unexpected={unexpected}"
        )
    return files


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--scope",
        choices=("catalog", "locations", "all"),
        default="all",
        help="Asset group to validate, normalize, and export.",
    )
    args = parser.parse_args()

    exported = []
    if args.scope in {"catalog", "all"}:
        files = catalog_files()
        export_files(files, catalog=True)
        exported.append(f"{len(files)} catalog")
    if args.scope in {"locations", "all"}:
        files = location_files()
        export_files(files, catalog=False)
        exported.append(f"{len(files)} locations")

    print(f"Normalized and exported {' + '.join(exported)} 2.5D icons at 256x256.")


if __name__ == "__main__":
    main()
