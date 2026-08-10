# Battle Info HUD

Battle Info HUD adds the missing battle-reading information to Gen1Recomp's
existing battle HUD. It preserves the original panels, curves, font and HUD
tiles instead of replacing them with a new interface.

## Install

1. Download the `.zip` from the
   [latest release](https://github.com/piftee/gen1recomp-battle-info-hud/releases/latest).
2. Open Gen1Recomp and select **MODS → Import mod .zip**. You can also drag the
   downloaded ZIP onto the launcher window on desktop.
3. Enable **Battle Info HUD**, then start a battle. The mod detects the normal
   classic layout, the engine's
   WIDE layout and supported staged voxel presentations automatically.

The ZIP contains only the mod. You still need your own legally obtained
Pokémon Red, Blue or Yellow ROM imported into
[Gen1Recomp](https://github.com/bryanthaboi/gen1recomp).

The mod is enabled by default after installation. Use **BATTLE INFO → OFF** in
the ordinary Options menu whenever you want the original minimal HUD back.
The same switch is also available on the mod's own options page.

## What it changes

- redraws the existing HP bars with their native green, yellow and red states
- extends the native player HUD upward for a dedicated EXP row, with a compact
  native-font mark, a full-width one-pixel blue strip seated on the lower rule,
  and a current/required-to-next-level readout
- places the game's own Poké Ball tile directly beside the opponent's name
  when that wild species has already been caught
- keeps both native level indicators: player status sits to its left on the
  same content grid, while opponent status sits to the right of its level
- keeps Gender Mod's player marker beside the raised level row instead of over
  the HP meter, including when a status condition is visible

No additional HUD boxes or replacement panels are drawn.

The mod changes presentation only. It does not alter Pokémon stats, EXP gains,
catching, status effects, battle rules or save data beyond its own on/off
preference. Removing or disabling it restores the original presentation.

## Compatibility

The enhancements draw in Gen1Recomp's normal classic 160×144 and WIDE battle
layouts, as well as when a compatible Dramatic Shape renderer exposes a live
staged battle. This includes upstream Dramatic Shape 1.8.2, BATTLE ART VOXEL
FORK 1.7.9 and Dramaless Shape. In the classic layout the native HUD draw is
edited in a private pixel-perfect layer and returned at its original position.
For staged renderers, the mod edits the renderer's original 160×144 HUD texture
before it is snapped to the window edges, including its current HUD scale and
dark-ink treatment. It does not paint a second late overlay, and other battle
overlays can still compose through the normal `battle.overlay` hook.

Gender Mod 0.3.5 is supported directly. Its original marker artwork and colour
remain owned by Gender Mod; Battle Info HUD only supplies the adjusted player
coordinate and preserves that marker through the staged renderer's own clean
pixel capture and colour-shadow pass.

This package contains no ROM or ROM-derived assets. Pokémon and related names
are trademarks of their respective owners; this is an unofficial fan mod.

## Development

Clone this repository into the `mods` directory of a Gen1Recomp checkout:

```sh
git clone https://github.com/piftee/gen1recomp-battle-info-hud.git \
  mods/battle_info_hud
```

Then run from the Gen1Recomp repository root:

```sh
python3 tools/modkit.py validate mods/battle_info_hud
luajit mods/battle_info_hud/tests/battle_info_hud_test.lua
love . --developer
```
