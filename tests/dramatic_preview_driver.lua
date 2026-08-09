-- Visual QA against a locally installed Dramatic Shape mod.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local BattleState = require("src.battle.BattleState")
  local Growth = require("src.pokemon.Growth")
  local Pokemon = require("src.pokemon.Pokemon")
  local DIR = os.getenv("SHOT_DIR") or "/tmp/battle-info-hud-dramatic"

  if os.getenv("USER_VIEWPORT") == "1" then
    love.window.setMode(1726, 1090, {
      resizable = true, minwidth = 640, minheight = 576,
      vsync = os.getenv("POKEPORT_QA_NO_VSYNC") == "1" and 0 or 1,
    })
    game.save.options = game.save.options or {}
    game.save.options.battleFit = "fill"
  end

  local player = Pokemon.new(game.data, "RATTATA", 12)
  player.name = "NORBIE"
  -- Keep the comparison fixture identical to the user's annotated capture;
  -- generated DVs otherwise make this alternate between 29 and 30 max HP.
  player.stats.hp = 29
  player.hp = 20
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

  U.teleport(game, "ROUTE_1", 5, 8, "down")
  U.wait(90)
  local battle = BattleState.newWild(game, "PIDGEY", 3,
    { onFinish = function() end })
  game.overworld:pushBattle(battle)
  U.wait(70)
  for _ = 1, 14 do U.tap(game, "a"); U.wait(8) end

  battle.introSlide = 0
  battle.introBalls = nil
  battle.showEnemyTrainer = false
  battle.showPlayerBack = false
  battle.enemySendingOut = false
  battle.sendingOut = false
  battle.enemy.shownStatus = "SLP"
  battle.player.shownStatus = "PSN"
  U.wait(12)

  local exports = game.mods and game.mods.exports
  local companion
  for _, id in ipairs({
    "DRAMATIC_SHAPE", "BATTLE_ART_VOXEL_FORK", "DRAMALESS_SHAPE",
  }) do
    if exports and exports[id] then companion = id break end
  end
  U.log(companion and ("PASS staged companion is active: " .. companion)
    or "FAIL no compatible staged companion is active")
  U.shot(game, DIR .. "/battle_info_hud_dramatic.png")
end
