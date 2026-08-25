"""Create size-bounded WebP copies of LibretApp's UI raster assets."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageOps


def optimize(source: Path, destination: Path, max_size: int, quality: int) -> int:
    destination.mkdir(parents=True, exist_ok=True)
    written = 0

    for input_path in sorted(source.glob("*.png")):
        output_path = destination / f"{input_path.stem}.webp"
        with Image.open(input_path) as original:
            image = ImageOps.exif_transpose(original)
            image = image.convert("RGBA" if "A" in image.getbands() else "RGB")
            if max(image.size) > max_size:
                image.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
            image.save(output_path, "WEBP", quality=quality, method=4)
        written += 1

    return written


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--max-size", type=int, default=256)
    parser.add_argument("--quality", type=int, default=90)
    args = parser.parse_args()

    count = optimize(args.source, args.destination, args.max_size, args.quality)
    source_bytes = sum(path.stat().st_size for path in args.source.glob("*.png"))
    destination_bytes = sum(path.stat().st_size for path in args.destination.glob("*.webp"))
    print(f"Optimized {count} images")
    print(f"PNG: {source_bytes / 1024 / 1024:.2f} MB")
    print(f"WebP: {destination_bytes / 1024 / 1024:.2f} MB")


if __name__ == "__main__":
    main()
