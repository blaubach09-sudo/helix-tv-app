#!/usr/bin/env python3
"""Helix TV tvOS icon + Top Shelf generator (carbon + gold, play-in-ring mark; NO company logo).
Writes directly into the tvOS asset catalog. Optional Michroma TTF path for the HELIXTV wordmark on Top Shelf.
  python3 Branding/make_icons.py [--font /path/Michroma-Regular.ttf]
"""
import argparse, os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BG, SURF, GOLD, INK = (11, 10, 9), (29, 25, 22), (243, 170, 32), (255, 255, 255)
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Swiftfin tvOS", "Resources", "Assets.xcassets")
BRAND = os.path.join(ROOT, "App Icon & Top Shelf Image.brandassets")
SS = 4  # supersample for crisp edges

def carbon(w, h):
    """carbon background with a soft gold glow top-right and orange glow top-left (Helios header feel)."""
    img = Image.new("RGB", (w, h), BG)
    glow = Image.new("RGB", (w, h), BG); d = ImageDraw.Draw(glow)
    d.ellipse([w*0.55, -h*0.6, w*1.25, h*0.5], fill=(60, 44, 18))
    d.ellipse([-w*0.25, -h*0.5, w*0.35, h*0.4], fill=(48, 30, 18))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=max(w, h)//6))
    return Image.blend(img, glow, 0.9)

def mark(size, ring_w=None):
    """gold play triangle inside a gold ring, transparent background, square `size`."""
    s = size * SS; img = Image.new("RGBA", (s, s), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
    rw = (ring_w or size * 0.062) * SS; r = s * 0.42; c = s / 2
    d.ellipse([c-r, c-r, c+r, c+r], outline=GOLD + (255,), width=int(rw))
    # equilateral-ish play triangle, centred optically (shifted right by ~6% of r)
    t = r * 0.58; cx = c + r * 0.06
    pts = [(cx - t*0.75, c - t*0.85), (cx + t*0.85, c), (cx - t*0.75, c + t*0.85)]
    d.polygon(pts, fill=GOLD + (255,))
    return img.resize((size, size), Image.LANCZOS)

def wordmark(font_path, height):
    """HELIX (white) + TV (gold) in Michroma, tracked. Returns RGBA image."""
    if not font_path: return None
    f = ImageFont.truetype(font_path, height)
    track = int(height * 0.32)
    def width(txt): return sum(f.getlength(ch) + track for ch in txt)
    w = int(width("HELIXTV")) + height; img = Image.new("RGBA", (w, int(height*1.5)), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
    x = 0
    for ch in "HELIXTV":
        col = INK if ch in "HELIX" else GOLD
        d.text((x, height*0.15), ch, font=f, fill=col + (255,)); x += f.getlength(ch) + track
    return img.crop(img.getbbox())

def save(img, *path):
    p = os.path.join(*path); os.makedirs(os.path.dirname(p), exist_ok=True); img.save(p, "PNG"); print("wrote", os.path.relpath(p, ROOT), img.size)

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--font", default=None); a = ap.parse_args()
    # App Icon (400x240 @1x/@2x) : Back = carbon, Front = mark (parallax layer)
    for scale, (w, h), fsz in ((1, (400, 240), 216), (2, (800, 480), 432)):
        sfx = "" if scale == 1 else "@2x"
        save(carbon(w, h), BRAND, "App Icon.imagestack", "Back.imagestacklayer", "Content.imageset", f"back{sfx}.png")
        front = Image.new("RGBA", (fsz, fsz), (0, 0, 0, 0)); m = mark(int(fsz * 0.78)); front.alpha_composite(m, ((fsz - m.width)//2, (fsz - m.height)//2))
        save(front, BRAND, "App Icon.imagestack", "Front.imagestacklayer", "Content.imageset", f"front{sfx}.png")
    # App Store icon 1280x768: Back carbon, Front 512 mark
    save(carbon(1280, 768), BRAND, "App Icon - App Store.imagestack", "Back.imagestacklayer", "Content.imageset", "1280x768-back.png")
    front = Image.new("RGBA", (512, 512), (0, 0, 0, 0)); m = mark(400); front.alpha_composite(m, (56, 56))
    save(front, BRAND, "App Icon - App Store.imagestack", "Front.imagestacklayer", "Content.imageset", "512.png")
    # Top Shelf (1920x720 @1x, 3840x1440 @2x) and Wide (2320x720, 4640x1440): carbon + mark + wordmark
    for name, (w, h) in (("Top Shelf Image.imageset", (1920, 720)), ("Top Shelf Image Wide.imageset", (2320, 720))):
        for scale in (1, 2):
            W, H = w*scale, h*scale; img = carbon(W, H).convert("RGBA")
            m = mark(int(H*0.42)); wm = wordmark(a.font, int(H*0.17))
            total = m.width + (int(H*0.12) + wm.width if wm else 0); x = (W - total)//2; y = (H - m.height)//2
            img.alpha_composite(m, (x, y))
            if wm: img.alpha_composite(wm, (x + m.width + int(H*0.12), (H - wm.height)//2))
            save(img.convert("RGB"), BRAND, name, f"topshelf{'' if scale==1 else '@2x'}.png")
    # standalone mark for in-app use (Shared asset catalog, added separately)
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "helix-mark-1024.png"); mark(1024).save(out); print("wrote", out)

if __name__ == "__main__": main()
