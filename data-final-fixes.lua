local Recipe = require('__stdlib__/stdlib/data/recipe')
local Technology = require('__stdlib__/stdlib/data/technology')

--List of recipes that need to be manually added to the list
--  These technically could/should be added by the original mod author
--  but it's faster to add them myself.
require("prototypes/added_manual_recipes")

if mods["IndustrialRevolution"] then
	--Hide and disable the scrapper recipe
	Recipe("iron-scrapper"):remove_unlock("automation-2")
	Recipe("iron-scrapper"):set_enabled(false)
	data.raw.recipe["iron-scrapper"].hidden = true

	local scraplist = {"iron","copper","tin","gold","bronze","steel","lead","glass","titanium","duranium","stainless"}
	if data.raw.item["tantalum-ingot"] and data.raw.item["tantalum-scrap"] then table.insert(scraplist,"tantalum") end
	for _, material in pairs(scraplist) do
		name = material.."-ingot-from-scrap"
		Recipe(name):set_enabled(false)
		Recipe(name):set_field("hidden", true)
		--data.raw.recipe[name].hidden = true
		for _, tech in pairs(data.raw.technology) do
			if tech.effects then
				for _, unlock in pairs(tech.effects) do
					if unlock.type == "unlock-recipe" then
						if unlock.recipe == name then
							Recipe(unlock.recipe):remove_unlock(tech)
							Technology(tech):remove_effect(tech, "unlock-recipe",unlock.recipe)
						end
					end
				end
			end
		end
	end
end

--Cheap cliff explosives setting makes the reverse recipe crash
if mods["FTweaks"] then
	if Config.cheapCliffExplosives then
		for key1, ingredient in pairs(data.raw.recipe["cliff-explosives"].ingredients) do
			for key2, item in ipairs(ingredient) do
				if string.match(item, "item") then
					data.raw.recipe["cliff-explosives"].ingredients[key1][key2] = nil
					data.raw.recipe["cliff-explosives"].ingredients[key1]["item"] = "item"
				end
			end
		end
	end
end

--This function can be prevented from running by using "rf.prevent_final_fixes()" in data.lua
--DO NOT USE THIS FUNCTION IN YOUR MOD- DOWNLOAD reverse-factory-postprocess INSTEAD
function rf.final_fixes()

--List of item types to be recycled
local itemTypes = {
	"ammo","armor","item","rail-planner","gun","capsule","module","tool","repair-tool","fluid"
}
--Disables vehicle recycling
if rf.vehicles then 
	table.insert(itemTypes,"item-with-entity-data")
end
--Disable productivity loop
if rf.limitations and rf.noprod then 
	for _, item in pairs(rf.limitations) do
		table.insert(rf.norecycle_items, item)
	end
end

--Makes item versions of every fluid in the game
if rf.fluid_items then
	for _, fluid in pairs(data.raw.fluid) do
		makeFluidItem(fluid)
	end
end
 
--Automatic reverse recipe creation
for _, itemType in pairs(itemTypes) do
	addRecipes(itemType, data.raw[itemType])
end
--Manual recipes added
for _, recycle in pairs(rf.custom_recycle) do
	itemType = recycle[1]
	item = data.raw[itemType][recycle[2]]
	recipe = data.raw.recipe[recycle[3]]
	makeRecipe(itemType, item, recipe)
end
--Convert fluid results to items if that setting is enabled
if rf.fluid_items then
	for _, recipe in pairs(rf.fluidrecipe_list) do
		convertFluidResults(data.raw.recipe[recipe])
	end
	data.raw.furnace["reverse-factory-3"].fluid_boxes = nil
	data.raw.furnace["reverse-factory-4"].fluid_boxes[2] = nil
	data.raw.furnace["reverse-factory-4"].fluid_boxes[3] = nil
end


--Fix required for Space Exploration to allow early recycling of empty-barrel
--  only works if productivity loop is not disabled
if mods["space-exploration"] and data.raw.recipe["rf-empty-barrel"] then 
	data.raw.recipe["rf-empty-barrel"].category = "recycle-products"
end

fixMaxResults()

--Set result size of entities based on largest recipe count in current game
--Beta: Adding two extra output slots for the potential fluid outputs on the t3 and t4 machines
--rf.maxResults[3] = 2 + rf.maxResults[3]
--rf.maxResults[4] = 2 + rf.maxResults[4]
for n=1,4 do
	data.raw["furnace"]["reverse-factory-"..n].result_inventory_size = rf.maxResults[n]
	if mods["nullius"] then
		data.raw["furnace"]["nullius-reverse-factory-"..n].result_inventory_size = rf.maxResults[n]
	end
end

end

if not rf.prevented_final_fixes then
	rf.final_fixes()
end

--log(serpent.block(data.raw.recipe["advanced-foundry-mk01"]))
--rf.debug(data.raw.recipe["vs-condensed-void-stone"])
--rf.debug(data.raw.recipe["rf-sweater"])
--rf.debug(data.raw.technology["reverse-factory-1"])
--rf.debug(data.raw.armor["starry-armor"])
--rf.debug(data.raw.module["productivity-module"].limitation)
--rf.debug(data.raw.module["productivity-module"])
--rf.debug(data.raw.recipe["cliff-explosives"])
--rf.debug(data.raw.recipe["sb-wood-bricks-charcoal"])