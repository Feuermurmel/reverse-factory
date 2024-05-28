if settings.global["rf-compati"].value then

function checkinvs()
	--If at least one recycler in the list..
	if next(global.recyclers) then
		--Check through the entire list..
		for key, entity in pairs (global.recyclers) do
			--Resets the timer if the recycler is not stopped by input
			local noResetTimer = true
			--Entity[1] is the actual recycler, Entity[2] is its timer
			--Then if the recycler has power..
			if entity[1].energy > 0 then
				--Then if the recycler is not currently recycling..
				if not entity[1].is_crafting() then
					--Then if the output is currently empty..
					if entity[1].get_output_inventory().is_empty() then
						--Then if the input is currently not empty..
						if entity[1].get_inventory(defines.inventory.assembling_machine_input).get_item_count() > 0 then
							--Decrement the timer, because the recycler is stopped with input
							entity[2] = countdown(entity[2])
							--Then if the timer has passed 0..
							if entity[2] < 0 then
								--Auto ingredient push and reset the timer if true
								pushIngredient(entity[1])
							--Do not reset the timer if the recycler is stopped by input
							else noResetTimer = false
							end
						end
					end
				end
			end
			--Resets the timer if the recycler was not stopped,
			--or if the recycler has already pushed to output
			if noResetTimer then
				entity[2]=global.timer
			end
		end
	end
end

--Function to check the world for recyclers and place them in a list
function scanworld()
	--It's easier to remake the list of recyclers, than to check for duplicates on load
	global = {}
	global.delay = settings.global["rf-delay"].value
	global.timer = settings.global["rf-timer"].value
	global.recyclers = {}
	--Check every game surface in the world
	for _, surface in pairs(game.surfaces) do
		for n=1, 4 do
			--Check the list of entities for any placed recyclers
			local rfname = "reverse-factory-"..n
			local list = surface.find_entities_filtered{name=rfname}
			--And add them to the list
			for _, entity in pairs(list) do
				addRecycler(entity)
			end
		end
	end
end

--On game load, scan the world for existing recyclers
script.on_init( function()
	scanworld()
end)

script.on_configuration_changed( function()
	scanworld()
end)

--Every 15 ticks, do a thing
script.on_event(defines.events.on_tick, function(event)
	if event.tick % global.delay == 0 then
		--game.players[1].print((#global.recyclers))
		--game.players[1].print(serpent.block(global.recyclers))
		checkinvs()
	end
end)

--When a recycler is placed, add it to the list
script.on_event(defines.events.on_robot_built_entity, function(event)
	addRecycler(event.created_entity)
end)

script.on_event(defines.events.on_built_entity, function(event)
	addRecycler(event.created_entity)
end)

--When a recycler is removed or destroyed, remove it from the list
script.on_event(defines.events.on_entity_died, function(event)
	killRecycler(event.entity)
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	killRecycler(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
	killRecycler(event.entity)
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	killRecycler(event.entity)
end)

--Check if the entity was a recycler, and if so, add it to the list with its own timer
function addRecycler(entity)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		local timer = global.timer
		local new_entity = {entity,timer}
		table.insert(global.recyclers,new_entity)
	end
end

--Check if the entity was a recycler, and if so, remove it from the list
function killRecycler(entity)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		for key, list_entity in pairs (global.recyclers) do
			if list_entity[1] == entity then
				table.remove(global.recyclers,key)
			end
		end
	end
end

--Countdown timer by the delay amount
function countdown(timer)
	local timer = timer - global.delay
	return timer
end

--Auto ingredient push function
function pushIngredient(entity)
	--Grab input contents, stored as table (pairs)
	local input = entity.get_inventory(defines.inventory.assembling_machine_input).get_contents()
	for itemName, itemCount in pairs(input) do
		--Squirrely-do to make a proper item table with strings
		item = {name=itemName, count=itemCount}
		--And finally take the stopped items and push them from input to output
		if entity.get_output_inventory().can_insert(item) then
			entity.get_output_inventory().insert(item)
			entity.get_inventory(defines.inventory.assembling_machine_input).clear()
		end
	end
end







end