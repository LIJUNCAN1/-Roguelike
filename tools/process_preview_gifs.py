"""Convert the supplied preview GIF recordings into editable sprite assets.

The recordings are 4x nearest-neighbour previews with a static background,
watermark, guides, and a vertically mirrored floor reflection.  This tool
uses temporal background subtraction instead of colour-keying so pale hair
and effects remain intact.
"""

from __future__ import annotations

import argparse
import json
import shutil
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image


NATIVE_SCALE = 4
CANVAS_SIZE = 64
SOURCE_GROUND_Y = 121
CANVAS_GROUND_Y = 58


@dataclass(frozen=True)
class ActionSpec:
    name: str
    display_name: str
    source_name: str
    start: int
    end: int
    loop: bool


ACTIONS = (
    ActionSpec("jump", "跳跃", "C6oVJk.gif", 0, 36, False),
    ActionSpec("slide", "滑铲", "Up1c5H.gif", 0, 27, False),
    ActionSpec("dodge", "闪避", "807UP_.gif", 0, 44, False),
    ActionSpec("hurt", "受击", "LsOtsR.gif", 0, 36, False),
    ActionSpec(
        "knockdown",
        "击倒恢复",
        "LsOtsR.gif",
        36,
        88,
        False,
    ),
    ActionSpec("heal", "回复技能", "LsOtsR.gif", 88, 104, False),
    ActionSpec(
        "run_start",
        "跑动起步",
        "Lvldg_.gif",
        60,
        78,
        False,
    ),
    ActionSpec(
        "run_loop",
        "跑动循环",
        "Lvldg_.gif",
        78,
        98,
        True,
    ),
    ActionSpec(
        "run_stop",
        "跑动收步",
        "Lvldg_.gif",
        158,
        176,
        False,
    ),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=Path(r"C:\Users\lijc\Downloads"),
    )
    parser.add_argument(
        "--external-output",
        type=Path,
        default=Path(r"D:\game1\素材\sample\preview_character"),
    )
    parser.add_argument(
        "--project-output",
        type=Path,
        default=(
            Path(__file__).resolve().parents[1]
            / "assets"
            / "sprites"
            / "player"
            / "preview_character"
            / "v1"
        ),
    )
    return parser.parse_args()


def load_gif(path: Path) -> tuple[list[np.ndarray], list[int]]:
    image = Image.open(path)
    expected_size = (
        image.width // NATIVE_SCALE,
        image.height // NATIVE_SCALE,
    )
    frames: list[np.ndarray] = []
    durations: list[int] = []
    for frame_index in range(image.n_frames):
        image.seek(frame_index)
        frame = image.convert("RGB").resize(
            expected_size,
            Image.Resampling.NEAREST,
        )
        frames.append(np.asarray(frame, dtype=np.uint8).copy())
        durations.append(max(int(image.info.get("duration", 50)), 1))
    return frames, durations


def packed_rgb(frames: list[np.ndarray]) -> np.ndarray:
    values = np.stack(frames).astype(np.uint32)
    return (
        (values[..., 0] << 16)
        | (values[..., 1] << 8)
        | values[..., 2]
    )


def temporal_mode(
    packed_frames: np.ndarray,
) -> tuple[np.ndarray, np.ndarray]:
    sorted_values = np.sort(packed_frames, axis=0)
    current_value = sorted_values[0].copy()
    current_count = np.ones(current_value.shape, dtype=np.uint16)
    best_value = current_value.copy()
    best_count = current_count.copy()
    for index in range(1, sorted_values.shape[0]):
        same = sorted_values[index] == current_value
        current_count = np.where(same, current_count + 1, 1)
        current_value = np.where(same, current_value, sorted_values[index])
        better = current_count > best_count
        best_count = np.where(better, current_count, best_count)
        best_value = np.where(better, current_value, best_value)
    return best_value, best_count


