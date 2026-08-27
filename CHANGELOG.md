# Changelog

## 0.8.7 - 2026-08-27

- Fixed the blue EXP fill being restored over the native TYPE/PP box when a
  move-colour mod used its text-only presentation during move selection.
- Kept normal battle EXP colour restoration unchanged and added coverage for
  both move-selection geometry and protected true-colour pixels.

## 0.8.6 - 2026-08-27

- Fixed the iOS crash when entering a battle in packaged Gen1Recomp builds.
- Removed the enhanced HUD's runtime dependency on Lua's optional `debug`
  library while retaining protected state and canvas cleanup.

## 0.8.5 - 2026-08-14

- Tightened the Gender Mod marker spacing by one native pixel in Battle Art
  Voxel Fork 1.8+ so both symbols sit naturally beside their level glyphs.
- Kept the artwork at its original 8×8 resolution and changed neither the
  standard classic nor WIDE layout coordinates.

## 0.8.4 - 2026-08-14

- Fixed Gender Mod's second coloured overlay pass cutting through the player
  Pokémon's name in Battle Art Voxel Fork 1.8+ battles.
- Kept both the captured gender tile and the later coloured marker on Battle
  Art's stock level row while preserving the raised coordinate in classic and
  WIDE layouts.
- Made the coordinate bridge safe to reattach after updating the mod in a
  running installation.

## 0.8.3 - 2026-08-14

- Fixed Gender Mod's player symbol splitting the Pokémon name when Battle Art
  Voxel Fork 1.8+ captures its native staged HUD.
- Kept the native staged symbol on Battle Art's stock level row while retaining
  the raised level-row coordinate in Battle Info HUD's classic and WIDE views.
- Preserved Battle Art 1.8+'s own HUD capture and edge placement instead of
  applying the older 1.7 texture-layout bridge to its new pipeline.

## 0.8.2 - 2026-08-11

- Replaced the fractionally scaled EXP label with the game's original native
  font glyphs drawn on whole-number pixel coordinates.
- Gave the three letters compact integer spacing so they remain crisp and
  distinct beside the full-size EXP values in classic, WIDE and staged voxel
  layouts.

## 0.8.1 - 2026-08-10

- Fixed the Gender Mod hand-off in staged voxel battles so its player marker
  is captured from a clean temporary cell instead of copying native name or
  panel pixels underneath it.
- Removed that temporary cell before Dramatic Shape moves the HUD bands, so no
  stray glyph or texture block can remain in the voxel view.
- Preserved BATTLE ART VOXEL FORK's full colour-shadow treatment when the
  enhanced HP, status and EXP rows are rebuilt.

## 0.8.0 - 2026-08-10

- Added direct compatibility with Gender Mod 0.3.5 so the player marker follows
  the raised level row instead of overlapping the HP bar.
- Kept gender markers visible alongside both level and status, and preserved
  Gender Mod's authored marker pixels inside staged Dramatic Shape textures.
- Moved the caught-species Poké Ball from the opponent's level row to a compact
  position directly beside the Pokémon name in classic, WIDE and staged HUDs.

## 0.7.0 - 2026-08-09

- Added full support for Gen1Recomp's normal classic 160×144 battle layout when
  no voxel or Dramatic Shape mod is enabled.
- Captured and extended the engine's original HUD draw in a transparent native-
  resolution layer, preserving its tiles, coordinates and draw order without
  erasing the battlefield underneath it.
- Kept semantic HP and EXP colours through the classic renderer's palette-zone
  pass, with the existing BATTLE INFO switch controlling all layouts.

## 0.6.0 - 2026-08-09

- Added staged-HUD detection for BATTLE ART VOXEL FORK and Dramaless Shape in
  addition to upstream Dramatic Shape 1.8.2.
- Preserved extended HUD arguments used by newer forks, including their
  white-on-dark glyph processing.
- Derived the expanded player panel from each fork's reported HUD placement
  and independent HUD scale.

## 0.5.0 - 2026-08-08

- Widened the staged EXP track to the full lower-rule span and lowered it onto
  the top edge of the existing black underline.
- Reduced the EXP mark to a proportionally scaled native-font label with an
  HP-like compact footprint.
- Aligned the player name, status and HP mark to one clean left edge while
  preserving the status-left-of-level order.

## 0.4.0 - 2026-08-08

- Extended the original player HUD upward and leftward while keeping its
  bottom and right anchors fixed, creating a dedicated EXP row.
- Moved the one-pixel EXP fill immediately above the native lower rule and
  kept the current/required readout on the row above it.
- Moved the caught Poké Ball into the opponent's former status position and
  placed opponent status to the right of the native level indicator.
- Completed the player HUD's right-hand stroke between the HP and EXP rows.

## 0.3.0 - 2026-08-08

- Replaced the staged post-render overlay with an edit to Dramatic Shape's
  original 160×144 HUD texture before it is snapped into place.
- Kept HP colour, status/level, caught and EXP additions inside the existing
  frosted HUD panels at every window size.
- Moved the EXP strip onto the lower rule beneath its number markers so the
  line no longer crosses through the glyphs.

## 0.2.0 - 2026-08-08

- Removed the replacement battle panels and now enhance the existing HUD.
- Reused Gen1Recomp's native HP bar renderer and caught Poké Ball tile.
- Reworked EXP into a two-pixel blue strip on the player HUD's lower rule,
  with current and required values at opposite ends.
- Kept status immediately left of the original level indicator.
- Added direct compatibility for Dramatic Shape's snapped frosted HUD.

## 0.1.0 - 2026-08-08

- Added an optional information-rich HUD for WIDE and staged voxel battles.
- Added semantic HP colour, player EXP progress and current/required values.
- Added a caught-species marker for wild encounters.
- Kept status and level visible together.
- Added the BATTLE INFO toggle to the game's standard Options menu.
