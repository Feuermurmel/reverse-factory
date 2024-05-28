require "util"

require("base-alter")

--Realistic Reverse Factory
require("prototypes.pipe-covers")
require("prototypes.category")
require("prototypes.entity")
require("prototypes.group")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.technology")
data:extend({
	{
    type = "item-group",
    name = "recycling",
    icon = "__core__/graphics/questionmark.png",
    icon_size = 64,
    order = "z",
  },
  {
    type = "item-subgroup",
    name = "recycling",
    group = "recycling",
    order = "z",
  },
})

rf = {}
rf.dynamic = settings.startup["rf-dynamic"].value
rf.difficulty = settings.startup["rf-difficulty"].value