def build_backgrounds(
    gif_frames: dict[str, list[np.ndarray]],
) -> dict[str, np.ndarray]:
    backgrounds: dict[str, np.ndarray] = {}
    for source_name, frames in gif_frames.items():
        packed = packed_rgb(frames)
        values, counts = np.unique(packed, return_counts=True)
        base_colour = values[int(np.argmax(counts))]
        # The preview background is a perfectly flat colour.  A constant
        # background prevents a long-held character pose from leaking into
        # a temporal background estimate.
        backgrounds[source_name] = np.full(
            packed.shape[1:],
            base_colour,
            dtype=np.uint32,
        )
    return backgrounds


def source_palette(
    frame: np.ndarray,
    background: np.ndarray,
) -> set[int]:
    packed = packed_rgb([frame])[0]
    mask = frame_mask(frame, background)
    return set(int(value) for value in packed[mask])


def frame_mask(
    frame: np.ndarray,
    background: np.ndarray,
) -> np.ndarray:
    packed = packed_rgb([frame])[0]
    mask = packed != background
    red = frame[..., 0].astype(np.int16)
    green = frame[..., 1].astype(np.int16)
    blue = frame[..., 2].astype(np.int16)
    preview_overlay = (
        (red >= 118)
        & (red <= 215)
        & (green >= 105)
        & (green <= 205)
        & (blue >= 88)
        & (blue <= 195)
        & (red >= green)
        & (green >= blue)
        & ((red - blue) <= 48)
    )
    mask &= ~preview_overlay
    mask[SOURCE_GROUND_Y + 1 :, :] = False
    return mask


def estimate_actor_x(
    frame: np.ndarray,
    mask: np.ndarray,
    base_palette: set[int],
) -> float:
    packed = packed_rgb([frame])[0]
    palette_values = np.fromiter(base_palette, dtype=np.uint32)
    current_body = mask & np.isin(packed, palette_values)

    red = (
        current_body
        & (frame[..., 0] >= 105)
        & (frame[..., 0] > frame[..., 1] * 1.18)
        & (frame[..., 0] > frame[..., 2] * 1.10)
    )
    ys, xs = np.nonzero(red)
    if xs.size >= 3:
        return float(np.median(xs))

    ys, xs = np.nonzero(current_body)
    if xs.size:
        return float((xs.min() + xs.max()) * 0.5)

    ys, xs = np.nonzero(mask)
    if xs.size:
        return float((xs.min() + xs.max()) * 0.5)
    return float(frame.shape[1] * 0.5)


def smooth_actor_positions(values: list[float]) -> list[float]:
    if len(values) < 3:
        return values
    smoothed: list[float] = []
    for index in range(len(values)):
        start = max(0, index - 1)
        end = min(len(values), index + 2)
        smoothed.append(float(np.median(values[start:end])))
    return smoothed


def render_action_frames(
    source_frames: list[np.ndarray],
    background: np.ndarray,
    base_palette: set[int],
    start: int,
    end: int,
) -> list[Image.Image]:
    selected = source_frames[start:end]
    masks = [frame_mask(frame, background) for frame in selected]
    actor_x = smooth_actor_positions(
        [
            estimate_actor_x(frame, mask, base_palette)
            for frame, mask in zip(selected, masks)
        ]
    )

    outputs: list[Image.Image] = []
    for frame, mask, anchor_x in zip(selected, masks, actor_x):
        rgba = np.zeros(
            (CANVAS_SIZE, CANVAS_SIZE, 4),
            dtype=np.uint8,
        )
        ys, xs = np.nonzero(mask)
        # Translate the whole frame by one integer amount. Rounding every
        # source pixel independently around a half-pixel anchor duplicates
        # alternating columns and creates a striped sprite.
        x_shift = int(round(CANVAS_SIZE * 0.5 - anchor_x))
        dest_x = xs + x_shift
        dest_y = ys - SOURCE_GROUND_Y + CANVAS_GROUND_Y
        valid = (
            (dest_x >= 0)
            & (dest_x < CANVAS_SIZE)
            & (dest_y >= 0)
            & (dest_y < CANVAS_SIZE)
        )
        rgba[dest_y[valid], dest_x[valid], :3] = frame[
            ys[valid],
            xs[valid],
        ]
        rgba[dest_y[valid], dest_x[valid], 3] = 255
        outputs.append(Image.fromarray(rgba, "RGBA"))
    return outputs


