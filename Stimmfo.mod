return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Stimmfo` encountered an error loading the Darktide Mod Framework.")

		new_mod("Stimmfo", {
			mod_script       = "Stimmfo/scripts/mods/Stimmfo/Stimmfo",
			mod_data         = "Stimmfo/scripts/mods/Stimmfo/Stimmfo_data",
			mod_localization = "Stimmfo/scripts/mods/Stimmfo/Stimmfo_localization",
		})
	end,
	packages = {},
}
