--Data contains all functions contained in the Factorio stdlib
local Data = require('__stdlib__/stdlib/data/data')
local Recipe = require('__stdlib__/stdlib/data/recipe')
local table = require('__stdlib__/stdlib/utils/table')

--Fixing some of the Factorio stdlib functions to work properly with all recipes
function Recipe:clear_ingredients()
    if self:is_valid() then
        if self.normal then
            if self.normal.ingredients then
                self.normal.ingredients = {}
            end
		end
		if self.expensive then
            if self.expensive.ingredients then
                self.expensive.ingredients = {}
            end
		end
        if self.ingredients then
            self.ingredients = {}
        end
    end
    return self
end

function Recipe:set_enabled(enabled)
    if self:is_valid() then
        if self.normal then
            self.normal.enabled = enabled
		end
		if self.expensive then
            self.expensive.enabled = enabled
		end
        if self.enabled  then
            self.enabled = enabled
        end
    end
    return self
end

function Data:copy(new_name, mining_result, opts)
    --Is.Assert.String(new_name, 'New name is required')
    if self:is_valid() then
        mining_result = mining_result or new_name
        --local from = self.name
        local copy = table.deep_copy(rawget(self, '_raw'))
        copy.name = new_name

        -- For Entities
        -- Need to also check mining_results!!!!!!
        if mining_result then
            if copy.minable and copy.minable.result then
                copy.minable.result = mining_result
            end
        end

        -- For items
        if copy.place_result then
            copy.place_result = new_name
        end

        -- For recipes, should also to check results!!
        if copy.type == 'recipe' then
            if copy.normal and copy.normal.result then
                copy.normal.result = new_name
			end
            if copy.expensive and copy.expensive.result then
                copy.expensive.result = new_name
			end
			if copy.result then
				copy.result = new_name
			end
        end

        -- rail planners
        if copy.placeable_by and copy.placeable_by.item then
            copy.placeable_by.item = mining_result
        end

        return self(copy, nil, opts or self.options)
    else
        error('Cannot Copy, invalid prototype', 4)
    end
end

--Used to gate intermediate products behind higher tier recyclers
if data.raw.module["productivity-module"] then
	rf.limitations = data.raw.module["productivity-module"].limitation
end

--Used for Yuoki mod compatibility
local yuoki = "-recipe"

--Check all recipes in category, and create a reverse recipe for any items in that category
function addRecipes(itemType, group)
	for itemName, item in pairs(group) do
		--Check if a canon recipe exists for the item in question
		local recipe = data.raw.recipe[itemName] and (data.raw.recipe[itemName] or data.raw.recipe[itemName..yuoki])
		--Fix for items from 248k mod
		if rf.mod248k and string.match(itemName,"_item") then
			recipeName = shorten248k(itemName)
			recipe = data.raw.recipe[recipeName]
		end
		if recipe then
			local reversible = false
			--Recipe must have ingredients to be uncraftable
			if recipe.ingredients then
				if next(recipe.ingredients) then
					reversible = true
				end
			end
			if recipe.normal then
				if recipe.normal.ingredients then
					if next(recipe.normal.ingredients) then 
						reversible = true
					end
				end
			end
			if recipe.expensive then
				if recipe.expensive.ingredients then
					if next(recipe.expensive.ingredients) then 
						reversible = true
					end
				end
			end
			--Recipe must 
			if reversible then
				if checkProbs(recipe,item) then
					if noRecycle(recipe,item) then
						makeRecipe(itemType,item,recipe)
					end
				end
			end
		end
	end
end

--Check if recipe uses probability or has multiple products (do NOT attempt to reeycle)
function checkProbs(recipe,item)
	local noProb = true
	if recipe.results then
		if #recipe.results > 1 then noProb = false end
		for _, ingred in ipairs(recipe.results) do
			if ingred.probability then noProb = false end
		end
	end
	if recipe.normal then
		if recipe.normal.results then
			if #recipe.normal.results > 1 then noProb = false end
			for _, ingred in ipairs(recipe.normal.results) do
				if ingred.probability then noProb = false end
			end
		end
	end
	if recipe.expensive then
		if recipe.expensive.results then
			if #recipe.expensive.results > 1 then noProb = false end
			for _, ingred in ipairs(recipe.expensive.results) do
				if ingred.probability then noProb = false end
			end
		end
	end
	return noProb
