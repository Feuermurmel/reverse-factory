--Initialisation
--rf_recipes will contain all recipes that the reverse factory needs to know to disassemble the items
--acceptedCategories contains all the recipes accepted by the reverse factory
--yuokiSuffix allows the mod to catch Yuoki recipes
local rf_recipes = {}
--local acceptedCategories = {"crafting", "advanced-crafting", "yuoki-formpress-recipe", "yuoki-wonder-recipe", "electronics", "electronics-machine", "ore-processing", "pellet-pressing", "ore-sorting-t1", "ore-sorting-t4"}
local yuokiSuffix = "-recipe"

function addRecipes(t_elts)
    for elt_name, elt in pairs(t_elts) do
        --Get Recipe
        local recipe = data.raw.recipe[elt_name] and data.raw.recipe[elt_name] or data.raw.recipe[elt_name .. yuokiSuffix]
        --After the search of the recipe if recipe is sill not nil, we add the reverse factory recipe
        if recipe then
			--Check if recipe has ingredients (can't uncraft into nothing)
		    if next(recipe.ingredients) then
				--Set default value for recipe without category property (default value = "crafting")
				recipe.category = recipe.category and recipe.category or "crafting"
				--Loop through all categories in game
				for _ in pairs(data.raw["recipe-category"]) do
					--Default uncraftable is true, false if fluid ingredient detected
					uncraft=true
					for _, ingred in ipairs(recipe.ingredients) do
						if ingred.type == "fluid"
							then uncraft=false end
					end
					--If no fluid ingredients detected, create recipe
					if uncraft then
						local count = recipe.result_count and recipe.result_count or 1
						local name = string.gsub(recipe.name, yuokiSuffix, "")
						local new_recipe =
						{
							type = "recipe",
							name = "rf-" .. name,
							icon =  elt.icon,
							category = "recycling",
							hidden = "true",
							energy_required = 30,
							ingredients = {{name, count}},
							results = recipe.ingredients
						}

						if #new_recipe.results > 1 then
							new_recipe.subgroup = "rf-multiple-outputs"
						end
						
						--Add the recipe to rf_recipes
						table.insert(rf_recipes, new_recipe)
						break
					end
				end
			end
        end
    end
end

--Create recycling recipes
addRecipes(data.raw.ammo)				--Create recipes for all ammunitions
addRecipes(data.raw.armor)				--Create recipes for all armors
addRecipes(data.raw.item)				--Create recipes for all items
addRecipes(data.raw.gun)				--Create recipes for all weapons
addRecipes(data.raw.capsule)			--Create recipes for all capsules
addRecipes(data.raw.module)				--Create recipes for all modules
addRecipes(data.raw.tool)				--Create recipes for all types of science packs
addRecipes(data.raw["rail-planner"])	--Create recipe for rail. Seriously, just rail.
addRecipes(data.raw["mining-tool"])		--Create recipes for all mining tools
addRecipes(data.raw["repair-tool"]) 	--Create recipes for all repair tools
table.insert(rf_recipes, rail)

--Add the new recipes in data
data:extend(rf_recipes)

--Debugs recipes in factorio-current.log
--error(serpent.block(data.raw))