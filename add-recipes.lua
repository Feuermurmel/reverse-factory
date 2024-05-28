rf.maxt1 = 1
rf.maxt2 = 1
local yuokiSuffix = "-recipe"

--Framework for adding recipes
function addRecipes(category)
	for item_name, item in pairs(category) do
		local recipe = data.raw.recipe[item_name] and data.raw.recipe[item_name] or data.raw.recipe[item_name..yuokiSuffix]
		--If recipe is not nil
		if recipe then
				--For recipes without normal/expensive versions
				if recipe.ingredients then if next(recipe.ingredients) then
				
					if uncraftable(recipe, item) then new_recipe = createRecipe(recipe, item) end
				end end
				if recipe.normal then if recipe.normal.ingredients then
					new_recipe = createDualRecipe(recipe, item)
				end end
		end
		table.insert(rf.recipes, new_recipe)
	end
end

--Used for basic recipes
function createRecipe(recipe, item)
	local rec_count = recipe.result_count and recipe.result_count or 1
	local rec_name = string.gsub(recipe.name, yuokiSuffix, "")
	local new_recipe = {}
	new_recipe = {
		type = "recipe",
		name = "rf-"..rec_name,
		icon = item.icon,
		icon_size = item.icon_size,
		subgroup = "rf-multiple-outputs",
		category = "recycle",
		hidden = "true",
		energy_required = 30,
		ingredients = {{rec_name, rec_count}},
		results = recipe.ingredients,
	}
	--Icons supercede the use of icon
	if item.icons then
		new_recipe.icons = item.icons
	end
	--If outputs fluid, set to separate category
	local fluid = false
	for _, ingred in ipairs(recipe.ingredients) do
		if ingred.type == "fluid" then fluid = true end
	end
	--Fluid determines max products for tier 2 recycler
	if fluid then
		new_recipe.category = "recycle-with-fluids"
		rf.maxt2 = math.max(#recipe.ingredients, rf.maxt2, rf.maxt1)
	else rf.maxt1 = math.max(#recipe.ingredients, rf.maxt1)
	end
	
	return new_recipe
end

--Used for normal/expensive recipes
function createDualRecipe(recipe, item)
	local normacount = recipe.normal.result_count and recipe.normal.result_count or 1
	local expencount = recipe.expensive.result_count and recipe.expensive.result_count or 1
	local rec_name = string.gsub(recipe.name, yuokiSuffix, "")
	local new_recipe = {}
	new_recipe = {
		type = "recipe",
		name = "rf-"..rec_name,
		icon = item.icon,
		icon_size = item.icon_size,
		category = "recycle",
		normal = {
			ingredients = {{rec_name, normacount}},
			results = recipe.normal.ingredients,
			hidden = "true",
			energy_required = 30,
			},
		expensive = {
			ingredients = {{rec_name, expencount}},
			results = recipe.expensive.ingredients,
			hidden = "true",
			energy_required = 30,
			},
		subgroup = "rf-multiple-outputs"
		}
	--Icons supercede the use of icon
	if item.icons then
		new_recipe.icons = item.icons
	end
	--If outputs fluid, set to separate category
	local fluid = false
	for _, ingred in ipairs(recipe.normal.ingredients) do
		if ingred.type == "fluid" then fluid = true end
	end
	for _, ingred in ipairs(recipe.expensive.ingredients) do
		if ingred.type == "fluid" then fluid = true end
	end
	--Fluid determines max products for tier 2 recycler
	if fluid then
		new_recipe.category = "recycle-with-fluids"
		rf.maxt2 = math.max(#recipe.normal.ingredients, #recipe.expensive.ingredients, rf.maxt2, rf.maxt1)
	else rf.maxt1 = math.max(#recipe.normal.ingredients, #recipe.expensive.ingredients, rf.maxt1)
	end
	
	return new_recipe
end

--Always true if safety is toggled off. Safety prevents ingredient loss
function uncraftable(recipe, item)
	uncraft = true
	if rf.safety then
		for _, ingred in ipairs(recipe.ingredients) do
			--Do not attempt to uncraft if one of the ingredients exceeds its stack size
			if (data.raw.item[ingred[1]]) then
				if (ingred[2] > data.raw.item[ingred[1]].stack_size) then
					uncraft=false
				end
			end
		end
	end
	if not uncraft then log("Item cannot be uncrafted: "..item.name) end
	return uncraft
end