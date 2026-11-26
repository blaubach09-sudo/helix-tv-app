# Apple TV media-app UI research (2026-11-26)

Sources reached: jellyfin/Swiftfin GitHub issues/discussions/releases, forums.plex.tv, community.firecore.com (Infuse),
forum.jellyfin.org, community.getchannels.com, Apple HIG (tvOS), Apple newsroom/support, 9to5Mac, PCWorld, mjtsai.
Not reachable: Reddit (all mirrors), MacRumors forums, AppleInsider, Neowin.

## Consensus rules we adopt
1. Continue Watching / Next Up first; hero < half screen; >= 2 rows visible (mjtsai 2022/11/03; plex 941835, 903106).
2. Home rows: Continue Watching (merged), Next Up, Recently Added (merged), libraries; no discovery clutter (plex 931048; Swiftfin #1851).
3. Series page = one screen: header + Play(next up) + season picker + horizontal 16:9 episode row; Play = default focus
   (Swiftfin #431, #2189, #2129, #2160; plex 903106).
4. Episode cards: SxxExx + title on every card; runtime/air date/resolution on focus; progress bar + played check;
   focused card fully visible; selecting the thumb plays (Swiftfin #1184, #2442, #2159; plex 725972, 935616).
5. Badges: real 4K/HDR/DV/Atmos glyphs under the title, not text pills (Infuse 32698).
6. Backdrop right-weighted, UI bottom-left (Channels 44088).
7. Unplayed counts on series poster and per season; clear played indicator (plex 725972; Swiftfin #1825, #1769).
8. Grid: 40pt gap, 6-7 columns @1920 (HIG layout); letter jump (Swiftfin #2072); sort first then filters (#1522).
9. Player = native muscle memory: Menu hides controls (exit only when hidden), L/R = +-10s, hold = 2x/3x/4x,
   swipe down = info pane, swipe up = subtitles; Back never exits from a submenu; focus lands on the scrubber;
   thin bar, trickplay, Ends at; Up Next card 10-15s before end; skip-intro translucent + auto-focused
   (support.apple.com atvb7944597f; plex 903103, 903091; Swiftfin #697, #2178, #2180, #2369, #1902).
10. Focus: system scale + parallax, never move focus without input, pad for the scaled state (HIG focus-and-selection;
    Swiftfin #489, #2308).
11. Liquid Glass only on the control layer; 35% dim behind glass over bright video (HIG materials, playing-video).
12. Plex praise to keep: studio logos over typeset titles, horizontal rows, multiple rating sources, honest HDR labels.

## Swiftfin issue index (tvOS UI)
Open: #1575 carousel, #2181 row poster type, #2346 adaptive mode, #335 Top Shelf, #1189 deep links, #2388/#2397 >20 seasons,
#2462 mark-watched flicker, #2351 HTML overviews.
Closed/instructive: #431 nav, #1640 season->episode focus, #2189/#2129/#2160 play default focus, #2442 row scroll,
#2244 picker focus vs selection, #2371 vertical episode list, #1184 thumb = play, #697 audio picker, #799 click-only scrub,
#1902/#2001 player, #2178-#2187 player focus, #2213/#2216 menus, #2369 Ends-at, #2157 trickplay popup, #2177/#2192 logos,
#2387/#2223 title width, #853 fanart bg, #2072 letter picker, #1522 sort/filter, #2256 tab bar, #2033 header overlap,
#1213/#2308 grid spacing, #2222 Liquid Glass guard, #1947 Top Shelf, #1325 search keyboard, #1204 player header,
#201 Back exits app, #1005 audio after exit.
