--Data contains all functions contained in the Factorio stdlib
local Data = require('__stdlib__/stdlib/data/data')
local Recipe = require('__stdlib__/stdlib/data/recipe')
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
		if recipe then
			--Recipe must have ingredients to be uncraftable
			if recipe.ingredients then
				if next(recipe.ingredients) then
					if checkProbs(recipe,item) then
						if checkRecipe(recipe,item) then
							makeRecipe(itemType,recipe)
						end
					end
				end
			elseif recipe.normal.ingredients and recipe.expensive.ingredients then
				if next(recipe.normal.ingredients) and next(recipe.expensive.ingredients) then 
					if checkProbs(recipe,item) then
						if checkRecipe(recipe,item) then
							makeRecipe(itemType,recipe)
						end
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
function checkRecipe(recipe,item)
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
function makeRecipe(itemType, recipe)
	local nrec = "rf-"..recipe.name
	local rfCategory, normalCount, expenCount = checkResults(itemType,recipe)
	local toAdd = {category = rfCategory, subgroup = "recycling", enabled = true, allow_decomposition = false}
	local energyMult = 3
	
	Data(recipe):copy(nrec)
	Recipe(nrec):clear_ingredients()

	--Copy icon or icons from item if recipe did not have it set
	if not recipe.icon then
		if data.raw[itemType][recipe.name].icon then
			Recipe(nrec):set_field("icon",data.raw[itemType][recipe.name].icon)
			Recipe(nrec):set_field("icon_size",data.raw[itemType][recipe.name].icon_size)
		elseif data.raw[itemType][recipe.name].icons then
			Recipe(nrec):set_field("icons",data.raw[itemType][recipe.name].icons)
			Recipe(nrec):set_field("icon_size",data.raw[itemType][recipe.name].icon_size)
		end
	end

	if expenCount then
		if Recipe(nrec):get_field("normal") == Recipe(nrec):get_field("expensive") then
			Recipe(nrec):add_ingredient({recipe.name,normalCount})
		else
			Recipe(nrec):add_ingredient({recipe.name,normalCount},{recipe.name,expenCount})
		end
		data.raw.recipe[nrec].normal.hidden = true
		data.raw.recipe[nrec].expensive.hidden = true
		data.raw.recipe[nrec].normal.allow_decomposition = false
		data.raw.recipe[nrec].expensive.allow_decomposition = false
		if data.raw.recipe[nrec].normal.energy_required then
			data.raw.recipe[nrec].normal.energy_required = energyMult*data.raw.recipe[nrec].normal.energy_required
			else data.raw.recipe[nrec].normal.energy_required = energyMult
		end
		if data.raw.recipe[nrec].expensive.energy_required then
			data.raw.recipe[nrec].expensive.energy_required = energyMult*data.raw.recipe[nrec].expensive.energy_required
		else data.raw.recipe[nrec].expensive.energy_required = energyMult
		end
	else
		if itemType == "fluid" then
			Recipe(nrec):add_ingredient({type="fluid",name=recipe.name,amount=normalCount})
		else
			Recipe(nrec):add_ingredient({recipe.name,normalCount})
		end
		Recipe(nrec):set_field("hidden", true)
		if Recipe(nrec):get_field("energy_required") then
			newEnergy = energyMult*Recipe(nrec):get_field("energy_required")
			Recipe(nrec):set_field("energy_required", newEnergy)
		else Recipe(nrec):set_field("energy_required",energyMult)
		end
	end

	Recipe(nrec):set_enabled(true)
	Recipe(nrec):set_fields(toAdd)

	removeResults(nrec)
	formatResults(nrec,recipe)
	--rf.debug(data.raw.recipe[nrec])
	local nrecData = data.raw.recipe[nrec]

	if rfCategory == "recycle-products" then
		if expenCount then
			rf.maxResults[1] = math.max(rf.maxResults[1],#nrecData.normal.results,#nrecData.expensive.results)
		else
			rf.maxResults[1] = math.max(rf.maxResults[1],#nrecData.results)
		end
	elseif rfCategory == "recycle-intermediates" then
		if expenCount then
			rf.maxResults[2] = math.max(rf.maxResults[1],rf.maxResults[2],#nrecData.normal.results,#nrecData.expensive.results)
		else
			rf.maxResults[2] = math.max(rf.maxResults[1],rf.maxResults[2],#nrecData.results)
		end
	elseif rfCategory == "recycle-with-fluids" then
		if expenCount then
			rf.maxResults[3] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3],#nrecData.normal.results,#nrecData.expensive.results)
		else
			rf.maxResults[3] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3],#nrecData.results)
		end
	elseif rfCategory == "recycle-productivity" then
		if expenCount then
			rf.maxResults[4] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3],rf.maxResults[4],#nrecData.normal.results,#nrecData.expensive.results)
		else
			--if not nrecData.results then rf.debug() end
			rf.maxResults[4] = math.max(rf.maxResults[1],rf.maxResults[2],rf.maxResults[3],rf.maxResults[4],#nrecData.results)
		end
	end
	--rf.debug(nrecData)
end

--Check recipe for result count and gate beind specific tier
function checkResults(itemType,recipe)
	--Default values for count and category
	local normalCount = recipe.result_count and recipe.result_count or 1
	local category = "recycle-products"
	local expenCount = nil
	--Recycling intermediate products are tier 2
	if data.raw[itemType][recipe.name].subgroup then
		if string.match(data.raw[itemType][recipe.name].subgroup, "intermediate") then
			category = "recycle-intermediates"
		elseif string.match(data.raw[itemType][recipe.name].subgroup, "raw") then
			category = "recycle-intermediates"
		end
	end
	--Check for normal/expensive recipes
	if recipe.normal and recipe.expensive then
		--Recycling fluids into items are tier 3
		if recipe.normal.results and recipe.expensive.results then
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
			for _, ingred in ipairs(recipe.expensive.results) do
				for _, object in pairs(ingred) do
					if type(object) == "number" then
						expenCount = object
					end
				end
			end
		--Default back to 1, ensure that expenCount is set
		elseif recipe.normal.result and recipe.expensive.result then
			normalCount = 1
			expenCount = 1
		end
		--Recycling items or fluids into fluids are tier 3
		if recipe.normal.ingredients and recipe.expensive.ingredients then
			for _, ingredient in ipairs(recipe.normal.ingredients) do
				if ingredient.type == "fluid" then
					category = "recycle-with-fluids"
				end
			end
			for _, ingredient in ipairs(recipe.expensive.ingredients) do
				if ingredient.type == "fluid" then
					category = "recycle-with-fluids"
				end
			end
		end
	else --Check for simple recipes
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
		--Recycling items or fluids into fluids are tier 3
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
	--Any recipes with productivity are tier 4
	if rf.limitations then
		for _, name in pairs(rf.limitations) do
			if recipe.name == name then
				category = "recycle-productivity"
			end
		end
	end
	return category, normalCount, expenCount
end

function removeResults(nrec)
	local nrecData = data.raw.recipe[nrec]
	if nrecData.result then 
		nrecData.results = {}
		nrecData.result = nil
		nrecData.result_count = nil
	end
	if nrecData.results then
		nrecData.results = {}
	end
	if nrecData.main_product then
		nrecData.main_product = nil
	end
	if nrecData.normal and nrecData.expensive then
		if nrecData.normal.result and nrecData.expensive.result then
			nrecData.normal.results = {}
			nrecData.expensive.results = {}
			nrecData.normal.result = nil
			nrecData.expensive.result = nil
			nrecData.normal.result_count = nil
			nrecData.expensive.result_count = nil
		end
		if nrecData.normal.results and nrecData.expensive.results then
			nrecData.normal.results = {}
			nrecData.expensive.results = {}
		end
		if nrecData.normal.main_product then
			nrecData.normal.main_product = nil
		end
		if nrecData.expensive.main_product then
			nrecData.expensive.main_product = nil
		end
	end
end

function formatResults(nrec,recipe)
	local nrecData = data.raw.recipe[nrec]
	if recipe.normal then
		for _, ingred in pairs(recipe.normal.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else
				ingredAmount = ingred[2] or ingred.amount 
				newResult = {type="item",name=ingred[1] or ingred.name,amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			table.insert(nrecData.normal.results, newResult)
		end
		for _, ingred in pairs(recipe.expensive.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else 
				ingredAmount = ingred[2] or ingred.amount
				newResult = {type="item",name=ingred[1] or ingred.name,amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			table.insert(nrecData.expensive.results, newResult)
		end
	else for _, ingred in pairs(recipe.ingredients) do
			if ingred.type then
				newResult = {type=ingred.type, name=ingred.name, amount = (math.ceil(rf.efficiency*ingred.amount/100))}
			else
				ingredAmount = ingred[2] or ingred.amount
				newResult = {type="item",name=ingred[1] or ingred.name,amount=(math.ceil(rf.efficiency*ingredAmount/100))}
			end
			table.insert(nrecData.results, newResult)
		end
	end
end




























