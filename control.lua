function checkinvs()
	local surface = game.surfaces['nauvis']
    local recyclers = {}
	--Find all reverse-factories
	recyclers = surface.find_entities_filtered{name= "reverse-factory"}
	if next(recyclers) then
		for _, rf in pairs(recyclers) do
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

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 240 == 0 then
		checkinvs()
	end
end)