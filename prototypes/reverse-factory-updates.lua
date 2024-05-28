--Data contains all functions contained in the Factorio stdlib
local Data = require('__stdlib__/stdlib/data/data')
local Recipe = require('__stdlib__/stdlib/data/recipe')
local Tech = require('__stdlib__/stdlib/data/technology')

function Recipe:clear_ingredients()
    if self:is_valid() then
        if self.normal then
            if self.normal.ingredients then
                self.normal.ingredients = {}
            end
		end
		if self.expensive then
            if self.expensive.ingredients then
                self.expensive.ingredients = {}
            end
		end
        if self.ingredients then
            self.ingredients = {}
        end
    end
    return self
end

function Recipe:set_ingredients(oldrecipe)
    if self:is_valid() then
		self:clear_ingredients()
		if data.raw.recipe[oldrecipe].ingredients then
			for _, ingredient in pairs(data.raw.recipe[oldrecipe].ingredients) do
				self:add_ingredient(ingredient)
			end
		else
			if data.raw.recipe[oldrecipe].normal then
				if data.raw.recipe[oldrecipe].normal.ingredients then
					for _, ingredient in pairs(data.raw.recipe[oldrecipe].normal.ingredients) do
						self:add_ingredient(ingredient)
					end
				end
			end
			if data.raw.recipe[oldrecipe].expensive then
				if data.raw.recipe[oldrecipe].normal.expensive then
					for _, ingredient in pairs(data.raw.recipe[oldrecipe].normal.expensive) do
						self:add_ingredient("",ingredient)
					end
				end
			end
		end
    end
    return self
end

--Game should be mostly vanilla at this point
if rf.mods ~= "DIR3" then
	Recipe("reverse-factory-1"):add_ingredient({"assembling-machine-1",2})
	Recipe("reverse-factory-2"):add_ingredient({"steel-plate",5})
	Recipe("reverse-factory-3"):add_ingredient({"stone-brick",10})
	Recipe("reverse-factory-4"):add_ingredient({"electric-furnace",2})
	Recipe("reverse-factory-2"):replace_ingredient("iron-plate","iron-gear-wheel")
	Recipe("reverse-factory-3"):replace_ingredient("iron-plate","pipe")
	Recipe("reverse-factory-3"):replace_ingredient("electronic-circuit","advanced-circuit")
	Recipe("reverse-factory-4"):replace_ingredient("iron-plate","steel-plate")
	Recipe("reverse-factory-4"):remove_ingredient("electronic-circuit")
	Recipe("reverse-factory-4"):add_ingredient({"effectivity-module",2})
	Tech("reverse-factory-1"):add_prereq("automation")
	Tech("reverse-factory-2"):add_prereq("automation-2")
	Tech("reverse-factory-3"):add_prereq("advanced-material-processing-2")
	Tech("reverse-factory-4"):add_prereq("automation-3")
	if not (mods["Krastorio2"] and mods["space-exploration"]) then
		Tech("reverse-factory-1"):set_field("unit",Tech("automation"):get_field("unit"))
	end
	Tech("reverse-factory-2"):set_field("unit",Tech("automation-2"):get_field("unit"))
	Tech("reverse-factory-3"):set_field("unit",Tech("advanced-material-processing-2"):get_field("unit"))
	Tech("reverse-factory-4"):set_field("unit",Tech("automation-3"):get_field("unit"))
end

--Only one of the below conditions will ever be true at one time.
--Priority follows what is set under data.lua, so intercompatibility is not guaranteed

