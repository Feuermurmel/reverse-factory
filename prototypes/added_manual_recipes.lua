--List of recipes that need to be manually added to the list
--  Must be in the format of {"item type", "item name",  "recipe name"}

--Added empty fuel canister from Pyanodon's Coal Processing mod
if mods["pycoalprocessing"] then
	if data.raw.item["empty-fuel-canister"] and data.raw.recipe["empty-jerry-can"] then
		table.insert(rf.custom_recycle, {"item", "empty-fuel-canister", "empty-jerry-can"})
	end
end

--Added gas canister, gas barrel, energy cell, and kerosine from King Jo's Fuels mod
if mods["kj_fuel"] then
	if data.raw.item["kj_gascan"] and data.raw.recipe["kj_gascan_fill"] then
		table.insert(rf.custom_recycle, {"item", "kj_gascan", "kj_gascan_fill"})
	end
	if data.raw.item["kj_energy_cell"] and data.raw.recipe["kj_energy_cell_load"] then
		table.insert(rf.custom_recycle, {"item", "kj_energy_cell", "kj_energy_cell_load"})
	end
	if data.raw.item["kj_kerosine"] and data.raw.recipe["kj_kerosine_fill"] then
		table.insert(rf.custom_recycle, {"item", "kj_kerosine", "kj_kerosine_fill"})
	end
	if data.raw.item["kj_gasbarrel"] and data.raw.recipe["kj_gasbarrel_fill"] then
		table.insert(rf.custom_recycle, {"item", "kj_gasbarrel", "kj_gasbarrel_fill"})
	end
end

if mods["Hovercrafts"] then
	if data.raw["item-with-entity-data"]["hcraft-entity"] and data.raw.recipe["hcraft-recipe"] then
		table.insert(rf.custom_recycle, {"item-with-entity-data", "hcraft-entity", "hcraft-recipe"})
	end
	if data.raw["item-with-entity-data"]["mcraft-entity"] and data.raw.recipe["mcraft-recipe"] then
		table.insert(rf.custom_recycle, {"item-with-entity-data", "mcraft-entity", "mcraft-recipe"})
	end
	if data.raw["item-with-entity-data"]["lcraft-entity"] and data.raw.recipe["lcraft-recipe"] then
		table.insert(rf.custom_recycle, {"item-with-entity-data", "lcraft-entity", "lcraft-recipe"})
	end
end