#!/usr/bin/env python3
"""Convertit les GIFs de assets/renders/ en animations lisibles par Godot.

Godot ne sait pas lire les GIFs. Ce script (lancé automatiquement par le workflow
GitHub avant l'export web) découpe chaque GIF en images PNG et écrit une ressource
SpriteFrames (frames.tres) qui garde le rythme exact du GIF :

    assets/renders/jumpscares/clovis.gif
      -> assets/renders/_gif/jumpscares/clovis/000.png, 001.png, ...
      -> assets/renders/_gif/jumpscares/clovis/frames.tres

Le jeu (RenderSlot) utilise automatiquement l'animation si elle existe.
Le dossier _gif/ est régénéré à chaque fois et n'est pas versionné.

En local : `pip install pillow` puis `python3 tools/convert_gifs.py`.
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

from PIL import Image, ImageSequence

ROOT = Path(__file__).resolve().parent.parent
RENDERS = ROOT / "assets" / "renders"
OUT = RENDERS / "_gif"
# Vitesse de l'animation Godot : 100 images/s => "duration" = délai GIF en centisecondes.
SPEED = 100.0


def res_path(p: Path) -> str:
    return "res://" + p.relative_to(ROOT).as_posix()


def convert(gif: Path) -> int:
    rel = gif.relative_to(RENDERS).with_suffix("")  # ex. jumpscares/clovis
    dest = OUT / rel
    dest.mkdir(parents=True, exist_ok=True)
    frames: list[tuple[Path, float]] = []
    with Image.open(gif) as im:
        loop = im.info.get("loop", 0) == 0 or "loop" not in im.info
        for i, frame in enumerate(ImageSequence.Iterator(im)):
            delay_ms = frame.info.get("duration", im.info.get("duration", 100)) or 100
            if delay_ms <= 10:  # comme les navigateurs : délai 0/1 cs -> 100 ms
                delay_ms = 100
            png = dest / f"{i:03d}.png"
            frame.convert("RGBA").save(png, optimize=True)
            frames.append((png, delay_ms / 10.0))
    lines = [f'[gd_resource type="SpriteFrames" load_steps={len(frames) + 1} format=3]', ""]
    for i, (png, _) in enumerate(frames):
        lines.append(f'[ext_resource type="Texture2D" path="{res_path(png)}" id="{i + 1}"]')
    lines += ["", "[resource]"]
    entries = ", ".join(
        f'{{"duration": {d:.2f}, "texture": ExtResource("{i + 1}")}}' for i, (_, d) in enumerate(frames)
    )
    lines.append(
        f'animations = [{{"frames": [{entries}], "loop": {str(loop).lower()}, '
        f'"name": &"default", "speed": {SPEED}}}]'
    )
    (dest / "frames.tres").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(frames)


def main() -> int:
    if OUT.exists():
        shutil.rmtree(OUT)
    gifs = sorted(p for p in RENDERS.rglob("*") if p.suffix.lower() == ".gif" and OUT not in p.parents)
    if not gifs:
        print("Aucun GIF à convertir.")
        return 0
    for gif in gifs:
        n = convert(gif)
        print(f"{gif.relative_to(ROOT)} -> {n} images")
    return 0


if __name__ == "__main__":
    sys.exit(main())
