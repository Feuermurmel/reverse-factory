function checkinvs()
	if next(rf.recyclers) then
		for _, rf in pairs(rf.recyclers) do
			--If recycler has power
			if rf.energy > 0 then
				--Check if not currently recycling
				if not rf.is_crafting() then
					--Check if any items in the input
					if rf.get_inventory(defines.inventory.assembling_machine_input).get_item_count() > 0 then
						--Grab input contents, stored as table (pairs)
						local items = rf.get_inventory(defines.inventory.assembling_machine_input).get_contents()
						for key, num in pairs(items) do
							--Squirrely-do to make a proper item table with strings
							item = {name=key, count=num}
							--And finally take the items and push them from input to output
							if rf.get_output_inventory().can_insert(item) then
								rf.get_output_inventory().insert(item)
								rf.get_inventory(defines.inventory.assembling_machine_input).clear()
							end
						end
					end
				end
			end
		end
	end
end

function scanworld()
	rf = {}
	rf.recyclers = {}
	for _, surface in pairs(game.surfaces) do
		local recyclers = surface.find_entities_filtered{name= "reverse-factory"}
		rf.recyclers = recyclers
	end
end

script.on_init( function()
	scanworld()
end)

script.on_configuration_changed( function()
	scanworld()
end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 240 == 0 then
		if rf then checkinvs() end
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if not rf then
		scanworld()
	end
	if event.created_entity.name == "reverse-factory" then
		table.insert(rf.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	if not rf then
		scanworld()
	end
	if event.created_entity.name == "reverse-factory" then
		table.insert(rf.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if not rf then
		scanworld()
	end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(rf.recyclers) do
			if entity == event.entity then
				table.remove(rf.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	if not rf then
		scanworld()
	end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(rf.recyclers) do
			if entity == event.entity then
				table.remove(rf.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	if not rf then
		scanworld()
	end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(rf.recyclers) do
			if entity == event.entity then
				table.remove(rf.recyclers, key)
			end
		end
	end
end)