def write_aseprite(
    path: Path,
    frames: list[Image.Image],
    durations: list[int],
    tag_name: str,
    loop: bool,
) -> None:
    frame_blocks: list[bytes] = []
    for frame_index, (frame, duration) in enumerate(
        zip(frames, durations)
    ):
        chunks: list[bytes] = []
        if frame_index == 0:
            layer_name = b"Character"
            layer_data = struct.pack(
                "<HHHHHHB3sH",
                3,
                0,
                0,
                CANVAS_SIZE,
                CANVAS_SIZE,
                0,
                255,
                b"\0" * 3,
                len(layer_name),
            ) + layer_name
            chunks.append(
                struct.pack("<IH", len(layer_data) + 6, 0x2004)
                + layer_data
            )

            tag = tag_name.encode("utf-8")
            tag_data = (
                struct.pack("<H8s", 1, b"\0" * 8)
                + struct.pack(
                    "<HHBH6s3BBH",
                    0,
                    len(frames) - 1,
                    0,
                    0 if loop else 1,
                    b"\0" * 6,
                    0,
                    0,
                    0,
                    0,
                    len(tag),
                )
                + tag
            )
            chunks.append(
                struct.pack("<IH", len(tag_data) + 6, 0x2018)
                + tag_data
            )

        raw = frame.tobytes()
        compressed = zlib.compress(raw, level=9)
        cel_data = (
            struct.pack(
                "<HhhB H h 5s HH",
                0,
                0,
                0,
                255,
                2,
                0,
                b"\0" * 5,
                CANVAS_SIZE,
                CANVAS_SIZE,
            )
            + compressed
        )
        chunks.append(
            struct.pack("<IH", len(cel_data) + 6, 0x2005)
            + cel_data
        )

        payload = b"".join(chunks)
        frame_size = len(payload) + 16
        frame_blocks.append(
            struct.pack(
                "<IHHH2sI",
                frame_size,
                0xF1FA,
                len(chunks),
                min(max(duration, 1), 65535),
                b"\0\0",
                len(chunks),
            )
            + payload
        )

    default_duration = min(max(durations[0], 1), 65535)
    header = (
        struct.pack(
            "<IHHHHHIHII",
            0,
            0xA5E0,
            len(frames),
            CANVAS_SIZE,
            CANVAS_SIZE,
            32,
            1,
            default_duration,
            0,
            0,
        )
        + struct.pack(
            "<B3sHBBhhHH84s",
            0,
            b"\0" * 3,
            0,
            1,
            1,
            0,
            0,
            16,
            16,
            b"\0" * 84,
        )
    )
    data = header + b"".join(frame_blocks)
    data = struct.pack("<I", len(data)) + data[4:]
    path.write_bytes(data)


def validate_aseprite(
    path: Path,
    expected_frames: list[Image.Image],
) -> None:
    data = path.read_bytes()
    file_size, magic, frame_count, width, height, depth = struct.unpack_from(
        "<IHHHHH",
        data,
        0,
    )
    if (
        file_size != len(data)
        or magic != 0xA5E0
        or frame_count != len(expected_frames)
        or width != CANVAS_SIZE
        or height != CANVAS_SIZE
        or depth != 32
    ):
        raise ValueError(f"Invalid Aseprite header: {path}")

    offset = 128
    decoded: list[bytes] = []
    for _frame_index in range(frame_count):
        frame_size, frame_magic, old_chunks = struct.unpack_from(
            "<IHH",
            data,
            offset,
        )
        new_chunks = struct.unpack_from("<I", data, offset + 12)[0]
        if frame_magic != 0xF1FA:
            raise ValueError(f"Invalid Aseprite frame: {path}")
        chunks = new_chunks or old_chunks
        chunk_offset = offset + 16
        for _chunk_index in range(chunks):
            chunk_size, chunk_type = struct.unpack_from(
                "<IH",
                data,
                chunk_offset,
            )
            if chunk_type == 0x2005:
                cel_type = struct.unpack_from(
                    "<H",
                    data,
                    chunk_offset + 13,
                )[0]
                if cel_type == 2:
                    image_width, image_height = struct.unpack_from(
                        "<HH",
                        data,
                        chunk_offset + 22,
                    )
                    compressed = data[
                        chunk_offset + 26 : chunk_offset + chunk_size
                    ]
                    raw = zlib.decompress(compressed)
                    expected_size = image_width * image_height * 4
                    if len(raw) != expected_size:
                        raise ValueError(
                            f"Invalid compressed cel: {path}"
                        )
                    decoded.append(raw)
            chunk_offset += chunk_size
        offset += frame_size

    if len(decoded) != len(expected_frames):
        raise ValueError(f"Missing Aseprite cels: {path}")
    for decoded_frame, expected in zip(decoded, expected_frames):
        if decoded_frame != expected.tobytes():
            raise ValueError(f"Aseprite cel mismatch: {path}")


