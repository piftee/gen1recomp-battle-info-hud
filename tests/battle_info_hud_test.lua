-- Standalone: luajit mods/battle_info_hud/tests/battle_info_hud_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Font = require("src.render.Font")
local Growth = require("src.pokemon.Growth")
local HudTiles = require("src.render.HudTiles")
local PaletteFX = require("src.render.PaletteFX")
local Runtime = require("src.mods.Runtime")
local BattleState = require("src.battle.BattleState")
local WideBattle = require("src.battle.WideBattle")

local data = T.fixtures.fresh()
Font.load(data)
local realWideDraw = WideBattle.draw
local realClassicDrawHUDs = BattleState.drawHUDs
local realClassicZonePass = BattleState.drawZonePass
local nativeWideCalls = {}
local nativeClassicCalls = {}
local nativeZoneCalls = {}
BattleState.drawHUDs = function(b, slide)
  nativeClassicCalls[#nativeClassicCalls + 1] = {
    slide = slide,
    enemyStatus = b.enemy.shownStatus,
    playerStatus = b.player.shownStatus,
  }
  return "classic-native"
end
BattleState.drawZonePass = function(b, src, sx, sy)
  nativeZoneCalls[#nativeZoneCalls + 1] = {
    battle = b, src = src, sx = sx, sy = sy,
  }
  return "zone-native"
end
WideBattle.draw = function(b)
  nativeWideCalls[#nativeWideCalls + 1] = {
    enemyStatus = b.enemy.shownStatus,
    playerStatus = b.player.shownStatus,
    enemyName = b.enemy.name,
    playerName = b.player.name,
  }
  Runtime.call("battle.overlay", function() end, b)
