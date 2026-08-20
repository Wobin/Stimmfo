local mod = get_mod("Stimmfo")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local definitions = {
  scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    stimmformation = {
      parent = "screen",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { tonumber(mod:localize("size")) or 240, 64 },
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
        visibility_function = function() return mod.showStimmfo == true end,
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
  local element = mod.stimmElement
  local pivot = mod.stimmPivot
  local widget = self._widgets_by_name.stimmformation
  local info = ""

  if element and pivot and not mod.in_hub() then
    info = mod:getStimmfo()
  end

  mod.showStimmfo = info ~= ""

  if not mod.showStimmfo then
    widget.content.text_value = info
    Stimmformation.super.update(self, ...)
    return
  end

  local wielded = mod.wielded
  local pivot_position = pivot.position
  local x = pivot_position[1] - 50
  local y = pivot_position[2] + (element._height_offset or 0)

  if wielded then
    x = x - 40
    y = y - 5
  else
    y = y + 10
  end

  if self._last_wielded ~= wielded then
    widget.style.text_style.font_size = wielded and 15 or 12
    self._last_wielded = wielded
  end

  self:set_scenegraph_position("stimmformation", x, y, 0, pivot.horizontal_alignment, pivot.vertical_alignment)

  widget.content.text_value = info
  Stimmformation.super.update(self, ...)
end

return Stimmformation
