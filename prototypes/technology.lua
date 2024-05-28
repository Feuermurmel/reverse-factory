data:extend({
--TECHNOLOGY
{
    type = "technology",
    name = "reverse-factory-1",
    icon = "__reverse-factory__/graphics/technology/reverse-factory.png",
	icon_size = 128,
	upgrade="true",
    prerequisites = {"automation", "electronics"},
    effects =
    {
        {
          type = "unlock-recipe",
          recipe = "reverse-factory-1"
        }
    },		 
    unit =
    {
        count = 80,
        ingredients =
        {
            {"science-pack-1", 1},
        },
        time = 15
    }
},
{
    type = "technology",
    name = "reverse-factory-2",
    icon = "__reverse-factory__/graphics/technology/reverse-factory.png",
	icon_size = 128,
	upgrade="true",
    prerequisites = {"automation-2", "advanced-electronics", "steel-processing","reverse-factory-1"},
    effects =
    {
        {
          type = "unlock-recipe",
          recipe = "reverse-factory-2"
        }
    },		 
    unit =
    {
        count = 120,
        ingredients =
        {
            {"science-pack-1", 1},
            {"science-pack-2", 1},
        },
        time = 15
    }
}
})
