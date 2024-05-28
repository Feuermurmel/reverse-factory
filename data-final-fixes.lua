--Remove Bio Industries dissassemble recipes
if data.raw.recipe["bi-burner-mining-drill-disassemble"] then
  data.raw.recipe["bi-burner-mining-drill-disassemble"] = nil
  data.raw.recipe["bi-steel-furnace-disassemble"] = nil
  thxbob.lib.tech.remove_recipe_unlock("advanced-material-processing", "bi-steel-furnace-disassemble")
end

--Initialisation
--rf_recipes will contain all recipes that the reverse factory needs to know to disassemble the items
--yuokiSuffix allows the mod to catch Yuoki recipes
local rf_recipes = {}
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
				for rcat in pairs(data.raw["recipe-category"]) do
					--Default uncraftable is true, false if current category was added by rf
					uncraft=true
					--Prevents recursive loop of checking reverse recipes
					if (rcat == "recycle") or (rcat == "recycle-with-fluid") then
						uncraft = false end
					--Default fluid is false, true if fluid detected
					fluid = false
					if uncraft then for _, ingred in ipairs(recipe.ingredients) do
						if ingred.type == "fluid"
							then fluid=true end
					end end
					--If no fluid ingredients detected, create reverse recipe
					if uncraft and (not fluid) then
						local count = recipe.result_count and recipe.result_count or 1
						local name = string.gsub(recipe.name, yuokiSuffix, "")
						local new_recipe =
						{
							type = "recipe",
							name = "rf-" .. name,
							icon =  elt.icon,
							category = "recycle",
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
					--If fluid ingredients detected, create fluid reverse recipe
					else if uncraft and fluid then
						local count = recipe.result_count and recipe.result_count or 1
						local name = string.gsub(recipe.name, yuokiSuffix, "")
						local new_recipe =
						{
							type = "recipe",
							name = "rf-" .. name,
							icon =  elt.icon,
							category = "recycle-with-fluid",
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
end

function addFluidRecipes(t_elts)
end

--Create recycling recipes
addRecipes(data.raw.ammo)				--Create recipes for all ammunitions
addRecipes(data.raw.armor)				--Create recipes for all armors
addRecipes(data.raw.item)				--Create recipes for all items
addRecipes(data.raw.gun)				--Create recipes for all weapons
addRecipes(data.raw.capsule)			--Create recipes for all capsules
addRecipes(data.raw.module)				--Create recipes for all modules
addRecipes(data.raw.tool)				--Create recipes for all forms of science packs
addRecipes(data.raw["rail-planner"])	--Create recipe for rail. Seriously, just rail.
addRecipes(data.raw["mining-tool"])		--Create recipes for all mining tools
addRecipes(data.raw["repair-tool"]) 	--Create recipes for all repair tools

--Add the new recipes in data
data:extend(rf_recipes)

--Debugs recipes in factorio-current.log
--error(serpent.block(data.raw))