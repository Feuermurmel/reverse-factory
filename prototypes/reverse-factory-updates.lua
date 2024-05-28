--Data contains all functions contained in the Factorio stdlib
local Data = require('__stdlib__/stdlib/data/data')
local Recipe = require('__stdlib__/stdlib/data/recipe')
local Tech = require('__stdlib__/stdlib/data/technology')

--Game should be mostly vanilla at this point
Recipe("reverse-factory-1"):add_ingredient({"assembling-machine-1",2})
Recipe("reverse-factory-2"):add_ingredient({"steel-plate",5})
Recipe("reverse-factory-3"):add_ingredient({"stone-brick",10})
Recipe("reverse-factory-4"):add_ingredient({"electric-furnace",2})
Recipe("reverse-factory-2"):replace_ingredient("iron-plate","iron-gear-wheel")
Recipe("reverse-factory-3"):replace_ingredient("iron-plate","pipe")
Recipe("reverse-factory-4"):replace_ingredient("iron-plate","steel-plate")
Recipe("reverse-factory-3"):replace_ingredient("electronic-circuit","advanced-circuit")
Recipe("reverse-factory-4"):replace_ingredient("electronic-circuit","effectivity-module")
Tech("reverse-factory-1"):add_prereq("automation")
Tech("reverse-factory-2"):add_prereq("automation-2")
Tech("reverse-factory-3"):add_prereq("advanced-material-processing-2")
Tech("reverse-factory-4"):add_prereq("automation-3")
Tech("reverse-factory-1"):set_field("unit",Tech("automation"):get_field("unit"))
Tech("reverse-factory-2"):set_field("unit",Tech("automation-2"):get_field("unit"))
Tech("reverse-factory-3"):set_field("unit",Tech("advanced-material-processing-2"):get_field("unit"))
Tech("reverse-factory-4"):set_field("unit",Tech("automation-3"):get_field("unit"))


--If bobs electronics, change advanced green circuit to basic green circuit
if bobmods then
	if data.raw.item["basic-circuit-board"] then
		Recipe("reverse-factory-1"):replace_ingredient("electronic-circuit","basic-circuit-board")
		Recipe("reverse-factory-1"):add_ingredient("iron-gear-wheel",5)
	end
	if data.raw.item["steel-gear-wheel"] then
		Recipe("reverse-factory-2"):replace_ingredient("iron-gear-wheel","steel-gear-wheel")
	end
	if data.raw.item["plastic-pipe"] then
		Recipe("reverse-factory-3"):replace_ingredient("pipe","plastic-pipe")
		Tech("reverse-factory-3"):remove_prereq("advanced-material-processing-2")
		Tech("reverse-factory-3"):add_prereq("plastics")
		Tech("reverse-factory-3"):set_field("unit",Tech("plastics"):get_field("unit"))
	end
	if data.raw.technology["tungsten-alloy-processing"] then
		Recipe("reverse-factory-4"):replace_ingredient("steel-plate","titanium-plate")
		Recipe("reverse-factory-4"):replace_ingredient("effectivity-module","processing-unit")
		Tech("reverse-factory-4"):remove_prereq("automation-3")
		Tech("reverse-factory-4"):add_prereq("titanium-processing")
		Tech("reverse-factory-4"):set_field("unit",Tech("titanium-processing"):get_field("unit"))
	end
end