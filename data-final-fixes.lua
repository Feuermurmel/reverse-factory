--This is where the magic happens
require('func')
local Recipe = require('__stdlib__/stdlib/data/recipe')

--List of item types to be recycled
local itemTypes = {
	"ammo","armor","item","gun","capsule","module","tool","repair-tool","fluid"
}
if rf.vehicles then 
	table.insert(itemTypes,"item-with-entity-data")
end

for _, itemType in pairs(itemTypes) do
	addRecipes(itemType, data.raw[itemType])
end


--Set result size of entities based on largest recipe count in current game
for n=1,4 do
	data.raw["furnace"]["reverse-factory-"..n].result_inventory_size = rf.maxResults[n]
end

--rf.debug(data.raw.recipe["se-data-storage-substrate"])
--rf.debug(rf.maxResults)
--rf.debug(data.raw.module["productivity-module"].limitation)
