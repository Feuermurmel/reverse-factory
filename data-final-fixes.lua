local Recipe = require('__stdlib__/stdlib/data/recipe')
local Technology = require('__stdlib__/stdlib/data/technology')

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

for _, itemType in pairs(itemTypes) do
	addRecipes(itemType, data.raw[itemType])
end

for _, recycle in pairs(rf.custom_recycle) do
	itemType = recycle[1]
	item = data.raw[itemType][recycle[2]]
	recipe = data.raw.recipe[recycle[3]]
	makeRecipe(itemType, item, recipe)
end

--Fix required for empty barrels being recyclable before tier 4.
if data.raw.recipe["rf-empty-barrel"] then 
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


--log(serpent.block(data.raw.recipe["advanced-foundry-mk01"]))
--rf.debug(data.raw.recipe["rf-wooden-chest"])
--rf.debug(data.raw.recipe["empty-barrel"])
--rf.debug(data.raw.technology["reverse-factory-1"])
--rf.debug(data.raw.armor["starry-armor"])
--rf.debug(data.raw.module["productivity-module"].limitation)
--rf.debug(data.raw.module["productivity-module"])
--rf.debug(data.raw.recipe["rf-empty-barrel"])