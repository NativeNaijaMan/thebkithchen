"""One-off procedural WAV placeholders for Phase 6 (quiet muzak, sting, jingle)."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SR = 44100


def _write_mono_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        for s in samples:
            w.writeframes(struct.pack("<h", max(-32767, min(32767, int(s)))))


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    out = root / "assets" / "audio"

    # 4s soft dual-tone “muzak”
    n = SR * 4
    muz: list[float] = []
    for i in range(n):
        t = i / SR
        am = 0.12 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.45 * t))
        v = am * (
            math.sin(2 * math.pi * 220 * t) * 0.4
            + math.sin(2 * math.pi * 330 * t) * 0.25
        )
        fade = min(1.0, i / 8000) * min(1.0, (n - i) / 8000)
        muz.append(fade * v * 22000)
    _write_mono_wav(out / "kitchen_muzak_loop.wav", muz)

    # Harsh short glitch
    n2 = int(SR * 0.18)
    gst: list[float] = []
    for i in range(n2):
        t = i / SR
        f = 880 + 2000 * t / 0.18
        env = math.sin(math.pi * i / max(1, n2)) ** 0.5
        gst.append(env * 0.55 * math.sin(2 * math.pi * f * t) * 28000)
    _write_mono_wav(out / "glitch_sting.wav", gst)

    # Three-note victory
    notes = [523.25, 659.25, 783.99]
    buf: list[float] = []
    for ni, freq in enumerate(notes):
        seg = int(SR * 0.14)
        gap = int(SR * 0.02)
        for i in range(seg):
            env = math.sin((math.pi * i) / max(1, seg - 1))
            t = i / SR
            buf.append(env * 0.35 * math.sin(2 * math.pi * freq * t) * 26000)
        buf.extend([0] * gap)
    _write_mono_wav(out / "victory_jingle.wav", buf)


if __name__ == "__main__":
    main()
