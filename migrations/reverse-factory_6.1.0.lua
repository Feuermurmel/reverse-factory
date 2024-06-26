game.reload_script()

for index, force in pairs(game.forces) do
	force.reset_recipes()
	force.reset_technologies()
end

if settings.global["rf-compati"].value then
	global = {}
	global.recyclers = {}
	global.marks = {}
	for _, surface in pairs(game.surfaces) do
		local r1 = surface.find_entities_filtered{name="reverse-factory-1"}
		local r2 = surface.find_entities_filtered{name="reverse-factory-2"}
		local r3 = surface.find_entities_filtered{name="reverse-factory-3"}
		local r4 = surface.find_entities_filtered{name="reverse-factory-4"}
		local recyclers = {}
		for _, value in pairs (r1) do
			table.insert(recyclers, value)
		end
		for _, value in pairs (r2) do
			table.insert(recyclers, value)
		end
		for _, value in pairs (r3) do
			table.insert(recyclers, value)
		end
		for _, value in pairs (r4) do
			table.insert(recyclers, value)
		end
		global.recyclers = recyclers
	end
	for i=0, (#global.recyclers) do
		table.insert(global.marks,false)
	end
end