end
local run = T.sdk.loadMod("mods/battle_info_hud", { data = data, dev = true })
T.eq(#run.errors, 0, "loads clean (" .. tostring(run.errors[1]) .. ")")

local schema = run.loader.optionSchemas.battle_info_hud or {}
T.eq(#schema, 1, "registers one simple presentation switch")
T.eq(schema[1].key, "enabled", "the setting has a stable saved key")
T.eq(schema[1].default, true, "the useful HUD is on after installation")

local game = {
  data = run.data,
  save = {
    options = {},
    pokedex = { owned = { FIXMON_B = true } },
  },
  mods = run.loader,
}
local rows = Runtime.call("ui.options.rows",
  function(_, base) return base end, game, { { id = "text_speed" } })
T.eq(#rows, 2, "the toggle appears in the normal Options menu")
T.eq(rows[2].id, "battle_info_hud_enabled", "the row id is namespaced")
T.eq(rows[2].value(game), "ON", "the Options row reflects the default")

local boxes, rectangles, texts, hpBars, marks, sprites = {}, {}, {}, {}, {}, {}
local activeColor = { 1, 1, 1, 1 }
local realDrawBox, realDraw = Font.drawBox, Font.draw
local realDrawHPBar = HudTiles.drawHPBar
local realSetColor = love.graphics.setColor
local realRectangle = love.graphics.rectangle
local realGetScissor = love.graphics.getScissor
local realSetScissor = love.graphics.setScissor
local realGetCanvas = love.graphics.getCanvas
local realSetCanvas = love.graphics.setCanvas
local realNewCanvas = love.graphics.newCanvas
local realClear = love.graphics.clear
local realGraphicsDraw = love.graphics.draw
local realMark = PaletteFX.markTrueColor
local currentCanvas, canvasCalls = "engine-canvas", {}
local canvasCreates, canvasClears, compositeDraws = {}, {}, {}

Font.drawBox = function(tx, ty, tw, th)
  boxes[#boxes + 1] = { tx = tx, ty = ty, tw = tw, th = th }
end
Font.draw = function(value, x, y)
  texts[#texts + 1] = { value = tostring(value), x = x, y = y }
end
HudTiles.drawHPBar = function(_, tx, ty, mon, barType, grayFill, segments)
  hpBars[#hpBars + 1] = {
    tx = tx, ty = ty, hp = mon.hp, maxHP = mon.stats.hp,
    barType = barType, grayFill = grayFill, segments = segments,
  }
end
love.graphics.setColor = function(r, g, b, a)
  if type(r) == "table" then
    activeColor = { r[1], r[2], r[3], r[4] }
  else
    activeColor = { r, g, b, a }
  end
end
love.graphics.rectangle = function(mode, x, y, w, h)
  rectangles[#rectangles + 1] = {
    mode = mode, x = x, y = y, w = w, h = h,
    color = { activeColor[1], activeColor[2], activeColor[3], activeColor[4] },
  }
end
love.graphics.getScissor = function() return nil end
love.graphics.setScissor = function() end
love.graphics.getCanvas = function() return currentCanvas end
love.graphics.setCanvas = function(canvas)
  currentCanvas = canvas
  canvasCalls[#canvasCalls + 1] = canvas
end
love.graphics.newCanvas = function(w, h)
  local canvas = {
    isTestHudCanvas = true,
    width = w,
    height = h,
    setFilter = function(self, min, mag)
      self.minFilter, self.magFilter = min, mag
    end,
  }
  canvasCreates[#canvasCreates + 1] = canvas
  return canvas
end
love.graphics.clear = function(...)
  canvasClears[#canvasClears + 1] = { canvas = currentCanvas, args = { ... } }
end
love.graphics.draw = function(drawable, x, y)
  if type(drawable) == "table" and drawable.isTestHudCanvas then
    compositeDraws[#compositeDraws + 1] = {
      drawable = drawable, x = x, y = y, canvas = currentCanvas,
    }
  end
end
PaletteFX.markTrueColor = function(x, y, w, h)
  marks[#marks + 1] = { x = x, y = y, w = w, h = h }
end

local level = 12
local floorExp = Growth.expForLevel(data.pokemon.FIXMON_A.growthRate, level,
  data.growth_rates)
local nextExp = Growth.expForLevel(data.pokemon.FIXMON_A.growthRate, level + 1,
  data.growth_rates)
local needed = nextExp - floorExp
local battle = {
  game = game,
  data = data,
  kind = "wild",
  frame = 1,
  enemy = {
    name = "FIXMON B", shownHP = 4, shownStatus = "SLP",
    mon = {
      species = "FIXMON_B", level = 10, hp = 4, stats = { hp = 40 },
    },
  },
  player = {
    name = "FIXMON A", shownHP = 36, shownStatus = "PSN",
    mon = {
      species = "FIXMON_A", level = level, hp = 36, stats = { hp = 40 },
      exp = floorExp + 10,
    },
  },
  wideLayout = function() return true end,
  growInScale = function() return nil end,
  statusLabel = function(_, mon) return mon.status end,
  drawBallRow = function(_, party, x, y)
    T.eq(party[1].hp, 1, "caught marker reuses the native healthy-ball row")
    sprites[#sprites + 1] = { x = x, y = y }
  end,
}

rows[2].step(game, 1)
T.eq(rows[2].value(game), "OFF", "the feature can be disabled")
WideBattle.draw(battle)
T.eq(#hpBars, 0, "OFF leaves the engine battle HUD untouched")
T.eq(nativeWideCalls[1].enemyStatus, "SLP",
  "OFF leaves native status rendering untouched")

rows[2].step(game, 1)
T.eq(rows[2].value(game), "ON", "the feature can be restored live")
nativeWideCalls, rectangles, texts, hpBars, marks, sprites = {}, {}, {}, {}, {}, {}
WideBattle.draw(battle)

T.same(boxes[1], { tx = 0, ty = 0, tw = 18, th = 4 },
  "the opponent panel grows to fit caught, level and status in one row")
T.same(boxes[2], { tx = 23, ty = 6, tw = 15, th = 6 },
  "the native wide player panel grows upward by exactly one row")
T.eq(nativeWideCalls[1].enemyStatus, nil,
  "the engine is allowed to draw the enemy level in its native position")
T.eq(nativeWideCalls[1].playerStatus, nil,
  "the engine is allowed to draw the player level in its native position")
T.check(Font.width(nativeWideCalls[1].enemyName) <= 48
    and Font.width(nativeWideCalls[1].playerName) <= 40,
  "wide names make room for status immediately left of the native level")
T.eq(battle.enemy.shownStatus, "SLP", "enemy status is restored after drawing")
T.eq(battle.player.shownStatus, "PSN", "player status is restored after drawing")
T.eq(battle.enemy.name, "FIXMON B", "enemy nickname is restored after drawing")
T.eq(battle.player.name, "FIXMON A", "player nickname is restored after drawing")

T.eq(#hpBars, 2, "the two existing HP bars are redrawn in colour")
T.same(hpBars[1], {
  tx = 1, ty = 2, hp = 4, maxHP = 40,
  barType = nil, grayFill = false, segments = 11,
}, "the enemy reuses the engine's original wide HP bar")
T.same(hpBars[2], {
  tx = 24, ty = 8, hp = 36, maxHP = 40,
  barType = 1, grayFill = false, segments = 10,
}, "the player reuses the engine's wide HP bar one row higher")

local seen = {}
for _, call in ipairs(texts) do seen[call.value] = call end
T.same(seen.SLP, { value = "SLP", x = 116, y = 8 },
  "enemy status sits directly right of the native level")
T.same(seen.PSN, { value = "PSN", x = 236, y = 56 },
  "player status sits directly left of the native level")
T.check(seen["10/" .. tostring(needed)] ~= nil,
  "EXP shows a compact current/required readout")
local expGlyphs = {}
for _, call in ipairs(texts) do
  if call.value == "E" or call.value == "X" or call.value == "P" then
    expGlyphs[#expGlyphs + 1] = call
  end
end
T.same(expGlyphs, {
  { value = "E", x = 192, y = 80 },
  { value = "X", x = 199, y = 80 },
  { value = "P", x = 206, y = 80 },
}, "EXP uses unscaled native glyphs on integer pixel coordinates")
T.same(sprites[1], {
  x = 8 + Font.width(nativeWideCalls[1].enemyName) + 2, y = 8,
}, "the native caught ball sits directly beside the wide opponent name")

T.eq(#rectangles, 2, "EXP uses one narrow track and one narrow fill")
T.same({ rectangles[1].x, rectangles[1].y, rectangles[1].w,
    rectangles[1].h }, { 192, 90, 96, 1 },
  "the wide EXP strip spans and seats into the native lower rule")
T.eq(rectangles[2].h, 1, "the blue EXP fill remains only one pixel tall")
T.check(rectangles[2].color[3] > 0.7
    and rectangles[2].color[1] < 0.3,
  "the EXP fill is blue")
T.eq(#marks, 3, "two native HP bars and EXP retain semantic colour")

boxes, rectangles, texts, hpBars, marks, sprites, canvasCalls =
  {}, {}, {}, {}, {}, {}, {}
battle.wideLayout = function() return false end
battle.dramaticShapeShot = { live = true }
local dramaticTextureCalls = {}
local dramatic = {
  hudTexture = function(b)
    dramaticTextureCalls[#dramaticTextureCalls + 1] = {
      enemyStatus = b.enemy.shownStatus,
      playerStatus = b.player.shownStatus,
    }
    return "hud-layer"
  end,
  snapRects = function(shot)
    local scale = shot.scale
    return {
      enemy = { 0, shot.ly, 80 * scale, 32 * scale },
      player = { 100, shot.ly + 56 * scale, 88 * scale, 40 * scale },
    }, { enemy = 0, player = 100 }
  end,
}
game.mods.exports.DRAMATIC_SHAPE = {
  lib = { require = function() return dramatic end },
}
Runtime.call("battle.overlay", function() end, battle)
T.eq(#boxes, 0, "staged voxel battles retain the existing classic HUD")
T.eq(#hpBars, 0,
  "staged additions are not painted as a post-render battle overlay")
T.eq(dramatic.hudTexture(battle, 0), "hud-layer",
  "Dramatic Shape's original snapped-HUD texture result is preserved")
local snapped = dramatic.snapRects({ scale = 5, ly = 10 })
T.same(snapped.player, { 20, 250, 520, 240 },
  "the original frosted player panel grows upward and leftward")
rows[2].step(game, 1)
local nativeSnap = dramatic.snapRects({ scale = 5, ly = 10 })
T.same(nativeSnap.player, { 100, 290, 440, 200 },
  "OFF restores Dramatic Shape's original player-panel geometry")
rows[2].step(game, 1)
T.eq(dramaticTextureCalls[1].enemyStatus, nil,
  "the original HUD texture draws the native enemy level")
T.eq(dramaticTextureCalls[1].playerStatus, nil,
  "the original HUD texture draws the native player level")
T.same(hpBars[1], {
  tx = 2, ty = 2, hp = 4, maxHP = 40,
  barType = nil, grayFill = false, segments = 6,
}, "staged enemy HP colour overlays the original bar exactly")
T.same(hpBars[2], {
  tx = 10, ty = 8, hp = 36, maxHP = 40,
  barType = 1, grayFill = false, segments = 6,
}, "staged player HP colour stays inside the extended original HUD")

seen = {}
for _, call in ipairs(texts) do seen[call.value] = call end
T.same(seen.SLP, { value = "SLP", x = 60, y = 8 },
  "staged enemy status sits right of its original level indicator")
T.same(seen.PSN, { value = "PSN", x = 80, y = 56 },
  "staged player status aligns with the name and HP mark")
T.same(sprites[1], { x = 8 + Font.width(battle.enemy.name) + 2, y = 0 },
  "the caught marker sits directly beside the staged opponent name")
T.same({ rectangles[1].x, rectangles[1].y, rectangles[1].w,
    rectangles[1].h, rectangles[1].color[4] }, { 56, 48, 104, 48, 0 },
  "the stock five-row player HUD is cleared inside its own texture")
T.same({ rectangles[2].x, rectangles[2].y, rectangles[2].w,
    rectangles[2].h }, { 64, 90, 80, 1 },
  "staged EXP fills the available lower-rule span")
T.same(canvasCalls, { "hud-layer", "engine-canvas" },
  "enhancements are drawn into the original HUD texture and canvas is restored")
T.eq(#marks, 0,
  "the already-coloured snapped texture does not leak main-canvas palette marks")
T.eq(battle.enemy.shownStatus, "SLP",
  "Dramatic Shape bridge restores the enemy status after its snapshot")
T.eq(battle.player.shownStatus, "PSN",
  "Dramatic Shape bridge restores the player status after its snapshot")

boxes, rectangles, texts, hpBars, marks, sprites, canvasCalls =
  {}, {}, {}, {}, {}, {}, {}
nativeClassicCalls, canvasCreates, canvasClears, compositeDraws = {}, {}, {}, {}
battle.dramaticShapeShot = nil
battle.letterboxWhite = true
battle.colorMode = function() return true end
local classicResult = BattleState.drawHUDs(battle, 0)
T.eq(classicResult, "classic-native",
  "classic enhancement preserves the original HUD draw result")
T.eq(#nativeClassicCalls, 1,
  "the normal renderer still draws its original HUD exactly once")
T.eq(nativeClassicCalls[1].enemyStatus, nil,
  "classic opponent level remains visible while status is added beside it")
T.eq(nativeClassicCalls[1].playerStatus, nil,
  "classic player level remains visible while status is added beside it")
T.eq(battle.enemy.shownStatus, "SLP",
  "classic enhancement restores opponent state after drawing")
T.eq(battle.player.shownStatus, "PSN",
  "classic enhancement restores player state after drawing")
T.eq(#canvasCreates, 1, "classic HUD uses one reusable native-size layer")
T.same({ canvasCreates[1].width, canvasCreates[1].height,
    canvasCreates[1].minFilter, canvasCreates[1].magFilter },
  { 160, 144, "nearest", "nearest" },
  "the classic layer preserves the original pixel grid")
T.eq(#canvasClears, 1, "the private HUD layer is cleared before reuse")
T.same({ canvasCalls[1], canvasCalls[2] },
  { canvasCreates[1], "engine-canvas" },
  "classic HUD edits stay off the battlefield canvas")
T.eq(#compositeDraws, 1,
  "the edited native HUD is composited exactly once")
T.eq(compositeDraws[1].drawable, canvasCreates[1],
  "the composite uses the edited private HUD layer")
T.same({ compositeDraws[1].x, compositeDraws[1].y,
    compositeDraws[1].canvas }, { 0, 0, "engine-canvas" },
  "the edited native HUD returns at its original coordinates")
T.eq(#hpBars, 2, "classic battles receive both semantic HP bars")
T.same(hpBars[1], {
  tx = 2, ty = 2, hp = 4, maxHP = 40,
  barType = nil, grayFill = true, segments = 6,
}, "classic opponent colour reuses its original HP geometry")
T.same(hpBars[2], {
  tx = 10, ty = 8, hp = 36, maxHP = 40,
  barType = 1, grayFill = true, segments = 6,
}, "classic player colour reuses its extended original HUD geometry")
T.eq(#marks, 3,
  "classic HP and EXP colours survive the engine's palette-zone pass")
T.same(sprites[1], { x = 8 + Font.width(battle.enemy.name) + 2, y = 0 },
  "classic caught marker sits beside the opponent name rather than level")
T.same({ rectangles[2].x, rectangles[2].y, rectangles[2].w,
    rectangles[2].h }, { 64, 90, 80, 1 },
  "classic EXP seats into the original player HUD's lower rule")
local zoneResult = BattleState.drawZonePass(battle, "classic-bg", 0, 0)
T.eq(zoneResult, "zone-native",
  "classic palette enhancement preserves the original zone-pass result")
T.eq(#nativeZoneCalls, 1,
  "the normal renderer still performs its original palette pass once")
T.same({ rectangles[#rectangles].x, rectangles[#rectangles].y,
    rectangles[#rectangles].w, rectangles[#rectangles].h },
  { 64, 90, 3, 1 },
  "the blue EXP pixels are reseated after classic battle colorization")
T.check(rectangles[#rectangles].color[3] > 0.7
    and rectangles[#rectangles].color[1] < 0.3,
  "the reseated classic EXP fill remains blue")
T.eq(#marks, 4,
  "the reseated EXP pixels remain protected in the final frame pass")

local savedDebug = rawget(_G, "debug")
_G.debug = nil
local noDebugOk, noDebugErr = pcall(function()
  BattleState.drawHUDs(battle, 0)
end)
_G.debug = savedDebug
T.check(noDebugOk,
  "classic battle entry works without the optional debug library ("
    .. tostring(noDebugErr) .. ")")

rows[2].step(game, 1)
rectangles, texts, hpBars, marks, sprites, canvasCalls =
  {}, {}, {}, {}, {}, {}
nativeClassicCalls, canvasClears, compositeDraws = {}, {}, {}
BattleState.drawHUDs(battle, 0)
T.eq(nativeClassicCalls[1].enemyStatus, "SLP",
  "OFF restores the untouched classic status behavior")
T.eq(#canvasClears, 0,
  "OFF bypasses the private HUD layer in classic battles")
T.eq(#hpBars, 0, "OFF removes all classic HUD additions")
rows[2].step(game, 1)

local nativeForkProbe
local nativeFork = {
  hudTexture = function()
    if nativeForkProbe then nativeForkProbe() end
    return "native-1.8-layer"
  end,
  snapRects = function()
    return { player = { 12, 34, 56, 78 } },
      { player = { x = 12, y = 34, scale = 2 } }
  end,
}
local nativeForkTexture = nativeFork.hudTexture
local nativeForkSnapRects = nativeFork.snapRects
game.mods.exports.BATTLE_ART_VOXEL_FORK = {
  version = "1.8.7",
  lib = {
    require = function(name)
      if name == "OverworldBattle" then return nativeFork end
    end,
  },
}
battle.dramaticShapeShot = { live = true }
battle.letterboxWhite = false
Runtime.call("battle.overlay", function() end, battle)
T.check(nativeFork.hudTexture ~= nativeForkTexture,
  "Battle Art 1.8+ capture receives a coordinate-only compatibility guard")
T.eq(nativeFork.snapRects, nativeForkSnapRects,
  "Battle Art 1.8+ retains its native staged HUD placement")
T.eq(nativeFork.hudTexture(battle), "native-1.8-layer",
  "Battle Art 1.8+ native staged HUD remains callable")

local forkTextureArgs, forkFlipCalls = {}, {}
local forkTextureProbe
local fork = {
  hudTexture = function(_, ...)
    forkTextureArgs = { ... }
    if forkTextureProbe then forkTextureProbe() end
    return "fork-layer"
  end,
  snapRects = function()
    return {
      enemy = { 0, 0, 320, 128 },
      player = { 688, 272, 352, 160 },
    }, {
      enemy = { x = 0, y = 0, scale = 4 },
      player = { x = 400, y = 240, scale = 4 },
    }
  end,
}
local forkHud = {
  flipGlyphs = function(w, h, draw, inverted, inkOnly, colorShadow)
    forkFlipCalls[#forkFlipCalls + 1] = {
      w = w, h = h, inverted = inverted,
      inkOnly = inkOnly, colorShadow = colorShadow,
    }
    draw()
  end,
}
game.mods.exports.BATTLE_ART_VOXEL_FORK = {
  version = "1.7.9",
  lib = {
    require = function(name)
      if name == "OverworldBattle" then return fork end
      if name == "BattleHud" then return forkHud end
    end,
  },
}
battle.dramaticShapeShot = { live = true }
battle.letterboxWhite = false
Runtime.call("battle.overlay", function() end, battle)
rectangles, texts, hpBars, marks, sprites, canvasCalls =
  {}, {}, {}, {}, {}, {}
T.eq(fork.hudTexture(battle, 0, true, false, true), "fork-layer",
  "a compatible fork keeps its original HUD texture result")
T.same(forkTextureArgs, { 0, true, false, true },
  "newer fork HUD contrast arguments pass through unchanged")
T.same(forkFlipCalls[1], {
  w = 160, h = 144, inverted = false,
  inkOnly = nil, colorShadow = true,
}, "fork additions reuse its complete colour-shadow glyph processor")
local forkRects = fork.snapRects({ scale = 5, ly = 10 })
T.same(forkRects.player, { 624, 240, 416, 192 },
  "fork player frost follows its independent band scale and placement")
T.same({ rectangles[1].x, rectangles[1].y, rectangles[1].w,
    rectangles[1].h, rectangles[1].color[4] }, { 56, 48, 104, 48, 0 },
  "the fork's original player HUD clears before contrast-processed redraw")
T.same({ rectangles[4].x, rectangles[4].y, rectangles[4].w,
    rectangles[4].h }, { 32, 19, 4, 2 },
  "the dark fork restores the enemy semantic HP fill inside native outlines")
T.same({ rectangles[5].x, rectangles[5].y, rectangles[5].w,
    rectangles[5].h }, { 96, 67, 43, 2 },
  "the dark fork restores the player semantic HP fill inside native outlines")
T.check(rectangles[5].color[2] > 0.7 and rectangles[5].color[1] == 0,
  "the restored healthy fill remains green rather than contrast-flipped white")

local genderOverlayCalls = {}
local genderOverlayCoordinateProbe
local genderHud = {
  classicGenderXY = function(side)
    if side == "enemy" then return 24, 8 end
    return 104, 64
  end,
  wideGenderXY = function(side)
    if side == "enemy" then return 80, 8 end
    return 256, 64
  end,
  drawOverlay = function(b)
    local playerXY
    if genderOverlayCoordinateProbe then
      playerXY = { genderOverlayCoordinateProbe() }
    end
    genderOverlayCalls[#genderOverlayCalls + 1] = {
      enemyStatus = b.enemy.shownStatus,
      playerStatus = b.player.shownStatus,
      playerXY = playerXY,
    }
    return "gender-overlay"
  end,
}
game.mods.exports.gender_mod = { BattleHUD = genderHud }
battle.dramaticShapeShot = nil
battle.letterboxWhite = true
Runtime.call("battle.overlay", function() end, battle)
local gx, gy = genderHud.classicGenderXY("player", battle.player.mon.level)
T.same({ gx, gy }, { 104, 56 },
  "Gender Mod player marker follows the raised classic level row")
local nativeStagedGenderXY
nativeForkProbe = function()
  nativeStagedGenderXY = {
    player = {
      genderHud.classicGenderXY("player", battle.player.mon.level),
    },
    enemy = {
      genderHud.classicGenderXY("enemy", battle.enemy.mon.level),
    },
  }
end
T.eq(nativeFork.hudTexture(battle), "native-1.8-layer",
  "Battle Art 1.8+ still returns its native staged HUD layer")
nativeForkProbe = nil
T.same(nativeStagedGenderXY, {
  player = { 105, 64 }, enemy = { 25, 8 },
}, "Battle Art 1.8+ seats both gender markers tightly beside level")
gx, gy = genderHud.classicGenderXY("player", battle.player.mon.level)
T.same({ gx, gy }, { 104, 56 },
  "the native staged guard restores enhanced classic coordinates afterward")
gx, gy = genderHud.wideGenderXY("player", battle.player.mon.level)
T.same({ gx, gy }, { 256, 56 },
  "Gender Mod player marker follows the raised wide level row")
gx, gy = genderHud.classicGenderXY("enemy", battle.enemy.mon.level)
T.same({ gx, gy }, { 24, 8 },
  "Gender Mod opponent marker retains its native level-row position")
battle.dramaticShapeShot = { live = true }
battle.letterboxWhite = false
genderOverlayCoordinateProbe = function()
  return genderHud.classicGenderXY("player", battle.player.mon.level)
end
T.eq(genderHud.drawOverlay(battle), "gender-overlay",
  "Gender Mod overlay result is preserved by the compatibility bridge")
genderOverlayCoordinateProbe = nil
battle.dramaticShapeShot = nil
battle.letterboxWhite = true
T.same(genderOverlayCalls[1], {
  enemyStatus = nil, playerStatus = nil, playerXY = { 105, 64 },
}, "Gender Mod's coloured voxel pass is seated beside the stock level row")
gx, gy = genderHud.classicGenderXY("player", battle.player.mon.level)
T.same({ gx, gy }, { 104, 56 },
  "the coloured voxel pass restores the classic coordinate afterward")
T.eq(battle.enemy.shownStatus, "SLP",
  "Gender compatibility restores opponent status after drawing")
T.eq(battle.player.shownStatus, "PSN",
  "Gender compatibility restores player status after drawing")

rows[2].step(game, 1)
gx, gy = genderHud.classicGenderXY("player", battle.player.mon.level)
T.same({ gx, gy }, { 104, 64 },
  "OFF restores Gender Mod's stock player coordinate")
genderHud.drawOverlay(battle)
T.same(genderOverlayCalls[2], {
  enemyStatus = "SLP", playerStatus = "PSN",
}, "OFF restores Gender Mod's native status suppression behavior")
rows[2].step(game, 1)

battle.dramaticShapeShot = { live = true }
battle.letterboxWhite = false
canvasCreates, canvasClears, compositeDraws, canvasCalls = {}, {}, {}, {}
rectangles, texts, hpBars, marks, sprites = {}, {}, {}, {}, {}
local stagedGenderXY
forkTextureProbe = function()
  stagedGenderXY = {
    genderHud.classicGenderXY("player", battle.player.mon.level),
  }
end
fork.hudTexture(battle, 0, true, false)
forkTextureProbe = nil
local copiedGender
for _, call in ipairs(compositeDraws) do
  if call.x == 104 and call.y == 56 and call.canvas == "fork-layer" then
    copiedGender = call.drawable
    break
  end
end
T.same(stagedGenderXY, { 0, 87 },
  "Gender Mod paints into a clean scratch cell during voxel capture")
local clearedGenderScratch = false
for _, rect in ipairs(rectangles) do
  if rect.x == 0 and rect.y == 87 and rect.w == 9 and rect.h == 9
      and rect.color[4] == 0 then
    clearedGenderScratch = true
    break
  end
end
T.check(clearedGenderScratch,
  "the temporary Gender Mod scratch cell is removed before band placement")
T.check(copiedGender and copiedGender.width == 9
    and copiedGender.height == 9,
  "staged HUD preserves Gender Mod's 8px marker and fork shadow edge")
T.same({ copiedGender and copiedGender.minFilter,
    copiedGender and copiedGender.magFilter },
  { "nearest", "nearest" },
  "staged Gender Mod marker remains on the native pixel grid")

Font.drawBox, Font.draw = realDrawBox, realDraw
HudTiles.drawHPBar = realDrawHPBar
love.graphics.setColor = realSetColor
love.graphics.rectangle = realRectangle
love.graphics.getScissor = realGetScissor
love.graphics.setScissor = realSetScissor
love.graphics.getCanvas = realGetCanvas
love.graphics.setCanvas = realSetCanvas
love.graphics.newCanvas = realNewCanvas
love.graphics.clear = realClear
love.graphics.draw = realGraphicsDraw
PaletteFX.markTrueColor = realMark
BattleState.drawHUDs = realClassicDrawHUDs
BattleState.drawZonePass = realClassicZonePass
WideBattle.draw = realWideDraw

T.finish("battle_info_hud")
