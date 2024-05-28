data:extend({
	{
		type = "bool-setting",
		name = "rf-compati",
		setting_type = "runtime-global",
		default_value = "true",
	},
	{
		type = "int-setting",
		name = "rf-delay",
		setting_type = "runtime-global",
		default_value = "60",
		minimum_value = "10",
		maximum_value = "1200"
	},
	{
		type = "int-setting",
		name = "rf-timer",
		setting_type = "runtime-global",
		default_value = "180",
		minimum_value = "10",
		maximum_value = "1200"
	},
	{
		type = "bool-setting",
		name = "rf-vehicles",
		setting_type = "startup",
		default_value = "false"
	},
	{
		type = "int-setting",
		name = "rf-efficiency",
		setting_type = "startup",
		default_value = "100",
		minimum_value = "10",
		maximum_value = "100"
	},
	{
		type = "bool-setting",
		name = "rf-prod-loop",
		setting_type = "startup",
		default_value = "false"
	},
	{
		type = "bool-setting",
		name = "rf-fluid-items",
		setting_type = "startup",
		default_value = "false"
	},
})