# Battle Info HUD design QA

- source visual truth: `/var/folders/_f/5hxfvt8s7tnfcfx87lg2xcn00000gn/T/codex-clipboard-55e6a1aa-c559-485e-9524-59b32347ab51.png`
- implementation screenshot: `/private/tmp/battle-info-hud-v05-qa/battle_info_hud_dramatic.png`
- full-view comparison: `/private/tmp/battle-info-hud-v05-qa/full_comparison.png`
- player HUD comparison: `/private/tmp/battle-info-hud-v05-qa/player_hud_comparison.png`
- EXP detail evidence: `/private/tmp/battle-info-hud-v05-qa/player_exp_zoom.png`
- viewport: 1024 × 768 desktop game window
- source pixels/CSS size/density: 1024 × 768 at device density 1
- implementation pixels/CSS size/density: 1024 × 768 at device density 1
- normalization: no scale or density normalization; the focused comparison
  uses the same 464 × 240 player-HUD crop from each 1024 × 768 image
- state: Route 1 Dramatic Shape 1.7.2 wild battle; caught Pidgey; enemy `SLP`,
  player `PSN`; player `20/29` HP and `272/469` EXP progress. Dramatic Shape's
  background camera timing differs between captures, but the snapped HUD
  viewport, content state, size and anchors are identical.

## Findings

No actionable P0, P1 or P2 mismatch remains against the three current
annotations. The final capture changes the original HUD texture in place and
does not introduce a second overlay or replacement panel.

## Full-view comparison evidence

The full before/after sheet shows the same 1024 × 768 battle state. The player
panel retains its bottom and right anchors and the opponent panel remains in
the original top-left position. The different 3D camera frame is an expected
Dramatic Shape animation variation and does not change HUD geometry.

## Focused comparison evidence

- EXP track: the implementation expands the track from native `x=80..144` to
  `x=64..144` and lowers it from `y=87` to `y=90`. The EXP detail visibly
  seats the blue fill directly on the upper edge of the existing black rule.
- EXP mark: `EXP` now uses three untouched native 8 × 8 glyph tiles at integer
  coordinates with a seven-pixel advance. It remains compact beside the
  numeric row without fractional scaling or overlapping strokes.
- Player alignment: name, status and HP mark now share native `x=80`; the
  level remains at `x=112`, keeping `PSN` immediately to its left with a
  consistent one-tile gap. The HP and EXP values terminate on the same
  `x=144` right edge.

## Required fidelity surfaces

- Fonts and typography: passed. Every label and value uses the existing game
  font. The EXP mark is drawn from native glyph tiles on the 160 × 144 integer
  pixel grid; names, status, level and number markers retain native scale.
- Spacing and layout rhythm: passed. The three player metadata rows now use
  consistent left and right anchors, and the EXP strip fills the exact
  available underline span without colliding with the curve or vertical edge.
- Colors and visual tokens: passed. HP uses the engine's semantic green,
  yellow and red renderer; EXP uses the established restrained blue fill over
  the black native rule.
- Image quality and asset fidelity: passed. The original HUD texture, HUD
  tiles, font atlas and caught Poké Ball tile are reused with crisp
  nearest-neighbour output; no substitute assets were introduced.
- Copy and content: passed. `EXP`, current/required EXP, HP, status and level
  remain unambiguous and simultaneously visible.

## Comparison history

1. Replacement-panel prototype — blocked.
   - P1: new boxes obscured the battle and departed from Dramatic Shape's HUD.
   - Fix: removed replacement panels and reused native HUD primitives.
2. Late-overlay build — blocked.
   - P1: additions remained in classic-screen coordinates after Dramatic Shape
     snapped its HUD.
   - Fix: edit Dramatic Shape's original HUD texture before its snap/scale.
3. First texture-integrated build — blocked.
   - P2: EXP text occupied the native curve and the caught marker sat against
     the HP bar.
   - Fix: extended the original player HUD upward for a dedicated EXP row.
4. User-annotated 0.3.0 capture — blocked.
   - P2: caught/status order was wrong; the EXP fill sat below the rule; the
     player right stroke had a gap.
   - Fix: reordered opponent metadata, moved the fill above the rule and
     completed the native right edge.
5. User-annotated 0.4.0 capture — blocked.
   - P2: the EXP track was too short and high, the label was oversized and the
     player metadata left edges were inconsistent.
   - Fix: widened/lowered the track, reduced the native EXP mark, and aligned
     the player name, status and HP mark.
6. Final same-state focused comparison — passed.
   - The focused HUD and EXP evidence visibly resolves all three annotations
     with no remaining P0/P1/P2 issue.
7. Pixel-grid typography review — passed.
   - Replaced the fractional EXP transform with native glyph tiles and compact
     integer spacing; classic and WIDE captures show crisp, separated strokes.

## 2026-08-14 Gender Mod compatibility regression

