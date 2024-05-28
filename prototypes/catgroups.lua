data:extend({
--Categories for reverse recipes, used to define tiers
	{
		type = "recipe-category",
		name = "recycle-products"
	},
	{
		type = "recipe-category",
		name = "recycle-intermediates"
	},
	{
		type = "recipe-category",
		name = "recycle-with-fluids"
	},
	{
		type = "recipe-category",
		name = "recycle-productivity"
	},
	{
		type = "recipe-category",
		name = "recycle-unbarreling"
	},
--Hidden group and subgroup which contains the reverse recipes
	{
		type = "item-group",
		name = "recycling",
		icon = "__reverse-factory__/graphics/technology/reverse-factory.png",
		icon_size = 128,
		order = "z",
	},
	{
		type = "item-subgroup",
		name = "recycling",
		group = "recycling",
		order = "z",
	}
})
