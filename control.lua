if settings.global["rf-compati"].value then

function checkinvs()
	--Run through every currently active surface
	for _, surface in pairs(global.activeSurfaces) do
		--If at least one recycler in the list..
		if global[surface] then if next(global[surface]) then
			--Check through the entire list..
			for _, entity in pairs (global[surface]) do
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
		end end
	end
end

--Function to check the world for recyclers and place them in a list
function scanworld()
	--It's easier to remake the list of recyclers, than to check for duplicates, on map load
	global = {}
	global.activeSurfaces = {}
	global.delay = settings.global["rf-delay"].value
	global.timer = settings.global["rf-timer"].value
	--Check every game surface in the world
	for _, surface in pairs(game.surfaces) do
		for n=1, 4 do
			--Check the list of entities for any placed recyclers
			local rfname = "reverse-factory-"..n
			local list = surface.find_entities_filtered{name=rfname}
			--And add them to the list for that specific surface
			for _, entity in pairs(list) do
				addRecycler(entity, surface.name)
			end
		end
	end
	--Check all players in the world to see what surfaces are activeSurfaces
	for _, player in pairs (game.players) do
		addActiveSurface(player.surface.name)
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
	if global.delay then
		if event.tick % global.delay == 0 then
			checkinvs()
		end
	--else game.players[1].print(("Global delay not yet set."))
	end
	if global.activeSurfaces then
		if event.tick % 60 == 0 then
			--game.players[1].print(serpent.block(global))
		end
	end
end)

--When a recycler is placed, add it to the list
script.on_event(defines.events.on_robot_built_entity, function(event)
	addRecycler(event.created_entity, event.created_entity.surface.name)
end)

script.on_event(defines.events.on_built_entity, function(event)
	--game.players[1].print((serpent.block(event.created_entity.surface.name)))
	addRecycler(event.created_entity, event.created_entity.surface.name)
end)

--When a recycler is removed or destroyed, remove it from the list
script.on_event(defines.events.on_entity_died, function(event)
	killRecycler(event.entity, event.entity.surface.name)
end)

script.on_event(defines.events.script_raised_destroy, function(event)
	killRecycler(event.entity, event.entity.surface.name)
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	killRecycler(event.entity, event.entity.surface.name)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
	killRecycler(event.entity, event.entity.surface.name)
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	killRecycler(event.entity, event.entity.surface.name)
end)

--When the surface is created
script.on_event(defines.events.on_surface_created, function(event)
	addActiveSurface(game.surfaces[event.surface_index].name)
end)

--Just after the surface is cleared
script.on_event(defines.events.on_surface_cleared, function(event)
	addActiveSurface(game.surfaces[event.surface_index].name)
end)

--Just before the surface is deleted
script.on_event(defines.events.on_pre_surface_deleted, function(event)
	--game.players[1].print(game.surfaces[event.surface_index].name)
	removeActiveSurface(game.surfaces[event.surface_index].name)
end)

--Just before the surface is cleared of all entites
script.on_event(defines.events.on_pre_surface_cleared, function(event)
	local surface = game.surfaces[event.surface_index].name
	removeActiveSurface(game.surfaces[event.surface_index].name)
	if global[surface] then
		global[surface] = {}
	end
	--[[
		for _, recycler in pairs (global[surface]) do
			game.players[1].print(serpent.block(recycler[1]))
			killRecycler(recycler[1], surface)
		end
	end]]--
end)

--When the surface is renamed?
script.on_event(defines.events.on_surface_renamed, function(event)
	removeActiveSurface(event.old_name)
	addActiveSurface(event.new_name)
end)

--When a player joins the game
script.on_event(defines.events.on_player_joined_game, function(event)
	addActiveSurface(game.players[event.player_index].surface.name)
end)

--When a player changes surfaces (Warptorio 2)
script.on_event(defines.events.on_player_changed_surface, function(event)
	--removeActiveSurface(game.surfaces[event.surface_index].name)
	addActiveSurface(game.players[event.player_index].surface.name)
end)

--Check if the entity was a recycler, and if so, add it to the list with its own timer
function addRecycler(entity, surface)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		local timer = global.timer
		local new_entity = {entity,timer}
		--If the list does not yet exist for this surface, create the list first
		if not global[surface] then
			global[surface] = {}
		end
		table.insert(global[surface],new_entity)
	end
end

--Check if the entity was a recycler, and if so, remove it from the list
function killRecycler(entity, surface)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		for key, list_entity in pairs (global[surface]) do
			if list_entity[1] == entity then
				table.remove(global[surface],key)
			end
		end
	end
end

function addActiveSurface(surface)
	local addSurface = true
	for _, oldSurface in pairs (global.activeSurfaces) do
		if string.find(surface, oldSurface, 1, true) then
			addSurface = false
			--game.players[1].print("Duplicate was located. addSurface = "..tostring(addSurface))
		end
	end
	if addSurface then
		--game.players[1].print("Current list: "..serpent.block(global.activeSurfaces))
		table.insert(global.activeSurfaces, surface)
		--game.players[1].print("Added: "..surface)
	end
end

function removeActiveSurface(surface)
	local removeSurface = false
	for key, oldSurface in pairs (global.activeSurfaces) do
		if string.match(surface, oldSurface) then
			table.remove(global.activeSurfaces, key)
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