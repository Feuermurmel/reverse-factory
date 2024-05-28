--Setup for the reverse factory item, entity, recipe, and tech
require("prototypes.technology")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.pipe-covers")
require("prototypes.entity")
--Setup for the reverse recipe groups and categories
require("prototypes.catgroups")

rf = {}
rf.recipes = {}
rf.safety = settings.startup["rf-safety"].value
rf.vehicles = settings.startup["rf-vehicles"].value