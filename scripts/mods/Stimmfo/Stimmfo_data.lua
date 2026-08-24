local mod = get_mod("Stimmfo")

return {
	name = "Stimmfo",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "stimmfo_broker_colour_mode",
				type = "dropdown",
				default_value = "off",
				options = {
					{ text = "stimmfo_broker_colour_mode_off", value = "off", show_widgets = {} },
					{ text = "stimmfo_broker_colour_mode_on", value = "on", show_widgets = { 1, 2, 3, 4 } },
				},
				sub_widgets = {
					{
						setting_id = "stimmfo_broker_colour_combat",
						type = "color",
						default_value = { 255, 230, 0, 0 },
						has_alpha = false,
					},
					{
						setting_id = "stimmfo_broker_colour_concentration",
						type = "color",
						default_value = { 255, 0, 191, 191 },
						has_alpha = false,
					},
					{
						setting_id = "stimmfo_broker_colour_durability",
						type = "color",
						default_value = { 255, 0, 191, 0 },
						has_alpha = false,
					},
					{
						setting_id = "stimmfo_broker_colour_celerity",
						type = "color",
						default_value = { 255, 199, 224, 20 },
						has_alpha = false,
					},
				},
			},
		},
	},
}
