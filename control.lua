if settings.global["rf-compati"].value then

function checkinvs()
	if next(global.recyclers) then
		for key, ent in pairs(global.recyclers) do
			--If recycler has power
			if ent.energy > 0 then
				--Check if not currently recycling. 
				if not ent.is_crafting() then
					--Check if output is empty
					if ent.get_output_inventory().is_empty() then
						--Check if input is not empty
						if ent.get_inventory(defines.inventory.assembling_machine_input).get_item_count() > 0 then
							--If mark is set, reset mark, and push item
							if (global.marks[key]) then
								global.marks[key] = false
								--Grab input contents, stored as table (pairs)
								local items = ent.get_inventory(defines.inventory.assembling_machine_input).get_contents()
								for key, num in pairs(items) do
									--Squirrely-do to make a proper item table with strings
									item = {name=key, count=num}
									--And finally take the items and push them from input to output
									if ent.get_output_inventory().can_insert(item) then
										ent.get_output_inventory().insert(item)
										ent.get_inventory(defines.inventory.assembling_machine_input).clear()
									end
								end
							--Else if mark is not set, set mark
							else
								global.marks[key] = true
							end
						end
					end
				end
			end
		end
	end
end

function scanworld()
	global = {}
	global.recyclers = {}
	global.marks = {}
	for _, surface in pairs(game.surfaces) do
		local recyclers = surface.find_entities_filtered{name= "reverse-factory"}
		global.recyclers = recyclers
	end
	for i=0, (#global.recyclers) do
		table.insert(global.marks,false)
	end
end
script.on_init( function()
	scanworld()
end)

script.on_configuration_changed( function()
	scanworld()
end)

script.on_event(defines.events.on_tick, function(event)
	if not global.marks then scanworld() end
	if event.tick % settings.global["rf-delays"].value == 0 then
		--game.players[1].print("TEST")
		checkinvs()
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if not global.marks then scanworld() end
	if event.created_entity.name == "reverse-factory" then
		table.insert(global.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	if not global.marks then scanworld() end
	if event.created_entity.name == "reverse-factory" then
		table.insert(global.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if not global.marks then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	if not global.marks then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	if not global.marks then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)


end