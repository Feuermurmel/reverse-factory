--Setup for the reverse factory item, entity, recipe, and technology
require("prototypes.pipe-covers")
require("prototypes.reverse-factory")
--Setup for the reverse recipe groups and categories
require("prototypes.catgroups")
--Insantiating tables needed for the rest of the mod to function
rf = {}
rf.recipes = {}
rf.vehicles = settings.startup["rf-vehicles"].value
rf.efficiency = settings.startup["rf-efficiency"].value
rf.noprod = settings.startup["rf-prod-loop"].value
rf.fluid_items = settings.startup["rf-fluid-items"].value
rf.fluidrecipe_list = {}
rf.norecycle_items = {}
rf.nofluid_items = {}
rf.norecycle_categories = {}
rf.norecycle_subgroups = {}
rf.custom_recycle = {}  --Format of {item-type, item-name, recipe-name}
rf.maxResults = {5,5,5,5}
rf.mod248k = false

--Prevents this mod's data-final-fixes from fully loading
rf.prevented_final_fixes = false
--If another mod lists this mod as an optional dependency (space-exploration-postprocess)
--Allows them to prevent this mod from loading, by running this in their data.lua
--Then, they can run this mod's final-fixes during their own final-fixes via "rf.final_fixes()"
--DO NOT USE THIS FUNCTION - DOWNLOAD reverse-factory-postprocess INSTEAD
function rf.prevent_final_fixes()
	rf.prevented_final_fixes = true
end

--If certain mods are detected, change some recipes later
if mods ["nullius"] then
	rf.mods = "nullius"
elseif mods["bobplates"] then
	rf.mods = "bobplates"
elseif mods["IndustrialRevolution"] then
	rf.mods = "DIR"
elseif mods["IndustrialRevolution3"] then
	rf.mods = "DIR3"
elseif mods["Fantario"] then
	rf.mods = "fantario"
elseif mods["bobassembly"] then
	rf.mods = "bobassembly"
end
if mods ["248k"] then
	rf.mod248k = true
end

--This is where the magic happens
require('dbug')
require('func')

--[[
    Construction Drones adds equipment grid to light armor
    This prevents light armor from being used in reverse recipe
    Robot Army uses light armor in droid-flame recipe
    Therefore, remove droid-flame recipe from being recycled in only this case
]]--
if mods["Construction_Drones"] and mods["robotarmy"] then
	table.insert(rf.norecycle_items, "droid-flame")
end
--Attach notes creates item version of this fluid, which does not have a canon recipe
if mods["bobplates"] and mods["attach-notes"] then
	table.insert(rf.norecycle_items, "heavy-water")
end
if mods["warptorio2"] then
	table.insert(rf.norecycle_items, "warptorio-armor")
end
if mods["anarchy"] then
	table.insert(rf.norecycle_items, "ultra-armor")
end
if mods["spaceblock"] then
	table.insert(rf.norecycle_items, "coal")
	table.insert(rf.norecycle_items, "copper-ore")
	table.insert(rf.norecycle_items, "iron-ore")
	table.insert(rf.norecycle_items, "stone")
	table.insert(rf.norecycle_items, "uranium-ore")
end
if mods["homeworld_redux"] then
	table.insert(rf.norecycle_categories, "seeder")
	table.insert(rf.norecycle_categories, "terraformer")
end
if mods ["pyhardmode"] then
	table.insert(rf.norecycle_items, "sweater")
end
if mods ["nullius"] then
	nulliusRecycling()
end

--Prevent duplication of crushed stone
table.insert(rf.norecycle_items, "stone-crushed")

--Prevent duplication of scrap recipes
table.insert(rf.norecycle_subgroups, "smelting_fantario")
table.insert(rf.norecycle_subgroups, "petrochem-catalysts")
table.insert(rf.norecycle_categories, "seed-extractor")
table.insert(rf.norecycle_categories, "fu_tokamak_reactor_crafting_category")

--Prevent these fluids from becoming items (they are unused)
table.insert(rf.nofluid_items, "ee-super-pump-speed-fluid")
table.insert(rf.nofluid_items, "fluid-unknown")

--Examples for adding custom recipes to reverse-factory, for external mod use.
--table.insert(rf.custom_recycle, {"item", "droid-smg-dummy", "droid-smg-deploy"})
--table.insert(rf.custom_recycle, {"item", "terminator-dummy", "terminator-deploy"})