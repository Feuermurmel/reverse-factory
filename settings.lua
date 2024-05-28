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
		name = "rf-compati",
		setting_type = "runtime-global",
		default_value = "true",
	},
	{
		type = "int-setting",
		name = "rf-delays",
		setting_type = "runtime-global",
		default_value = "30",
		minimum_value = "10",
		maximum_value = "1200"
	},
})