--Remove Bio Industries dissassemble recipes
if data.raw.recipe["bi-burner-mining-drill-disassemble"] then
  data.raw.recipe["bi-burner-mining-drill-disassemble"] = nil
  data.raw.recipe["bi-steel-furnace-disassemble"] = nil
  thxbob.lib.tech.remove_recipe_unlock("advanced-material-processing", "bi-steel-furnace-disassemble")
end