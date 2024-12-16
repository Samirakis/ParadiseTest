/datum/food
	var/name = "Food"
	var/desc = "If you see this, report to a coder"
	var/portions = 2
	var/overlay_icon = null
	var/list/ingredients = list()
	var/list/liquid_ingredients = list()


/datum/food/snacks/spaghettiboiled
	name = "Spaghetti"
	desc = "Вкусно, но чего-то не хватает.."
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
	)
	liquid_ingredients = list("water" = 10)
