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
rf.intermediates = settings.startup["rf-intermediates"].value
rf.norecycle_items = {}
rf.norecycle_categories = {}
--table.insert(rf.norecycle_items, "electronic-circuit")
table.insert(rf.norecycle_categories, "recycle")
table.insert(rf.norecycle_categories, "recycle-with-fluids")
table.insert(rf.norecycle_categories, "oil-processing")
--table.insert(rf.norecycle_categories, "centrifuging")
--table.insert(rf.norecycle_categories, "smelting")