--If Nullius mod is installed, total rewrite recipes and technologies
if rf.mods == "nullius" then
	--Clear ingredients, then copy ingredients from modded machine, and add previous tier
	Recipe("nullius-reverse-factory-1"):set_field("ingredients",{})
	Recipe("nullius-reverse-factory-1"):add_ingredient("nullius-small-assembler-1")
	for _, ingredient in pairs(data.raw.recipe["nullius-small-assembler-1"].ingredients) do
		Recipe("nullius-reverse-factory-1"):add_ingredient(ingredient)
	end
	Recipe("nullius-reverse-factory-2"):set_field("ingredients",{})
	Recipe("nullius-reverse-factory-2"):add_ingredient("nullius-reverse-factory-1")
	Recipe("nullius-reverse-factory-2"):add_ingredient("nullius-medium-assembler-1")
	for _, ingredient in pairs(data.raw.recipe["nullius-medium-assembler-1"].ingredients) do
		Recipe("nullius-reverse-factory-2"):add_ingredient(ingredient)
	end
	Recipe("nullius-reverse-factory-3"):set_field("ingredients",{})
	Recipe("nullius-reverse-factory-3"):add_ingredient("nullius-reverse-factory-2")
	Recipe("nullius-reverse-factory-3"):add_ingredient("nullius-large-assembler-2")
	for _, ingredient in pairs(data.raw.recipe["nullius-large-assembler-2"].ingredients) do
		Recipe("nullius-reverse-factory-3"):add_ingredient(ingredient)
	end
	Recipe("nullius-reverse-factory-4"):set_field("ingredients",{})
	Recipe("nullius-reverse-factory-4"):add_ingredient("nullius-reverse-factory-3")
	Recipe("nullius-reverse-factory-4"):add_ingredient("nullius-medium-furnace-2")
	for _, ingredient in pairs(data.raw.recipe["nullius-medium-furnace-2"].ingredients) do
		Recipe("nullius-reverse-factory-4"):add_ingredient(ingredient)
	end
	
	--Remove all existing vanilla prereqs
	Tech("nullius-reverse-factory-1"):remove_prereq("automation")
	Tech("nullius-reverse-factory-2"):remove_prereq("automation-2")
	Tech("nullius-reverse-factory-3"):remove_prereq("advanced-material-processing-2")
	Tech("nullius-reverse-factory-4"):remove_prereq("automation-3")
	
	--Then add the nullius prereq techs and copy nullius tech requirements
	Tech("nullius-reverse-factory-1"):add_prereq("nullius-automation")
	Tech("nullius-reverse-factory-1"):set_field("unit",Tech("nullius-automation"):get_field("unit"))
	Tech("nullius-reverse-factory-2"):add_prereq("nullius-mass-production-1")
	Tech("nullius-reverse-factory-2"):set_field("unit",Tech("nullius-mass-production-1"):get_field("unit"))
	Tech("nullius-reverse-factory-3"):add_prereq("nullius-mass-production-2")
	Tech("nullius-reverse-factory-3"):set_field("unit",Tech("nullius-mass-production-2"):get_field("unit"))
	Tech("nullius-reverse-factory-4"):add_prereq("nullius-metallurgy-3")
	Tech("nullius-reverse-factory-4"):set_field("unit",Tech("nullius-metallurgy-3"):get_field("unit"))
	
	--Finally, set crafting categories for all machines to only be built by assemblers
	Recipe("nullius-reverse-factory-1"):set_field("category","medium-assembly")
	Recipe("nullius-reverse-factory-2"):set_field("category","medium-assembly")
	Recipe("nullius-reverse-factory-3"):set_field("category","medium-assembly")
	Recipe("nullius-reverse-factory-4"):set_field("category","medium-assembly")
end