- Source evidence: Gen1Recomp 0.1.83 with Gender Mod 0.3.5 and Battle Art
  Voxel Fork 1.8.7 placed the player's pink symbol in the Pokémon name row.
- Cause: Battle Art 1.8+ owns a stock staged HUD whose name remains at `y=56`
  and level remains at `y=64`; the older compatibility bridge applied Battle
  Info HUD's raised `y=56` level coordinate during that native capture.
- Fix: the native staged capture now receives a scoped coordinate guard that
  preserves `y=64`, then restores the enhanced `y=56` coordinate immediately
  afterward for classic and WIDE rendering.
- Evidence: direct 160×144 HUD-texture capture under the real 0.1.83/0.3.5/1.8.7
  runtime shows the symbol immediately before `:L12`, on the row below the
  player name. Automated coverage also checks that the scope is restored.

### Follow-up: coloured overlay pass

- Source evidence: the 0.8.3 follow-up capture showed a second pink player
  glyph cutting through `PIKACHU` even though the glyph baked into Battle
  Art's HUD texture was correctly seated on the level row.
- Cause: Gender Mod repaints its coloured marker after the staged texture has
  been placed. That later pass ran outside the capture-only coordinate guard
  and therefore received Battle Info HUD's classic `y=56` player coordinate.
- Fix: Battle Art 1.8+ staged battles now scope both Gender Mod passes to the
  stock `y=64` player level row. Classic and WIDE overlays still receive the
  enhanced `y=56` coordinate.
- Evidence: automated coverage invokes the real overlay ordering separately
  from the texture capture and checks the stock level row, then verifies the
  enhanced coordinate is restored outside the staged battle.

### Follow-up: staged marker spacing

- Source evidence: the 0.8.4 capture placed the player marker on the correct
  level row, but the Gender Mod tile's transparent right edge left a visibly
  loose two-native-pixel gap before `:L12` at Battle Art's enlarged scale.
- Fix: both staged markers move right by one native pixel. Their authored 8×8
  pixels and vertical centres remain untouched, leaving one clear native pixel
  before the level glyph.
- Scope: the nudge applies only during Battle Art 1.8+'s native HUD capture and
  coloured overlay passes. Classic, WIDE and legacy staged coordinates are
  unchanged.

## 2026-08-27 iOS battle-entry crash

- Source evidence: an iOS packaged build stopped at battle entry with
  `hud.lua:505: attempt to index global 'debug' (a nil value)`.
- Cause: five protected HUD cleanup paths passed `debug.traceback` directly to
  `xpcall`. The optional Lua debug library is present in desktop development
  but intentionally absent from packaged mobile builds.
- Fix: all protected paths now use a local message handler that calls the real
  traceback when available and otherwise returns the original error text.
- Evidence: automated coverage enters the enhanced classic battle renderer
  with `_G.debug = nil`, reproducing the mobile runtime constraint. The draw,
  status restoration and canvas cleanup complete without an error.

## 2026-08-27 text-only move-selection EXP overlap

- Source evidence: on the mobile classic battle screen, Typed Move Colors in
  Text Only mode left a blue EXP strip running left through the native TYPE/PP
  details box after FIGHT was selected.
- Cause: the text-only presentation performs a palette-zone pass after the
  move UI is drawn. Battle Info HUD treated that pass as the battle-background
  pass and restored the EXP fill at its normal battle coordinates.
- Fix: late classic EXP colour restoration is suspended while `moveSelect` or
  `mimicSelect` owns the lower screen. The actual HUD EXP row and every normal
  battle phase retain the existing blue progress fill.
- Evidence: automated coverage runs the wrapped zone pass during move
  selection and verifies that it adds neither a rectangle nor protected
  true-colour pixels over the move-details box.

## 2026-08-29 neutral Gender Mod battle marker

- Source evidence: the reported WIDE battle showed Gender Mod's black `⚲`
  asset one tile before SENTRET's native level marker. A pixel comparison
  matched the boxed glyph to Gender Mod 0.3.5's `assets/genderless.png`.
- Cause: Gender Mod resolves both genuinely genderless Pokémon and species
  missing from its Gen 1 ratio table to the same neutral state. SENTRET is not
  present in that table, so the fallback icon appeared as an unexplained HUD
  symbol.
- Fix: Battle Info HUD suppresses neutral/N art only while Gender Mod is
  drawing its battle HUD or coloured battle overlay. Male and female markers
  retain their original artwork and coordinates; non-battle Gender Mod screens
  remain untouched.
- Evidence: automated coverage exercises the ink, authored-colour and overlay
  paths. Neutral calls are absent inside battle passes, M/F calls remain, and
  a neutral call outside the battle scope still reaches Gender Mod.

## Residual test gap

Visual QA covered macOS and Dramatic Shape 1.7.2 at 1024 × 768. Automated
tests cover WIDE rendering, the live option toggle, palette behavior,
opponent ordering, panel expansion and texture/canvas restoration. Mobile and
VR-specific placement were not visually sampled.

final result: passed