end

--Check if recipe should be recyclable.
function noRecycle(recipe,item)
	uncraft = true
	--List of items and categories not to recycle; can be added to by other mods.
	for _, item in pairs(rf.norecycle_items) do
		if recipe.name == item then uncraft = false end
	end
	for _, category in pairs(rf.norecycle_categories) do
		if recipe.category == category then uncraft = false end
	end
	for _, subgroup in pairs(rf.norecycle_subgroups) do
		if item.subgroup == subgroup then uncraft = false end
		if recipe.subgroup == subgroup then uncraft = false end
	end
	--Output list of items that could not be recycled.
	if not uncraft then log("Item is on list of Unrecyclables: "..item.name) end
	return uncraft
end

--Create a reverse recipe for input recipe
function makeRecipe(itemType,item,recipe)
	local nrec = "rf-"..item.name
	local rfCategory, normalCount, expenCount = checkResults(itemType,item,recipe)
	local toAdd = {category = rfCategory, subgroup = "recycling", enabled = true, hidden = true, allow_decomposition = false, unlock_results = false}
	--local energyMult = 3
	local energyMin = 5
	
	Data(recipe):copy(nrec)
	Recipe(nrec):clear_ingredients()

	--Copy icon or icons from item if recipe did not have it set
	if not recipe.icon and not recipe.icons then
		if data.raw[itemType][item.name].icon then
			Recipe(nrec):set_field("icon",data.raw[itemType][item.name].icon)
		end
		if data.raw[itemType][item.name].icons then
			Recipe(nrec):set_field("icons",data.raw[itemType][item.name].icons)
		end
		if data.raw[itemType][item.name].icon_size then
			Recipe(nrec):set_field("icon_size",data.raw[itemType][item.name].icon_size)
		end
		if data.raw[itemType][item.name].icon_mipmaps then
			Recipe(nrec):set_field("icon_mipmaps",data.raw[itemType][item.name].icon_mipmaps)
		end
	end

	--If normal/expensive recipe, make edits to those parts as well
	if data.raw.recipe[nrec].normal then
		data.raw.recipe[nrec].normal.hidden = true
		data.raw.recipe[nrec].normal.unlock_results = false
		data.raw.recipe[nrec].normal.allow_decomposition = false
	end
	if data.raw.recipe[nrec].expensive then
		data.raw.recipe[nrec].expensive.hidden = true
		data.raw.recipe[nrec].expensive.unlock_results = false
		data.raw.recipe[nrec].expensive.allow_decomposition = false
	end
	
	--If expenCount is defined, then expensive must be defined
	if expenCount then
		--This implies only expensive is defined, while normal is empty
		if Recipe(nrec):get_field("normal") == Recipe(nrec):get_field("expensive") then
			Recipe(nrec):add_ingredient({item.name,normalCount})
		else --Otherwise, both normal and expensive are defined
			Recipe(nrec):add_ingredient({item.name,normalCount},{item.name,expenCount})
		end
	else --Otherwise, only normal or only recipe is defined, but not expensive
		if itemType == "fluid" then
			Recipe(nrec):add_ingredient({type="fluid",name=item.name,amount=normalCount})
		else  --This has the unintentional side effect of converting normal to simply recipe
			Recipe(nrec):add_ingredient({item.name,normalCount})
		end
	end

	Recipe(nrec):set_enabled(true)
	Recipe(nrec):set_fields(toAdd)

	removeResults(nrec)	
	formatResults(nrec,recipe)
	fixCategory(nrec,rfCategory)
	
	if mods ["nullius"] then
		Recipe(nrec):set_field("order","nullius-b")
	end
end