--If bobs intermediates is detected, then check if these items exist, and replace ingredients.
if rf.mods == "bobplates" then
	Recipe("reverse-factory-1"):add_ingredient("iron-gear-wheel",5)
	--Bob Electronics is not guaranteed, but change recipes if it exists
	if data.raw.item["basic-circuit-board"] then
		Recipe("reverse-factory-1"):replace_ingredient("electronic-circuit","basic-circuit-board")
		Recipe("reverse-factory-4"):remove_ingredient("effectivity-module")
		Recipe("reverse-factory-4"):add_ingredient({"processing-unit",5})
	end
	if data.raw.item["steel-gear-wheel"] then
		Recipe("reverse-factory-2"):replace_ingredient("iron-gear-wheel","steel-gear-wheel")
	end
	if data.raw.item["plastic-pipe"] then
		if data.raw.technology["plastic-1"] then
			Recipe("reverse-factory-3"):replace_ingredient("pipe","plastic-pipe")
			Tech("reverse-factory-3"):remove_prereq("advanced-material-processing-2")
			Tech("reverse-factory-3"):add_prereq("plastic-1")
			Tech("reverse-factory-3"):set_field("unit",Tech("plastic-1"):get_field("unit"))
		else
			Recipe("reverse-factory-3"):replace_ingredient("pipe","plastic-pipe")
			Tech("reverse-factory-3"):remove_prereq("advanced-material-processing-2")
			Tech("reverse-factory-3"):add_prereq("plastics")
			Tech("reverse-factory-3"):set_field("unit",Tech("plastics"):get_field("unit"))
		end
	end
	if data.raw.technology["tungsten-alloy-processing"] then
		Recipe("reverse-factory-4"):replace_ingredient("steel-plate","titanium-plate")
		Tech("reverse-factory-4"):remove_prereq("automation-3")
		Tech("reverse-factory-4"):add_prereq("titanium-processing")
		Tech("reverse-factory-4"):set_field("unit",Tech("titanium-processing"):get_field("unit"))
	end
end

--If Industrial Revolution is installed, complete overwrite recipes and technologies
if rf.mods == "DIR" then
	Recipe("reverse-factory-1"):set_field("ingredients",{})
	Recipe("reverse-factory-1"):add_ingredient("assembling-machine-1")
	for _, ingredient in pairs(data.raw.recipe["assembling-machine-1"].ingredients) do
		Recipe("reverse-factory-1"):add_ingredient(ingredient)
	end
	Recipe("reverse-factory-2"):set_field("ingredients",{})
	Recipe("reverse-factory-2"):add_ingredient("reverse-factory-1")
	Recipe("reverse-factory-2"):add_ingredient("assembling-machine-2")
	for _, ingredient in pairs(data.raw.recipe["assembling-machine-2"].expensive.ingredients) do
		Recipe("reverse-factory-2"):add_ingredient(ingredient)
	end
	Recipe("reverse-factory-3"):set_field("ingredients",{})
	Recipe("reverse-factory-3"):add_ingredient("reverse-factory-2")
	Recipe("reverse-factory-3"):add_ingredient("assembling-machine-3")
	for _, ingredient in pairs(data.raw.recipe["assembling-machine-3"].ingredients) do
		Recipe("reverse-factory-3"):add_ingredient(ingredient)
	end
	Recipe("reverse-factory-4"):set_field("ingredients",{})
	Recipe("reverse-factory-4"):add_ingredient("reverse-factory-3")
	Recipe("reverse-factory-4"):add_ingredient("arc-furnace")
	for _, ingredient in pairs(data.raw.recipe["arc-furnace"].ingredients) do
		Recipe("reverse-factory-4"):add_ingredient(ingredient)
	end
	
	Data("reverse-factory-1","furnace"):set_field("energy_source",Data("assembling-machine-1","assembling-machine"):get_field("energy_source"))
	Data("reverse-factory-1","furnace"):set_field("energy_usage",Data("assembling-machine-1","assembling-machine"):get_field("energy_usage"))
	
	Tech("reverse-factory-3"):remove_prereq("advanced-material-processing-2")
	Tech("reverse-factory-3"):add_prereq("automation-3")
	Tech("reverse-factory-4"):remove_prereq("automation-3")
	Tech("reverse-factory-4"):add_prereq("ir2-furnaces-3")

	--Tech("reverse-factory-1"):set_field("unit",Tech("automation-1"):get_field("unit"))
	Tech("reverse-factory-2"):set_field("unit",Tech("automation-2"):get_field("unit"))
	Tech("reverse-factory-3"):set_field("unit",Tech("automation-3"):get_field("unit"))
	Tech("reverse-factory-4"):set_field("unit",Tech("ir2-furnaces-3"):get_field("unit"))
end

