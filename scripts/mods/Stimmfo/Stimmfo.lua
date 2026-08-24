--[[
  Name: Stimmfo
  Author: Wobin
  Date: 24/08/2026
  Repository: https://github.com/Wobin/Stimmfo
]]--

local mod = get_mod("Stimmfo")
mod.version = mod.get_metadata and mod:get_metadata("version") or "unknown"

local broker_settings_ok, BrokerTalentSettings = pcall(require, "scripts/settings/talent/talent_settings_broker")

local STIMM_SLOT = "slot_pocketable_small"
local LOC_BRAIN_RUPTURE = "loc_talent_psyker_brain_burst_improved"
local BROKER_DURATION_PASSIVE = "broker_passive_stimm_increased_duration"
local BROKER_BASE_DURATION = 15
local BROKER_DURATION_BONUS = 5

local player

local hud_element_settings = {
  class_name = "Stimmformation",
  filename = "Stimmfo/scripts/mods/Stimmfo/Stimmformation",
  use_hud_scale = true,
  use_retained_mode = false,
  visibility_groups = {
    "alive"
  },
  validation_function = function() return not mod.in_hub() end
}

mod.in_hub = function()
  local gm = Managers.state and Managers.state.game_mode
  if not gm then return true end
  return gm:game_mode_name() == "hub"
end

mod.getPlayer = function(self)
  if player then return player end
  player = Managers.player and Managers.player:local_player_safe(1)
  return player
end

mod.getBrokerMix = function(self, local_player)
  local unit = local_player and local_player.player_unit
  local talent_extension = unit and ScriptUnit.has_extension(unit, "talent_system")
  local stimm = broker_settings_ok and BrokerTalentSettings and BrokerTalentSettings.broker_stimm

  if not talent_extension or not stimm or not talent_extension.buff_template_tier then
    return ""
  end

  local best = {}

  for talent_name, data in pairs(stimm) do
    local tier = talent_extension:buff_template_tier(talent_name)
    local talent_data = tier and tier > 0 and data.talent_data
    local key = talent_data and talent_data.display_name

    if key then
      local rank = tonumber(string.match(talent_name, "_(%d+)%a?$")) or tier

      if not best[key] or rank > best[key].rank then
        best[key] = { rank = rank, format_values = talent_data.format_values }
      end
    end
  end

  local branches = {}

  for key, entry in pairs(best) do
    branches[#branches + 1] = Localize(key, true, entry.format_values)
  end

  if #branches == 0 then return "" end

  table.sort(branches)

  local duration = BROKER_BASE_DURATION
  local bonus = talent_extension:buff_template_tier(BROKER_DURATION_PASSIVE)

  if bonus and bonus > 0 then
    duration = duration + BROKER_DURATION_BONUS
  end

  return "[" .. duration .. "s] [" .. table.concat(branches, " / ") .. "]"
end

mod.getStimmfo = function(self)
  local local_player = self:getPlayer()
  local prof = local_player and local_player:profile()

  if self._cached_stimm == self.stimmName and self._cached_profile == prof then
    return self._cached_info
  end

  local infoString = ""

  if not prof then return infoString end

  if self.stimmName == "syringe_broker_pocketable" then
    infoString = self:getBrokerMix(local_player)
  elseif self.stimmName == "syringe_corruption_pocketable" then
    infoString = "[+25% "..self:localize("health_or_one_segment") .."]"
  elseif self.stimmName == "syringe_ability_boost_pocketable" then
    infoString = "[+300% " .. self:localize("ability_cooldown").."]"
  elseif self.stimmName == "syringe_power_boost_pocketable" then
    local archetype_name = prof.archetype and prof.archetype.name or ""
    if archetype_name:match("psyker") then
      infoString = "[-34% "..self:localize("peril_gen") .."] "
    end
    infoString = infoString .. "[+25% "..self:localize("power_rending").."]"
  elseif self.stimmName == "syringe_speed_boost_pocketable" then
    local archetype_name = prof.archetype and prof.archetype.name or ""
    local secondary = prof.loadout_item_data and prof.loadout_item_data.slot_secondary
    local secondary_id = secondary and secondary.id or ""
    local talents = prof.talents or {}
    local has_staff = secondary_id:match("staff")

    infoString = self:localize("stamina")..":[100% ".. self:localize("restore").. "] [-50% ".. self:localize("sprint").."] [-25% "..self:localize("push_block").."] "..self:localize("speed")..":"
    if secondary_id:match("plasma") then
      infoString = infoString .. " [+25% ".. self:localize("plasma_charge") .."]"
    end
    if archetype_name:match("psyker") then
      infoString = infoString .. " [+25% "..self:localize("quell")
      if has_staff then
        infoString = infoString .. self:localize("staff")
      end
      if talents.psyker_brain_burst_improved then
        infoString = infoString .. "/" .. Localize(LOC_BRAIN_RUPTURE)
      elseif talents.psyker_grenade_throwing_knives then
        infoString = infoString .. self:localize("assail")
      elseif talents.psyker_grenade_chain_lightning then
        infoString = infoString .. self:localize("smite")
      else
        infoString = infoString .. self:localize("brain_burst")
      end
      infoString = infoString .. "]"
    end
    infoString = infoString .. " [+20% "..self:localize("attack") .."]"
    if not has_staff then
      infoString = infoString .. " [+15% "..self:localize("reload") .."]"
    end
  end

  self._cached_stimm = self.stimmName
  self._cached_profile = prof
  self._cached_info = infoString
  return infoString
end

mod.on_game_state_changed = function(status, state_name)
  if status == "exit" and state_name == "StateGameplay" then
    mod.stimmElement = nil
    mod.stimmPivot = nil
    mod.stimmName = nil
    mod.wielded = nil
    mod._cached_stimm = nil
    mod._cached_profile = nil
    mod._cached_info = nil
    player = nil
  end
end

mod.on_all_mods_loaded = function ()
  mod:info(mod.version)

  if not mod.register_hud_element then
    mod:echo("Not running latest dmf")
    return
  end

  mod:register_hud_element(hud_element_settings)

  mod:hook_safe("HudElementPlayerWeapon", "update", function(self, dt, t, ui_renderer)
    if self._slot_name == STIMM_SLOT then
      mod.stimmName = self._widgets_by_name.icon and self._widgets_by_name.background and self._data and self._data.item and self._data.item.weapon_template
    end
  end)

  mod:hook_safe("HudElementPlayerWeaponHandler", "_set_wielded_slot", function (self, wielded_slot)
    mod.wielded = wielded_slot == STIMM_SLOT
  end)

  mod:hook_safe("HudElementPlayerWeaponHandler", "_align_weapon_scenegraphs", function(self)
    local player_weapons_array = self._player_weapons_array

    for i = 1, #player_weapons_array do
      local data = player_weapons_array[i]

      if data.slot_id == STIMM_SLOT then
        mod.stimmElement = data.hud_element_player_weapon
        mod.stimmPivot = self._ui_scenegraph.weapon_pivot
        return
      end
    end

    mod.stimmElement = nil
    mod.stimmPivot = nil
    mod.stimmName = nil
    mod._cached_stimm = nil
    mod._cached_info = nil
  end)
end
