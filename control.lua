if settings.global["rf-compat"].value then

function checkinvs()
	if next(global.recyclers) then
		for _, ent in pairs(global.recyclers) do
			--If recycler has power
			if ent.energy > 0 then
				--Check if not currently recycling. 
				if not ent.is_crafting() then
					--Check if output is not blocked
					if ent.get_output_inventory().is_empty() then
						--Check if any items in the input
						if ent.get_inventory(defines.inventory.assembling_machine_input).get_item_count() > 0 then
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
						end
					end
				end
			end
		end
	end
end

function scanworld()
	global.recyclers = {}
	for _, surface in pairs(game.surfaces) do
		local recyclers = surface.find_entities_filtered{name= "reverse-factory"}
		global.recyclers = recyclers
	end
end

script.on_init( function()
	scanworld()
end)

script.on_configuration_changed( function()
	scanworld()
end)

script.on_event(defines.events.on_tick, function(event)
	if not global.recyclers then scanworld() end
	if event.tick % settings.global["rf-delay"].value == 0 then
		checkinvs()
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if not global.recyclers then scanworld() end
	if event.created_entity.name == "reverse-factory" then
		table.insert(global.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	if not global.recyclers then scanworld() end
	if event.created_entity.name == "reverse-factory" then
		table.insert(global.recyclers, event.created_entity)
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if not global.recyclers then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	if not global.recyclers then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	if not global.recyclers then scanworld() end
	if event.entity.name == "reverse-factory" then
		for key, entity in pairs(global.recyclers) do
			if entity == event.entity then
				table.remove(global.recyclers, key)
			end
		end
	end
end)

end