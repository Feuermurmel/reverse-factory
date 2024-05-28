--Remove Bio Industries dissassemble recipes
if data.raw.recipe["bi_steel_furnace_disassemble"] then
  data.raw.recipe["bi_steel_furnace_disassemble"].hidden = true
  data.raw.recipe["bi_burner_mining_drill_disassemble"].hidden = true
  data.raw.recipe["bi_stone_furnace_disassemble"].hidden = true
  data.raw.recipe["bi_burner_inserter_disassemble"].hidden = true
  data.raw.recipe["bi_long_handed_inserter_disassemble"].hidden = true
  thxbob.lib.tech.remove_recipe_unlock("advanced-material-processing", "bi_steel_furnace_disassemble")
  thxbob.lib.tech.remove_recipe_unlock("automation-2", "bi_burner_mining_drill_disassemble")
  thxbob.lib.tech.remove_recipe_unlock("automation-2", "bi_stone_furnace_disassemble")
  thxbob.lib.tech.remove_recipe_unlock("automation-2", "bi_burner_inserter_disassemble")
  thxbob.lib.tech.remove_recipe_unlock("automation-2", "bi_long_handed_inserter_disassemble")
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
			--Fix for duplicating crushed stone (angels refining)
			if not (recipe.name == "stone-crushed") then
				--Check if recipe has ingredients (can't uncraft into nothing)
				if recipe.ingredients then
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
							if uncraft then
								for _, ingred in ipairs(recipe.ingredients) do
									if ingred.type == "fluid" then 
										fluid=true
									end
									--Do not attempt to uncraft if one of the ingredients exceeds its stack size
									if (data.raw.item[ingred[1]]) then
										if (ingred[2] > data.raw.item[ingred[1]].stack_size) then
											uncraft=false
										end
									end
								end
							end
							--If no fluid ingredients detected, create reverse recipe
							if uncraft and (not fluid) then
								local count = recipe.result_count and recipe.result_count or 1
								local name = string.gsub(recipe.name, yuokiSuffix, "")
								local new_recipe 
								if elt.icon then
								--For all regular items and mods (elt.icon)
									new_recipe =
									{
										type = "recipe",
										name = "rf-" .. name,
										icon =  elt.icon,
										icon_size = elt.icon_size,
										category = "recycle",
										hidden = "true",
										energy_required = 30,
										ingredients = {{name, count}},
										results = recipe.ingredients
									}
								--Fix for annoying mods who use unnecessary tints (elt.icons)
								else new_recipe=
									{
										type = "recipe",
										name = "rf-" .. name,
										icons =  elt.icons,
										icon_size = elt.icon_size,
										category = "recycle",
										hidden = "true",
										energy_required = 30,
										ingredients = {{name, count}},
										results = recipe.ingredients
									}
								end

								if new_recipe.results then
									if #new_recipe.results > 1 then
										new_recipe.subgroup = "rf-multiple-outputs"
									end
								end
								
								--Add the recipe to rf_recipes
								table.insert(rf_recipes, new_recipe)
								--break
							--If fluid ingredients detected, create fluid reverse recipe
							elseif uncraft and fluid then
								local count = recipe.result_count and recipe.result_count or 1
								local name = string.gsub(recipe.name, yuokiSuffix, "")
								local new_recipe
								if elt.icon then 
									new_recipe = {
										type = "recipe",
										name = "rf-" .. name,
										icon =  elt.icon,
										icon_size = elt.icon_size,
										category = "recycle-with-fluid",
										hidden = "true",
										energy_required = 30,
										ingredients = {{name, count}},
										results = recipe.ingredients
									}
								else
									new_recipe = {
										type = "recipe",
										name = "rf-" .. name,
										icons =  elt.icons,
										icon_size = elt.icon_size,
										category = "recycle-with-fluid",
										hidden = "true",
										energy_required = 30,
										ingredients = {{name, count}},
										results = recipe.ingredients
									}
								end

								if new_recipe.results then
									if #new_recipe.results > 1 then
										new_recipe.subgroup = "rf-multiple-outputs"
									end
								end
								
								--Add the recipe to rf_recipes
								table.insert(rf_recipes, new_recipe)
								--break
								end
							end
					end
				--For recipes with differing difficulties
				elseif recipe.normal then
					if recipe.normal.ingredients then
						if next(recipe.normal.ingredients) then
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
								if uncraft then for _, ingred in ipairs(recipe.normal.ingredients) do
									if ingred.type == "fluid" then 
										fluid=true
									end
									--Do not attempt to uncraft if one of the ingredients exceeds its stack size
									if (data.raw.item[ingred[1]]) then
										if (ingred[2] > data.raw.item[ingred[1]].stack_size) then
											uncraft=false
										end
									end
								end end
								--If no fluid ingredients detected, create reverse recipe
								if uncraft and (not fluid) then
									--Someone fucked up
									if not recipe.expensive then
										error("\nNOTE: This is a courtesy error by Reverse Factory. The problem mod is something else.\n\nRecipe missing expensive counterpart: " .. recipe.name .. "\n" .. serpent.block(recipe))
									end
									local normacount = recipe.normal.result_count and recipe.normal.result_count or 1
									local expencount = recipe.expensive.result_count and recipe.expensive.result_count or 1
									local name = string.gsub(recipe.name, yuokiSuffix, "")
									local new_recipe
									--Dynamic hard mode recipes
									if rf.dynamic then
										if elt.icon then
										--For all regular items and mods (elt.icon)
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												normal = {
													ingredients = {{name, normacount}},
													results = recipe.normal.ingredients
													},
												expensive = {
													ingredients = {{name, expencount}},
													results = recipe.expensive.ingredients
													},
												main_product = "",
												subgroup = "recycling"
											}
										--Fix for annoying mods who use unnecessary tints (elt.icons)
										else new_recipe= {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												normal = {
													ingredients = {{name, normacount}},
													results = recipe.normal.ingredients
													},
												expensive = {
													ingredients = {{name, expencount}},
													results = recipe.expensive.ingredients
													},
												main_product = "",
												subgroup = "recycling"
											}
										end
									--Hard coded reverse recipes (easy)
									elseif rf.difficulty then
										if elt.icon then
										--For all regular items and mods (elt.icon)
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, normacount}},
												results = recipe.normal.ingredients
											}
										--Fix for annoying mods who use unnecessary tints (elt.icons)
										else new_recipe= {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, normacount}},
												results = recipe.normal.ingredients
											}
										end
									--Hard coded reverse recipes (hard)
									else
										if elt.icon then
										--For all regular items and mods (elt.icon)
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, expencount}},
												results = recipe.expensive.ingredients
											}
										--Fix for annoying mods who use unnecessary tints (elt.icons)
										else new_recipe= {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, expencount}},
												results = recipe.expensive.ingredients
											}
										end
									end

									if new_recipe.results then
										if #new_recipe.results > 1 then
											new_recipe.subgroup = "rf-multiple-outputs"
										end
									end
									
									--Add the recipe to rf_recipes
									table.insert(rf_recipes, new_recipe)
								--If fluid ingredients detected, create fluid reverse recipe
								elseif uncraft and fluid then
									--Someone fucked up
									if not recipe.expensive then
										error("\nNOTE: This is a courtesy error by Reverse Factory. The problem mod is something else.\n\nRecipe missing expensive counterpart: " .. recipe.name .. "\n" .. serpent.block(recipe))
									end
									local normacount = recipe.normal.result_count and recipe.normal.result_count or 1
									local expencount = recipe.expensive.result_count and recipe.expensive.result_count or 1
									local name = string.gsub(recipe.name, yuokiSuffix, "")
									local new_recipe
									if rf.dynamic then
										--Dynamic fluid with icon
										if elt.icon then
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												normal = {
														ingredients = {{name, normacount}},
														results = recipe.normal.ingredients
														},
												expensive = {
														ingredients = {{name, expencount}},
														results = recipe.expensive.ingredients
														},
												main_product = "",
												subgroup = "recycling"
											}
										else 
											--Dynamic fluid with icons
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												normal = {
														ingredients = {{name, normacount}},
														results = recipe.normal.ingredients
														},
												expensive = {
														ingredients = {{name, expencount}},
														results = recipe.expensive.ingredients
														},
												main_product = "",
												subgroup = "recycling"
											}
										end
									elseif rf.difficulty then
										--Easy fluid with icon
										if elt.icon then
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, normacount}},
												results = recipe.normal.ingredients
											}
										else 
											--Easy fluid with icons
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, normacount}},
												results = recipe.normal.ingredients
											}
										end
									else
										--Hard with icon
										if elt.icon then
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icon =  elt.icon,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, expencount}},
												results = recipe.expensive.ingredients
											}
										else
											--Hard with icons
											new_recipe = {
												type = "recipe",
												name = "rf-" .. name,
												icons =  elt.icons,
												icon_size = elt.icon_size,
												category = "recycle-with-fluid",
												hidden = "true",
												energy_required = 30,
												ingredients = {{name, expencount}},
												results = recipe.expensive.ingredients
											}
										end
									end
									
									if new_recipe.results then
										if #new_recipe.results > 1 then
											new_recipe.subgroup = "rf-multiple-outputs"
										end
									end
									
									--Add the recipe to rf_recipes
									table.insert(rf_recipes, new_recipe)
								end
							end
						end
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
addRecipes(data.raw.tool)				--Create recipes for all forms of science packs
addRecipes(data.raw["rail-planner"])	--Create recipe for rail. Seriously, just rail.
addRecipes(data.raw["mining-tool"])		--Create recipes for all mining tools
addRecipes(data.raw["repair-tool"]) 	--Create recipes for all repair tools

--Add the new recipes in data
data:extend(rf_recipes)

--Debugs recipes in factorio-current.log
--error(serpent.block(data.raw))