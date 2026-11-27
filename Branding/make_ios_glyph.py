import re, sys
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen
FONT="/Volumes/MAC MINI NVME/Projects/helix-tv-app/Branding/fonts/Michroma-Regular.ttf"
f=TTFont(FONT); gs=f.getGlyphSet(); cmap=f.getBestCmap()
TEXT_W=float(sys.argv[1]) if len(sys.argv)>1 else 840   # target wordmark width in 1024 canvas
TRACK=0.07   # tracking as fraction of cap height
MARK_H=float(sys.argv[2]) if len(sys.argv)>2 else 470
GAP=58
def glyph(ch):
    n=cmap[ord(ch)]; g=gs[n]; p=SVGPathPen(gs); g.draw(p); b=BoundsPen(gs); g.draw(b); return p.getCommands(), g.width, b.bounds
caps=glyph('H')[2]; capH=caps[3]-caps[1]
# lay out in font units
items=[]; x=0; word_gap=capH*0.45
for i,ch in enumerate("HELIXTV"):
    d,adv,bb=glyph(ch)
    if ch=='T': x+=word_gap
    items.append((ch,d,x,bb)); x+=adv+TRACK*capH
left=items[0][3][0]; right=items[-1][2]+items[-1][3][2]
wu=right-left; s=TEXT_W/wu; textH=capH*s
top=(1024-(MARK_H+GAP+textH))/2
# mark: orig bbox 259..765 x 220..806
ms=MARK_H/586.0; mcx=512; 
mtx=f"translate({512-512*ms:.2f},{top-220*ms:.2f}) scale({ms:.5f})"
base=(top+MARK_H+GAP+textH)
tx0=(1024-TEXT_W)/2
paths=[]
for ch,d,gx,bb in items:
    col="#FFFFFF" if ch in "HELIX" else "#f4ac21"
    paths.append(f'<path fill="{col}" stroke="{col}" stroke-width="{5/s:.1f}" stroke-linejoin="round" transform="translate({tx0+(gx-left)*s:.2f},{base:.2f}) scale({s:.5f},{-s:.5f})" d="{d}"/>')
src=open('orig.svg').read()
inner=src[src.index('<g'):src.rindex('</svg>')]
out=f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024px" height="1024px" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg">
<title>Helix TV</title>
<g transform="{mtx}">
{inner}
</g>
{chr(10).join(paths)}
</svg>
'''
open('Glyph.svg','w').write(out); print("textH",round(textH),"top",round(top))
