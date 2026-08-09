-- Visual QA for Battle Info HUD. Run from the repository root:
--   SHOT_DIR=/tmp/battle-info-hud \
--   POKEPORT_DRIVER=mods/battle_info_hud/tests/preview_driver.lua \
--   POKEPORT_IDENTITY=battle-info-hud-preview POKEPORT_VERSION=red love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local BattleState = require("src.battle.BattleState")
  local Growth = require("src.pokemon.Growth")
  local PaletteFX = require("src.render.PaletteFX")
  local Pokemon = require("src.pokemon.Pokemon")
  local DIR = os.getenv("SHOT_DIR") or "/tmp/battle-info-hud"

  love.window.setMode(1280, 720, {
    resizable = true, minwidth = 640, minheight = 576,
  })
  game.save.options = game.save.options or {}
  game.save.options.colors = "redpp"
  game.save.options.battleLayout = "og"
  PaletteFX.setMode("redpp")

  local player = Pokemon.new(game.data, "RATTATA", 12)
  player.name = "NORBIE"
  player.hp = math.max(1, math.floor(player.stats.hp * 0.72))
  player.status = "PSN"
  local def = game.data.pokemon[player.species]
  local floorExp = Growth.expForLevel(def.growthRate, player.level,
    game.data.growth_rates)
  local nextExp = Growth.expForLevel(def.growthRate, player.level + 1,
    game.data.growth_rates)
  player.exp = floorExp + math.floor((nextExp - floorExp) * 0.58)
  game.save.party = { player }
  game.save.pokedex = game.save.pokedex or { seen = {}, owned = {} }
  game.save.pokedex.owned = game.save.pokedex.owned or {}
  game.save.pokedex.owned.PIDGEY = true

  while game.stack:top() do game.stack:pop() end
  local battle = BattleState.newWild(game, "PIDGEY", 3,
    { onFinish = function() end })
  game.stack:push(battle)
  U.wait(8)
  battle.introSlide = 0
  battle.introBalls = nil
  battle.showEnemyTrainer = false
  battle.showPlayerBack = false
  battle.enemySendingOut = false
  battle.sendingOut = false
  battle.phase = "messages"
  battle.enemy.shownStatus = "SLP"
  battle.player.shownStatus = "PSN"
  battle.dramaticShapeShot = { live = true }
  U.wait(8)
  U.log("PASS native classic HUD enhancement prepared")
  U.shot(game, DIR .. "/battle_info_hud_staged.png")

  battle.dramaticShapeShot = nil
  U.wait(12)
  U.log("PASS no-companion classic HUD enhancement prepared")
  U.shot(game, DIR .. "/battle_info_hud_classic.png")

  game.save.options.battleLayout = "wide"
  U.wait(12)
  U.log("PASS native wide HUD enhancement prepared")
  U.shot(game, DIR .. "/battle_info_hud_wide.png")
end