def write_action(
    output_root: Path,
    spec: ActionSpec,
    frames: list[Image.Image],
    durations: list[int],
    full_export: bool = True,
) -> None:
    action_dir = output_root / spec.name
    if action_dir.exists():
        shutil.rmtree(action_dir)
    action_dir.mkdir(parents=True)

    sheet = Image.new(
        "RGBA",
        (CANVAS_SIZE * len(frames), CANVAS_SIZE),
        (0, 0, 0, 0),
    )
    for index, frame in enumerate(frames):
        sheet.paste(frame, (CANVAS_SIZE * index, 0), frame)
    sheet.save(action_dir / f"{spec.name}.png")

    if full_export:
        frame_dir = action_dir / "frames"
        frame_dir.mkdir()
        for index, frame in enumerate(frames):
            frame.save(frame_dir / f"frame_{index:03d}.png")

        gif_frames = [frame.convert("RGBA") for frame in frames]
        gif_frames[0].save(
            action_dir / f"{spec.name}.gif",
            save_all=True,
            append_images=gif_frames[1:],
            duration=durations,
            loop=0 if spec.loop else 1,
            disposal=2,
            transparency=0,
        )

        aseprite_path = action_dir / f"{spec.name}.aseprite"
        write_aseprite(
            aseprite_path,
            frames,
            durations,
            spec.name,
            spec.loop,
        )
        validate_aseprite(aseprite_path, frames)

    metadata = {
        "id": spec.name,
        "display_name": spec.display_name,
        "source_gif": spec.source_name,
        "source_frame_range": [spec.start, spec.end - 1],
        "canvas_size": [CANVAS_SIZE, CANVAS_SIZE],
        "frame_count": len(frames),
        "durations_ms": durations,
        "loop": spec.loop,
        "ground_anchor": [CANVAS_SIZE // 2, CANVAS_GROUND_Y],
        "background_removed": True,
        "watermark_removed_with_background": True,
        "reflection_removed": True,
    }
    (action_dir / "metadata.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def main() -> None:
    args = parse_args()
    source_names = sorted({spec.source_name for spec in ACTIONS})
    gif_frames: dict[str, list[np.ndarray]] = {}
    gif_durations: dict[str, list[int]] = {}
    for source_name in source_names:
        path = args.source / source_name
        if not path.exists():
            raise FileNotFoundError(path)
        gif_frames[source_name], gif_durations[source_name] = load_gif(
            path
        )

    backgrounds = build_backgrounds(gif_frames)
    base_palette = source_palette(
        gif_frames["C6oVJk.gif"][0],
        backgrounds["C6oVJk.gif"],
    )

    for spec in ACTIONS:
        source = gif_frames[spec.source_name]
        durations = gif_durations[spec.source_name][
            spec.start : spec.end
        ]
        frames = render_action_frames(
            source,
            backgrounds[spec.source_name],
            base_palette,
            spec.start,
            spec.end,
        )
        write_action(
            args.external_output,
            spec,
            frames,
            durations,
        )
        write_action(
            args.project_output,
            spec,
            frames,
            durations,
            False,
        )
        print(
            f"{spec.name}: {len(frames)} frames, "
            f"{sum(durations)} ms"
        )


if __name__ == "__main__":
    main()