if rf.mods == "DIR3" then
	Recipe("reverse-factory-1"):set_ingredients("assembling-machine-1")
	--Recipe("reverse-factory-1"):add_ingredient("assembling-machine-1")
	
	Recipe("reverse-factory-2"):set_ingredients("assembling-machine-2")
	Recipe("reverse-factory-2"):add_ingredient("reverse-factory-1")
	
	Recipe("reverse-factory-3"):set_ingredients("assembling-machine-3")
	Recipe("reverse-factory-3"):add_ingredient("reverse-factory-2")
	
	Recipe("reverse-factory-4"):set_ingredients("laser-assembler")
	Recipe("reverse-factory-4"):remove_ingredient("assembling-machine-3")
	Recipe("reverse-factory-4"):add_ingredient("reverse-factory-3")
	
	Tech("reverse-factory-1"):add_prereq("automation")
	Tech("reverse-factory-2"):add_prereq("automation-2")
	Tech("reverse-factory-3"):add_prereq("automation-3")
	Tech("reverse-factory-4"):add_prereq("automation-4")

	Tech("reverse-factory-1"):set_field("unit",Tech("automation"):get_field("unit"))
	Tech("reverse-factory-2"):set_field("unit",Tech("automation-2"):get_field("unit"))
	Tech("reverse-factory-3"):set_field("unit",Tech("automation-3"):get_field("unit"))
	Tech("reverse-factory-4"):set_field("unit",Tech("automation-4"):get_field("unit"))
end

--If Fantario is installed
if rf.mods == "fantario" then
	--Change assembling machines to heat-based power, and balance to heat-based assemblers
	Data("reverse-factory-1","furnace"):set_field("energy_source",Data("assembling-machine-1","assembling-machine"):get_field("energy_source"))
	Data("reverse-factory-1","furnace"):set_field("energy_usage",Data("assembling-machine-1","assembling-machine"):get_field("energy_usage"))
	Data("reverse-factory-2","furnace"):set_field("energy_source",Data("assembling-machine-2","assembling-machine"):get_field("energy_source"))
	Data("reverse-factory-2","furnace"):set_field("energy_usage",Data("assembling-machine-2","assembling-machine"):get_field("energy_usage"))
	Data("reverse-factory-3","furnace"):set_field("energy_source",Data("assembling-machine-3","assembling-machine"):get_field("energy_source"))
	Data("reverse-factory-3","furnace"):set_field("energy_usage",Data("assembling-machine-3","assembling-machine"):get_field("energy_usage"))

	--Change reverse factory recipes and technologies
	Recipe("reverse-factory-2"):replace_ingredient("steel-plate","iron-frame")
	Recipe("reverse-factory-3"):replace_ingredient("stone-brick","steel-frame")
	Recipe("reverse-factory-3"):replace_ingredient("advanced-circuit","effectivity-module")

	Recipe("reverse-factory-4"):replace_ingredient("steel-plate","steel-frame")
	Recipe("reverse-factory-4"):replace_ingredient("effectivity-module","electric-engine-unit")
	Recipe("reverse-factory-4"):replace_ingredient("electric-furnace","assembling-machine-4")

	Tech("reverse-factory-3"):remove_prereq("advanced-material-processing-2")
	Tech("reverse-factory-3"):add_prereq("steel-processing")
	Tech("reverse-factory-3"):set_field("unit",Tech("steel-processing"):get_field("unit"))

	Tech("reverse-factory-4"):remove_prereq("automation-3")
	Tech("reverse-factory-4"):add_prereq("electric-engine")
	Tech("reverse-factory-4"):set_field("unit",Tech("electric-engine"):get_field("unit"))

	--Move reverse factory T4 next to electric assembling machine, in electric machines tab.
	Data("reverse-factory-4","item"):set_field("subgroup",Data("assembling-machine-4","item"):get_field("subgroup"))
	Data("reverse-factory-4","item"):set_field("order",Data("assembling-machine-4","item"):get_field("order").."-z")
end

--If bobs assembly without bobs intermediates
if rf.mods == "bobassembly" then
	Tech("reverse-factory-4"):remove_prereq("automation-3")
	Tech("reverse-factory-4"):add_prereq("advanced-material-processing-3")
	Tech("reverse-factory-4"):set_field("unit",Tech("advanced-material-processing-3"):get_field("unit"))
end













