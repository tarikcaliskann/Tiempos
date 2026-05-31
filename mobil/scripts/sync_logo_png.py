#!/usr/bin/env python3
"""Tek marka PNG: frontend/public/logo.png -> mobil/assets/images/logo.png"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
src = REPO / "frontend" / "public" / "logo.png"
dst = ROOT / "assets" / "images" / "logo.png"

if not src.is_file():
    raise SystemExit(f"Kaynak bulunamadı: {src}")
dst.write_bytes(src.read_bytes())
print(f"OK: {src} -> {dst}")
