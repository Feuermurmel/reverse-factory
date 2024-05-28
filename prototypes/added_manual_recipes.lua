--List of recipes that need to be manually added to the list
--  Must be in the format of {"item type", "item name",  "recipe name"}

--Added empty fuel canister from Pyanodon's Coal Processing mod
if mods["pycoalprocessing"] then
	if data.raw.item["empty-fuel-canister"] and data.raw.recipe["empty-jerry-can"] then
		table.insert(rf.custom_recycle, {"item", "empty-fuel-canister", "empty-jerry-can"})
	end
end