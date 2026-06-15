#!/usr/bin/env python3
"""Generate krill app icons: a white Lucide glyph on a circular pink background."""
from PIL import Image, ImageDraw
from pathlib import Path
import subprocess, sys, urllib.request, tempfile

# A krill icon is one Lucide glyph in Ghost White, centered on a solid
# circle of Shimmering Blush. The circle fills the tile edge-to-edge;
# the glyph occupies the inner ~56% so the pink has comfortable padding.
SHIMMERING_BLUSH = (221, 117, 150, 255)  # --fm-accent — the icon background
GHOST_WHITE      = "#FAFAFF"             # --fm-bg — the glyph stroke color
MASTER = 1024
GLYPH_SIZE = 576  # ~56% of MASTER — smaller than the old squircle's 70%

# slug -> Lucide icon name. Source of truth for every krill app's
# launcher glyph. Adding an app: append its slug and the chosen
# Lucide name (browse https://lucide.dev/icons), then re-run the
# script — or let the release workflow do it on the next tag.
APPS = {
    "image-editor":    "crop",
    "image-viewer":    "image",
    "markdown-editor": "file-pen-line",
    "markdown-viewer": "book-open",
    "rss-reader":      "rss",
    "color-editor":    "palette",
    "document-viewer": "file-text",
    "csv-editor":      "table",
    "text-editor":     "notepad-text",
    "terminal":        "square-terminal",
    "system-monitor":  "activity",
    "file-drop":       "file-signal",
    "photo-importer":  "image-down",
    "audio-editor":    "audio-lines",
    "paint":           "brush",
    "pixel-editor":    "grid-2x2",
}

def fetch_svg(name):
    url = f"https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/{name}.svg"
    return urllib.request.urlopen(url).read().decode()

def recolor(svg):
    # bake Ghost White stroke so the glyph reads on the pink circle
    return svg.replace('stroke="currentColor"', f'stroke="{GHOST_WHITE}"')

def render_glyph(svg_text, px):
    with tempfile.NamedTemporaryFile(suffix=".svg", delete=False) as f:
        f.write(svg_text.encode())
        svg_path = f.name
    png_path = svg_path.replace(".svg", ".png")
    subprocess.run(
        ["convert", "-background", "none", "-density", "1200",
         svg_path, "-resize", f"{px}x{px}", png_path],
        check=True,
    )
    return Image.open(png_path).convert("RGBA")

def make_master(svg_text):
    # Supersample the circle so its edge is smooth, then downscale.
    ss = 4
    big = Image.new("RGBA", (MASTER * ss, MASTER * ss), (0, 0, 0, 0))
    draw = ImageDraw.Draw(big)
    draw.ellipse((0, 0, MASTER * ss - 1, MASTER * ss - 1), fill=SHIMMERING_BLUSH)
    canvas = big.resize((MASTER, MASTER), Image.LANCZOS)

    glyph = render_glyph(svg_text, GLYPH_SIZE)
    offset = ((MASTER - glyph.width) // 2, (MASTER - glyph.height) // 2)
    canvas.alpha_composite(glyph, offset)
    return canvas

def export(master, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)
    sizes = {"icon.png": 1024, "32x32.png": 32, "128x128.png": 128, "128x128@2x.png": 256}
    for name, sz in sizes.items():
        master.resize((sz, sz), Image.LANCZOS).save(out_dir / name, "PNG")

def render_one(slug, out_dir):
    glyph = APPS.get(slug)
    if not glyph:
        raise SystemExit(f"unknown slug {slug!r} — add it to APPS in this script")
    print(f"{slug:18s} -> lucide:{glyph}")
    svg = recolor(fetch_svg(glyph))
    master = make_master(svg)
    export(master, out_dir)

def main(argv):
    # Two modes:
    #   render-icons.py /path/to/krill-software
    #     Bulk: regenerate icons for every slug in APPS into
    #     <root>/<slug>/src-tauri/icons/. The local dev workflow.
    #
    #   render-icons.py --slug <slug> --out <dir>
    #     Single app: drop the four PNGs into <dir>. The release-CI
    #     workflow, which doesn't know about sibling repos.
    if "--slug" in argv:
        i = argv.index("--slug")
        slug = argv[i + 1]
        j = argv.index("--out")
        out = Path(argv[j + 1])
        render_one(slug, out)
        print("done")
        return
    if len(argv) < 2:
        raise SystemExit(__doc__ + "\nUsage:\n  render-icons.py <krill-software-root>\n  render-icons.py --slug <slug> --out <dir>")
    root = Path(argv[1])
    for slug in APPS:
        render_one(slug, root / slug / "src-tauri" / "icons")
    print("done")

if __name__ == "__main__":
    main(sys.argv)
