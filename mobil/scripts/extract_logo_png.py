#!/usr/bin/env python3
"""Embed PNG çıkar: mobil/assets/images/logo.svg -> mobil/assets/images/logo.png"""
import base64
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
svg_path = ROOT / "assets" / "images" / "logo.svg"
out_path = ROOT / "assets" / "images" / "logo.png"


def main() -> None:
    svg = svg_path.read_text(encoding="utf-8")
    m = re.search(r'(?:xlink:href|href)="(data:image/png;base64,[^"]+)"', svg)
    if not m:
        raise SystemExit(f"logo.svg içinde data:image/png;base64 bulunamadı: {svg_path}")
    uri = m.group(1)
    b64 = uri.split(",", 1)[1]
    out_path.write_bytes(base64.b64decode(b64))
    print(f"OK -> {out_path} ({out_path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
