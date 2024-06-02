if settings.global["rf-compati"].value then

function checkinvs()
	--Run through every currently active surface
	for _, surface in pairs(global.surfaces) do
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
					entity[2]=settings.global["rf-timer"].value
				end
			end
		end end
	end
end

--This should only run on map initialization, resetting the global variables needed
function initworld()
	--It's easier to remake the list of recyclers, than to check for duplicates, on map load
	global = {}
	global.surfaces = {}
	--global.delay = settings.global["rf-delay"].value
	--global.timer = settings.global["rf-timer"].value
	--Check every game surface in the world
	for key, surface in pairs(game.surfaces) do
		for n=1, 4 do
			--Check the list of entities for any placed recyclers
			local rfname = "reverse-factory-"..n
			local list = game.surfaces[key].find_entities_filtered{name=rfname}
			--And add them to the list for that specific surface
			for _, entity in pairs(list) do
				addRecycler(entity, surface.name)
			end
		end
	end
end

--Scan the world for recyclers and place them in a list, previously created by initworld()
--That's what this function did originally, but now it just resets the surface list.
function scanworld(surface)
	--game.players[1].print("Number of game surfaces :"..#game.surfaces)
	--game.players[1].print("Number of global surfaces :"..#global.surfaces)
	global[surface] = {}
end

--This sets up the timer to check recycler inventories every nth tick (defined in settings)
--Initializes the function to be called on map load, and settings changed.
function setup_checkinvs()
    --Remove previously set up on_nth_tick() handler, if any.
    script.on_nth_tick(nil)
    script.on_nth_tick(settings.global["rf-delay"].value, checkinvs)
end

--When mod settings are changed, updates the "on nth tick" timer.
script.on_event(defines.events.on_runtime_mod_setting_changed, setup_checkinvs)

--Runs immediately on map load.
setup_checkinvs()

--This only runs when this mod is initially added to game.
script.on_init( function()
	initworld()
end)

--This runs whenever the modlist is updated or modified.
script.on_configuration_changed( function()
	initworld()
end)

--When a recycler is placed, add it to the list
script.on_event(defines.events.on_robot_built_entity, function(event)
	addRecycler(event.created_entity, event.created_entity.surface.name)
end)

script.on_event(defines.events.on_built_entity, function(event)
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
	addSurface(game.surfaces[event.surface_index].name)
end)

--Just after the surface is cleared
script.on_event(defines.events.on_surface_cleared, function(event)
	addSurface(game.surfaces[event.surface_index].name)
end)

--Just before the surface is deleted
script.on_event(defines.events.on_pre_surface_deleted, function(event)
	removeSurface(game.surfaces[event.surface_index].name)
end)

--Just before the surface is cleared of all entites
script.on_event(defines.events.on_pre_surface_cleared, function(event)
	local surface = game.surfaces[event.surface_index].name
	removeSurface(game.surfaces[event.surface_index].name)
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
	removeSurface(event.old_name)
	addSurface(event.new_name)
end)

--When a player joins the game
script.on_event(defines.events.on_player_joined_game, function(event)
	addSurface(game.players[event.player_index].surface.name)
end)

--When a player changes surfaces
script.on_event(defines.events.on_player_changed_surface, function(event)
	--removeSurface(game.surfaces[event.surface_index].name)
	addSurface(game.players[event.player_index].surface.name)
	
	if game.active_mods["warptorio2"] then
		scanworld(game.surfaces[event.surface_index])
	end
end)

--Check if the entity was a recycler, and if so, add it to the list with its own timer
function addRecycler(entity, surface)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		local timer = settings.global["rf-timer"].value
		local new_entity = {entity,timer}
		--If the list does not yet exist for this surface, create the list first
		if not global[surface] then
			addSurface(surface)
			global[surface] = {}
		end
		--game.players[1].print(("Recycler added to: "..surface))
		table.insert(global[surface],new_entity)
	end
end

--Check if the entity was a recycler, and if so, remove it from the list
function killRecycler(entity, surface)
	if string.find(entity.name, "reverse") and string.find(entity.name, "factory") then
		for key, list_entity in pairs (global[surface]) do
			if list_entity[1] == entity then
				table.remove(global[surface],key)
				--game.players[1].print(("Recycler removed from: "..surface))
			end
		end
	end
end

function addSurface(surface)
	local toAddSurface = true
	for _, oldSurface in pairs (global.surfaces) do
		if string.find(surface, oldSurface, 1, true) then
			toAddSurface = false
			--game.players[1].print("Duplicate entry: "..surface)
		end
	end
	if toAddSurface then
		--game.players[1].print("Current list: "..serpent.block(global.surfaces))
		table.insert(global.surfaces, surface)
		--game.players[1].print("Added: "..surface)
	end
end

function removeSurface(surface)
	for key, oldSurface in pairs (global.surfaces) do
		if string.match(surface, oldSurface) then
			table.remove(global.surfaces, key)
		end
	end
end

--Countdown timer by the delay amount
function countdown(timer)
	local timer = timer - settings.global["rf-delay"].value
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