--Check recipe for result count and gate beind specific tier
function checkResults(itemType,item,recipe)
	--Default values for count and category
	local normalCount = recipe.result_count and recipe.result_count or 1
	local category = "recycle-products"
	local expenCount = nil

	--Recycling intermediate products are tier 2
	if data.raw[itemType][item.name].subgroup then
		if string.match(data.raw[itemType][item.name].subgroup, "intermediate") then
			category = "recycle-intermediates"
		elseif string.match(data.raw[itemType][item.name].subgroup, "raw") then
			category = "recycle-intermediates"
		end
	end

	--Check for normal recipes
	if recipe.normal then
		--Recycling fluids into items are tier 3
		if recipe.normal.results then
			if recipe.normal.results.type == "fluid" then
				category = "recycle-with-fluids"
			end
			--Also check for results count
			for _, ingred in ipairs(recipe.normal.results) do
				for _, object in pairs(ingred) do
					if type(object) == "number" then
						normalCount = object
					end
				end
			end
		--Default back to 1
		elseif recipe.normal.result then
			if recipe.normal.result_count then
				normalCount = recipe.normal.result_count
			else normalCount = 1 end
		end
		--Recycling items or fluids into fluids are tier 3
		if recipe.normal.ingredients then
			for _, ingredient in ipairs(recipe.normal.ingredients) do
				if ingredient.type == "fluid" then
					category = "recycle-with-fluids"
				end
			end
		end
	end

	--Check for expensive recipes
	if recipe.expensive then
		--Recycling fluids into items are tier 3
		if recipe.expensive.results then
			if recipe.expensive.results.type == "fluid" then
				category = "recycle-with-fluids"
			end
			--Also check for results count
			for _, ingred in ipairs(recipe.expensive.results) do
				for _, object in pairs(ingred) do
					if type(object) == "number" then
						expenCount = object
					end
				end
			end
		--Default back to 1
		elseif recipe.expensive.result then
			if recipe.expensive.result_count then
				expenCount = recipe.expensive.result_count
			else expenCount = 1 end
		end
		--Recycling items or fluids into fluids are tier 3
		if recipe.expensive.ingredients then
			for _, ingredient in ipairs(recipe.expensive.ingredients) do
				if ingredient.type == "fluid" then
					category = "recycle-with-fluids"
				end
			end
		end
	end

	--Check for simple recipes
	if recipe.results then
		--Recycling fluids into items are tier 3
		if recipe.results.type == "fluid" then
			category = "recycle-with-fluids"
		end
		--Also check for results count
		for _, ingred in pairs(recipe.results) do
			for _, object in pairs(ingred) do
				if type(object) == "number" then
					normalCount = object
				end
			end
		end
	end
	if recipe.ingredients then
		--Recycling items into fluids are tier 3
		for _, ingredient in ipairs(recipe.ingredients) do
			if ingredient.type == "fluid" then
				category = "recycle-with-fluids"
			end
		end
	end

	--Recycling fluids in general are tier 3
	if itemType == "fluid" then
		category = "recycle-with-fluids"
	end
	
	--Add any fluid results to the list of fluid recipes
	if string.match(category,"fluids") then
		table.insert(rf.fluidrecipe_list,"rf-"..item.name)
	end

	--Any recipes with productivity are tier 4
	if rf.limitations then
		for _, name in pairs(rf.limitations) do
			if recipe.name == name then
				category = "recycle-productivity"
			end
		end
	end

	--Upgrade to higher tier depending on ingredient count.
	if recipe.ingredients then
		if #recipe.ingredients > 15 then
			category = "recycle-productivity"
		elseif #recipe.ingredients > 10 then
			category = "recycle-with-fluids"
		elseif #recipe.ingredients > 5 then
			category = "recycle-intermediates"
		end
	end
	if recipe.normal then
		if recipe.normal.ingredients then
			if #recipe.normal.ingredients > 15 then
				category = "recycle-productivity"
			elseif #recipe.normal.ingredients > 10 then
				category = "recycle-with-fluids"
			elseif #recipe.normal.ingredients > 5 then
				category = "recycle-intermediates"
			end
		end
	end	
	if recipe.expensive then
		if recipe.expensive.ingredients then
			if #recipe.expensive.ingredients > 15 then
				category = "recycle-productivity"
			elseif #recipe.expensive.ingredients > 10 then
				category = "recycle-with-fluids"
			elseif #recipe.expensive.ingredients > 5 then
				category = "recycle-intermediates"
			end
		end
	end
	
	return category, normalCount, expenCount
end

