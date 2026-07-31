"""Import the three authored directional seed-slime run GIFs."""

from __future__ import annotations

import json
import shutil
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image, ImageSequence


CANVAS_SIZE = 64
GROUND_Y = 58
SOURCES = {
    "run_side": Path(
        r"C:\Users\lijc\Downloads\job_aae7475f3ebc4744a986fec822db2bd7-transparent.gif"
    ),
    "run_up": Path(
        r"C:\Users\lijc\Downloads\job_cca2a787a8d64c0fb0c37278b629e50a-transparent.gif"
    ),
    "run_down": Path(
        r"C:\Users\lijc\Downloads\job_327d57769a6043bd94c540337c5c2606-transparent.gif"
    ),
}


def normalize_gif(path: Path) -> tuple[list[Image.Image], list[int]]:
    image = Image.open(path)
    source_frames = [frame.convert("RGB") for frame in ImageSequence.Iterator(image)]
    durations = [
        max(int(frame.info.get("duration", image.info.get("duration", 100))), 1)
        for frame in ImageSequence.Iterator(image)
    ]
    background = Counter(
        pixel for frame in source_frames for pixel in frame.getdata()
    ).most_common(1)[0][0]
    background_array = np.asarray(background, dtype=np.uint8)
    output: list[Image.Image] = []
    for source in source_frames:
        rgb = np.asarray(source, dtype=np.uint8)
        mask = np.any(rgb != background_array, axis=2)
        ys, xs = np.nonzero(mask)
        if xs.size == 0:
            output.append(Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE)))
            continue
        left = max(int(xs.min()) - 1, 0)
        top = max(int(ys.min()) - 1, 0)
        right = min(int(xs.max()) + 2, source.width)
        bottom = min(int(ys.max()) + 2, source.height)
        rgba = np.zeros((source.height, source.width, 4), dtype=np.uint8)
        rgba[..., :3] = rgb
        rgba[..., 3] = np.where(mask, 255, 0).astype(np.uint8)
        crop = Image.fromarray(rgba, "RGBA").crop((left, top, right, bottom))
        if crop.width > CANVAS_SIZE - 4 or crop.height > CANVAS_SIZE - 4:
            scale = min(
                (CANVAS_SIZE - 4) / crop.width,
                (CANVAS_SIZE - 4) / crop.height,
            )
            crop = crop.resize(
                (max(1, round(crop.width * scale)), max(1, round(crop.height * scale))),
                Image.Resampling.NEAREST,
            )
        canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
        canvas.alpha_composite(
            crop,
            ((CANVAS_SIZE - crop.width) // 2, GROUND_Y - crop.height),
        )
        output.append(canvas)
    return output, durations


def write_animation(root: Path, name: str, source: Path) -> None:
    frames, durations = normalize_gif(source)
    destination = root / name
    destination.mkdir(parents=True, exist_ok=True)
    sheet = Image.new(
        "RGBA",
        (CANVAS_SIZE * len(frames), CANVAS_SIZE),
        (0, 0, 0, 0),
    )
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * CANVAS_SIZE, 0))
    sheet.save(destination / f"{name}.png")
    metadata = {
        "frame_count": len(frames),
        "frame_size": [CANVAS_SIZE, CANVAS_SIZE],
        "durations_ms": durations,
        "loop": True,
        "ground_anchor_y": GROUND_Y,
        "source": f"source/{source.name}",
    }
    (destination / "metadata.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    source_copy = root / "source" / source.name
    source_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, source_copy)
    print(f"Imported {name}: {len(frames)} frames")


def main() -> None:
    root = (
        Path(__file__).resolve().parents[1]
        / "assets"
        / "sprites"
        / "player"
        / "seed_slime"
        / "v1"
    )
    for name, source in SOURCES.items():
        if not source.exists():
            raise FileNotFoundError(source)
        write_animation(root, name, source)


if __name__ == "__main__":
    main()
