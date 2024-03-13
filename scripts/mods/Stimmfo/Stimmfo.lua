-- Title: Stimmfo
-- Author: Wobin
-- Date: 11/03/2024
-- Version: 1.0

local HudElementPlayerWeaponHandlerSettings = require("scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings")

local mod = get_mod("Stimmfo")
local player
local hud_element_settings = {
  class_name = "Stimmformation",
  filename = "Stimmfo/scripts/mods/Stimmfo/Stimmformation",
  use_hud_scale = true,  -- optional
  use_retained_mode = false,  -- optional, used if your element also uses it (uncommon)
  visibility_groups = {
    "alive"
  }
}

mod.getPlayer = function(self)
  if player then return player end
  player = Managers.player:local_player(1)      
  mod:dump(player:profile().talents, "talents", 1)
  return player
end

mod.getStimmfo = function(self)
  local infoString = ""
  if mod.stimmName == "syringe_corruption_pocketable" then
    infoString = "[+25% "..mod:localize("health_or_one_segment") .."]"
  elseif mod.stimmName == "syringe_ability_boost_pocketable" then
    infoString = "[+300% " .. mod:localize("ability_cooldown").."]"
  elseif mod.stimmName == "syringe_power_boost_pocketable" then
    if mod:getPlayer():profile().archetype.archetype_name:match("psyker") then
      infoString = "[-33% "..mod:localize("peril_gen").."]"
    end
    infoString = infoString .. " [+25% "..mod:localize("power_rending").."]"
  elseif mod.stimmName == "syringe_speed_boost_pocketable" then
    infoString = mod:localize("stamina")..":[-25% "..mod:localize("push_block").."] [-50% ".. mod:localize("sprint").."] "..mod:localize("speed")..":[+20% "..mod:localize("attack").."]"
    if not mod:getPlayer():profile().loadout_item_data.slot_secondary.id:match("staff") then
      infoString = infoString .. " [+15% "..mod:localize("reload") .."]"
    end
    if mod:getPlayer():profile().loadout_item_data.slot_secondary.id:match("plasma") then
      infoString = infoString .. " [+25% ".. mod:localize("plasma_charge").."]"
    end
    if mod:getPlayer():profile().loadout_item_data.slot_secondary.id:match("staff") then
      infoString = infoString .. " [+25% ".. mod:localize("staff").."]"
    end
    if mod:getPlayer():profile().talents.psyker_brain_burst_improved then
      infoString = infoString .. " [+25% "..mod:localize("brain_burst").."]"
    end
    if mod:getPlayer():profile().talents.psyker_grenade_throwing_knives then
      infoString = infoString .. " [+25% "..mod:localize("assail").."]"
    end
    if mod:getPlayer():profile().talents.psyker_grenade_chain_lightning then
      infoString = infoString .. " [+25% "..mod:localize("smite").."]"
    end
    if mod:getPlayer():profile().archetype.archetype_name:match("psyker") then
      infoString = infoString .. " [+25% "..mod:localize("quell").."]"
    end
  
  end
  return infoString
end

mod.on_all_mods_loaded = function ()
  
  if not mod.register_hud_element then 
    mod:echo("Not running latest dmf")
    return 
  end
  
  mod:register_hud_element(hud_element_settings)
  mod:hook_safe("HudElementPlayerWeapon", "update", function(self, dt, t, ui_renderer)	  
    if self._slot_name == "slot_pocketable_small" then  
      mod.stimmName = self._widgets_by_name.icon and self._widgets_by_name.background and self._data and self._data.item and self._data.item.weapon_template
    end
  end)  

  mod:hook_safe("HudElementPlayerWeaponHandler", "_set_wielded_slot", function (self, wielded_slot)
            mod.wielded = wielded_slot == "slot_pocketable_small"      
  end)
  mod:hook_safe("HudElementPlayerWeaponHandler", "_align_weapon_scenegraphs", function(self)
    local foundSyringe = false
    local ui_scenegraph = self._ui_scenegraph
    local scenegraph_id = "weapon_pivot"
    local scenegraph_settings = ui_scenegraph[scenegraph_id]
    local horizontal_alignment = scenegraph_settings.horizontal_alignment
    local vertical_alignment = scenegraph_settings.vertical_alignment
    local pivot_position = scenegraph_settings.position
    local start_x = pivot_position[1]
    local start_y = pivot_position[2]
    local offset_x = 0
    local offset_y = 0
    local weapon_spacing = HudElementPlayerWeaponHandlerSettings.weapon_spacing
    local player_weapons_array = self._player_weapons_array
      
    for index, data in ipairs(player_weapons_array) do
      
      if data.slot_id == "slot_pocketable_small" then           
        offset_y = -(index - 1) * (HudElementPlayerWeaponHandlerSettings.size_small[2] + weapon_spacing[2])
        local x = start_x + offset_x
        local y = start_y + offset_y
        mod.newPosition = {x, y, 0}
        foundSyringe = true
      end
    end
    if not foundSyringe then mod.newPosition = nil end
  end)
end