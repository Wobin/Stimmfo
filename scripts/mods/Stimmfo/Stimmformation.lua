local mod = get_mod("Stimmfo")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local definitions = {    -- typically housed in a separate file and executed via `mod:io_dofile`
  scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    stimmformation = {
      parent = "screen",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 180, 64 },
      position = { 0, 0, 0 }
    }
  },
  widget_definitions = {
    stimmformation = UIWidget.create_definition({
      {
        style_id = "text_style",
        pass_type = "text",
        value_id = "text_value",
        value = "Stimm Info",
        visibility_function = function() return mod.newPosition end,        
        style = {
          font_size = 12,
          font_type = "machine_medium",
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          text_color = Color.ui_terminal(255, true),
          offset = { 0, 0, 0 }
        }       
      }
    }, "stimmformation")
  }
}

local Stimmformation = class("Stimmformation", "HudElementBase")

function Stimmformation:init(parent, draw_layer, start_scale)
  Stimmformation.super.init(self, parent, draw_layer, start_scale, definitions)
end

function Stimmformation:update(...)  
  if mod.newPosition == -1 or not mod.newPosition then return end
  local wanted_position = mod.newPosition
  
  local x, y, z = wanted_position[1], wanted_position[2] - 20 , wanted_position[3]
    
  local horizontal_alignment = "right"
  local vertical_alignment = "bottom"  
  
  if mod.wielded then 
    x = x - 40 
    y = y + 15
    self._widgets_by_name.stimmformation.style.text_style.font_size = 15    
  else
    self._widgets_by_name.stimmformation.style.text_style.font_size = 12    
  end
  
  self:set_scenegraph_position("stimmformation", x -50 , y , z, horizontal_alignment, vertical_alignment)
  
  self._widgets_by_name.stimmformation.content.text_value = mod:getStimmfo()
  Stimmformation.super.update(self, ...)
end --]]
return Stimmformation