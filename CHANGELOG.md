# Changelog

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
