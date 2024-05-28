data:extend({
  {
		type = "bool-setting",
		name = "rf-dynamic",
		setting_type = "startup",
		default_value = "false",
	},
	{
		type = "bool-setting",
		name = "rf-difficulty",
		setting_type = "startup",
		default_value = "true",
	},
	{
		type = "bool-setting",
		name = "rf-compat",
		setting_type = "runtime-global",
		default_value = "false",
	},
	{
		type = "int-setting",
		name = "rf-delay",
		setting_type = "runtime-global",
		default_value = "300",
		minimum_value = "30",
		maximum_value = "1200"
	},
})