function removeResults(nrec)
	local nrecData = data.raw.recipe[nrec]
	if nrecData.result then
		nrecData.result = nil
		nrecData.result_count = nil
	end
	if nrecData.main_product then
		nrecData.main_product = nil
	end
	if nrecData.normal then
		if nrecData.normal.result then
			nrecData.normal.results = {}
			nrecData.normal.result = nil
			nrecData.normal.result_count = nil
		end
		if nrecData.normal.results then
			nrecData.normal.results = {}
		end
		if nrecData.normal.main_product then
			nrecData.normal.main_product = nil
		end
	end
	if nrecData.expensive then
		if nrecData.expensive.result then
			nrecData.expensive.results = {}
			nrecData.expensive.result = nil
			nrecData.expensive.result_count = nil
		end
		if nrecData.expensive.results then
			nrecData.expensive.results = {}
		end
		if nrecData.expensive.main_product then
			nrecData.expensive.main_product = nil
		end
	end
end

function formatResults(nrec,recipe)
	local nrecData = data.raw.recipe[nrec]
	if recipe.normal then
		nrecData.normal.results = {}
		for _, ingred in pairs(recipe.normal.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else
				ingredAmount = ingred[2] or ingred.amount 
				newResult = {type="item", name=ingred[1] or ingred.name, amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			if checkForGrids(newResult.name) then
				newResult.amount = 1
			end
			table.insert(nrecData.normal.results, newResult)
		end
	end
	if recipe.expensive then
		nrecData.expensive.results = {}
		for _, ingred in pairs(recipe.expensive.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else 
				ingredAmount = ingred[2] or ingred.amount
				newResult = {type="item",name=ingred[1] or ingred.name,amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			if checkForGrids(newResult.name) then
				newResult.amount = 1
			end
			table.insert(nrecData.expensive.results, newResult)
		end
	end
	if recipe.ingredients then
		nrecData.results = {}
		for _, ingred in pairs(recipe.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else
				ingredAmount = ingred[2] or ingred.amount
				newResult = {type="item",name=ingred[1] or ingred.name,amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			if checkForGrids(newResult.name) then
				newResult.amount = 1
			end
			table.insert(nrecData.results, newResult)
		end
	end
end

function fixCategory(nrec,rfCategory)
	local nrecData = data.raw.recipe[nrec]

	if nrecData.results then
		if rfCategory == "recycle-products" then
			rf.maxResults[1] = math.max(rf.maxResults[1],#nrecData.results)
			if Recipe(nrec):get_field("energy_required") then
				if tonumber(Recipe(nrec):get_field("energy_required")) < 1 then
					Recipe(nrec):set_field("energy_required",1)
				end
			else Recipe(nrec):set_field("energy_required",1)
			end
		elseif rfCategory == "recycle-intermediates" then
			rf.maxResults[2] = math.max(rf.maxResults[2],#nrecData.results)
			if Recipe(nrec):get_field("energy_required") then
				if tonumber(Recipe(nrec):get_field("energy_required")) < 2 then
					Recipe(nrec):set_field("energy_required",2)
				end
			else Recipe(nrec):set_field("energy_required",2)
			end
		elseif rfCategory == "recycle-with-fluids" then
			rf.maxResults[3] = math.max(rf.maxResults[3],#nrecData.results)
			if Recipe(nrec):get_field("energy_required") then
				if tonumber(Recipe(nrec):get_field("energy_required")) < 3 then
					Recipe(nrec):set_field("energy_required",3)
				end
			else Recipe(nrec):set_field("energy_required",3)
			end
		elseif rfCategory == "recycle-productivity" then
			rf.maxResults[4] = math.max(rf.maxResults[4],#nrecData.results)
			if Recipe(nrec):get_field("energy_required") then
				if tonumber(Recipe(nrec):get_field("energy_required")) < 4 then
					Recipe(nrec):set_field("energy_required",4)
				end
			else Recipe(nrec):set_field("energy_required",4)
			end
		end
	end

	if nrecData.normal then
		if nrecData.normal.results then
			if rfCategory == "recycle-products" then
				rf.maxResults[1] = math.max(rf.maxResults[1],#nrecData.normal.results)
				if data.raw.recipe[nrec].normal.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 1 then
						data.raw.recipe[nrec].normal.energy_required = 1
					end
				else data.raw.recipe[nrec].normal.energy_required = 1
				end
			elseif rfCategory == "recycle-intermediates" then
				rf.maxResults[2] = math.max(rf.maxResults[2],#nrecData.normal.results)
				if data.raw.recipe[nrec].normal.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 2 then
						data.raw.recipe[nrec].normal.energy_required = 2
					end
				else data.raw.recipe[nrec].normal.energy_required = 2
				end
			elseif rfCategory == "recycle-with-fluids" then
				rf.maxResults[3] = math.max(rf.maxResults[3],#nrecData.normal.results)
				if data.raw.recipe[nrec].normal.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 3 then
						data.raw.recipe[nrec].normal.energy_required = 3
					end
				else data.raw.recipe[nrec].normal.energy_required = 3
				end
			elseif rfCategory == "recycle-productivity" then
				rf.maxResults[4] = math.max(rf.maxResults[4],#nrecData.normal.results)
				if data.raw.recipe[nrec].normal.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 4 then
						data.raw.recipe[nrec].normal.energy_required = 4
					end
				else data.raw.recipe[nrec].normal.energy_required = 4
				end
			end
		end
	end

	if nrecData.expensive then
		if nrecData.expensive.results then
			if rfCategory == "recycle-products" then
				rf.maxResults[1] = math.max(rf.maxResults[1],#nrecData.expensive.results)
				if data.raw.recipe[nrec].expensive.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 1 then
						data.raw.recipe[nrec].expensive.energy_required = 1
					end
				else data.raw.recipe[nrec].expensive.energy_required = 1
				end
			elseif rfCategory == "recycle-intermediates" then
				rf.maxResults[2] = math.max(rf.maxResults[2],#nrecData.expensive.results)
				if data.raw.recipe[nrec].expensive.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 2 then
						data.raw.recipe[nrec].expensive.energy_required = 2
					end
				else data.raw.recipe[nrec].expensive.energy_required = 2
				end
			elseif rfCategory == "recycle-with-fluids" then
				rf.maxResults[3] = math.max(rf.maxResults[3],#nrecData.expensive.results)
				if data.raw.recipe[nrec].expensive.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 3 then
						data.raw.recipe[nrec].expensive.energy_required = 3
					end
				else data.raw.recipe[nrec].expensive.energy_required = 3
				end
			elseif rfCategory == "recycle-productivity" then
				rf.maxResults[4] = math.max(rf.maxResults[4],#nrecData.expensive.results)
				if data.raw.recipe[nrec].expensive.energy_required then
					if tonumber(data.raw.recipe[nrec].normal.energy_required) < 4 then
						data.raw.recipe[nrec].expensive.energy_required = 4
					end
				else data.raw.recipe[nrec].expensive.energy_required = 4
				end
			end
		end
	end

end

function checkForGrids(ingredient)
	local possibleGrid = false
	if data.raw.armor[ingredient] then
		if data.raw.armor[ingredient].equipment_grid then
			possibleGrid = true
		end
	end
	if data.raw.car[ingredient] then
		if data.raw.car[ingredient].equipment_grid then
			possibleGrid = true
		end
	end
	if data.raw["spider-vehicle"][ingredient] then
		if data.raw["spider-vehicle"][ingredient].equipment_grid then
			possibleGrid = true
		end
	end
	return possibleGrid
end

function makeFluidItem(fluid)
	makeFluid = true
	for _, item in pairs(rf.nofluid_items) do
		if fluid.name == item then makeFluid = false end
	end
	if makeFluid then
		new_item = {
			type = "item",
			name = Data(fluid,"fluid"):get_field("name"),
			icon = Data(fluid,"fluid"):get_field("icon"),
			icon_size = Data(fluid,"fluid"):get_field("icon_size"),
			icon_mipmaps = Data(fluid,"fluid"):get_field("icon_mipmaps"),
			subgroup = "fluid-recipes",
			order = Data(fluid,"fluid"):get_field("order"),
			stack_size = "100"
		}
		if fluid.icons then
			new_item.icons = Data(fluid,"fluid"):get_icons()
		end
		data:extend({new_item})
		makeFluidRecipe(fluid)
	end
end

function makeFluidRecipe(fluid)
	new_recipe = {
		type = "recipe",
		name = fluid.name.."-conversion",
		subgroup = "fluid-recipes",
		category = "crafting-with-fluid",
		energy_required = 0.25,
		ingredients = {
			{fluid.name, 1}
		},
		results = {
			{type="fluid",name=fluid.name,amount=10}
		},
		allow_as_intermediate = false,
		hide_from_player_crafting = true
	}
	if mods["barreling-machine"] then
		table.insert(data.raw.furnace["barreling-machine"].crafting_categories,"recycle-unbarreling")
		new_recipe.category = "recycle-unbarreling"
	end
	if mods["auto-barrel"] then
		table.insert(data.raw.furnace["unbarreling-machine"].crafting_categories,"recycle-unbarreling")
		new_recipe.category = "recycle-unbarreling"
	end
	if mods["beltbox-barreling"] then
		for _, furnace in pairs(data.raw.furnace) do
			if string.match(furnace.name,"beltbox") then
				table.insert(data.raw.furnace[furnace.name].crafting_categories,"recycle-unbarreling")
			end
		end
		new_recipe.category = "recycle-unbarreling"
	end
	data:extend({new_recipe})
end

function convertFluidResults(recipe)
	--For simple recipes
	if recipe.results then
		for _, result in pairs(recipe.results) do
			if result.type == "fluid" then
				result.type = "item"
				result.amount = math.floor(result.amount/10)
			end
		end
	end
	--For more complex recipe, with normal variant
	if recipe.normal then
		if recipe.normal.results then
			for _, result in pairs(recipe.normal.results) do
				if result.type == "fluid" then
					result.type = "item"
					result.amount = math.floor(result.amount/10)
				end
			end
		end
	end
	--For more complex recipe, with expensive variant
	if recipe.expensive then
		if recipe.expensive.results then
			for _, result in pairs(recipe.expensive.results) do
				if result.type == "fluid" then
					result.type = "item"
					result.amount = math.floor(result.amount/10)
				end
			end
		end
	end
end

--Ensure that t2 recyclers make enough room for t1 and t2 recipes, and so on for each tier.
function fixMaxResults()
	rf.maxResults[2] = math.max(rf.maxResults[1],rf.maxResults[2])
	rf.maxResults[3] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3])
	rf.maxResults[4] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3],rf.maxResults[4])
end
--[[
function removeFromAllTechs(recipe)
	tech = seekTech(recipe)
	while tech do
		Recipe(recipe):remove_unlock(tech)
		tech = seekTech(recipe)
	end
end

function seekTech(recipe)
	for _, tech in pairs(data.raw.technology) do
		if tech.effects and (not string.find(tech.name, "demo-")) then
			for _, effect in pairs (tech.effects) do
				if recipe == effect.recipe then
					return tech.name
				end			
			end
		end
	end
end



]]--

function strReplace(str, what, with)
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
    return string.gsub(str, what, with)
end

function nulliusRecycling()
	for n = 1,4 do
		oldRecipe = "reverse-factory-"..n
		newRecipe = "nullius-reverse-factory-"..n
		Data(oldRecipe, "item"):copy(newRecipe)
		Data(oldRecipe, "recipe"):copy(newRecipe)
		Data(oldRecipe, "technology"):copy(newRecipe)
		Data(oldRecipe, "furnace"):copy(newRecipe)
		Data(newRecipe, "item"):set_field("order", "nullius-dd")
		Data(newRecipe, "technology"):set_field("order", "nullius-dd")
		Data(newRecipe, "technology"):set_field("effects",
		{
			{
			  type = "unlock-recipe",
			  recipe = "nullius-reverse-factory-"..n,
			}
		})
		if n > 1 then
			Data(newRecipe, "technology"):set_field("prerequisites",
			{"nullius-reverse-factory-"..(n-1)})
		end
	end
end

function shorten248k (itemName)
	recipeName = string.gsub(itemName,"_item","_recipe")
	--val = string.strfind(itemName,"-item")
	--recipeName = strsub(itemName, 0, val)
	return recipeName
end









