-- Battle Info HUD is presentation-only. It adds one saved switch to the
-- standard Options menu and enhances the battle renderer's existing HUD.
return function(mod)
  local optionSchema = {
    { key = "enabled", label = "BATTLE INFO", type = "toggle",
      default = true },
  }
  mod.options:define(optionSchema)

  local function setOption(game, value)
    local options = game and game.save and game.save.options
    if options then
      options.modOptions = options.modOptions or {}
      options.modOptions[mod.id] = options.modOptions[mod.id] or {}
      options.modOptions[mod.id].enabled = value
    end
    local loader = game and game.mods
    if loader then
      loader.modOptions = loader.modOptions or {}
      loader.modOptions[mod.id] = loader.modOptions[mod.id] or {}
      loader.modOptions[mod.id].enabled = value
      if loader.events then
        loader.events:emit("mod.options_changed",
          { mod = mod.id, key = "enabled", value = value })
      end
    end
  end

  mod.hooks:wrap("ui.options.rows", function(next, game, rows)
    local out = next(game, rows)
    if type(out) ~= "table" then return out end
    out[#out + 1] = {
      id = "battle_info_hud_enabled",
      label = "BATTLE INFO",
      value = function()
        return mod.options:get("enabled") and "ON" or "OFF"
      end,
      step = function(g)
        setOption(g, not mod.options:get("enabled"))
        return true
      end,
    }
    return out
  end)

  local source, readErr = mod:read("hud.lua")
  if not source then
    mod.log:error("hud.lua is missing (%s); reinstall the mod",
      tostring(readErr or "unknown read error"))
    return
  end
  local chunk, compileErr = load(source, "@" .. mod.path .. "/hud.lua")
  if not chunk then
    mod.log:error("hud.lua did not compile: %s", tostring(compileErr))
    return
  end
  local ok, install = pcall(chunk)
  if not ok or type(install) ~= "function" then
    mod.log:error("hud.lua must return an installer: %s", tostring(install))
    return
  end
  local installed, installErr = pcall(install, mod)
  if not installed then
    mod.log:error("battle information HUD failed: %s", tostring(installErr))
    return
  end
  mod.log:info("optional native battle HUD enhancements enabled")
end
