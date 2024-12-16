/obj/item/reagent_containers/food/snacks/cooker
	icon = 'icons/obj/dinnerware.dmi'

/datum/recipe/cooker/spaghettiboiled
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti
		)
	time = 20 SECONDS
	result = /obj/item/reagent_containers/food/snacks/cooker/spaghettiboiled

/obj/item/reagent_containers/food/snacks/cooker/spaghettiboiled
	name = "Spaghetti"
	desc = "Yum."
	icon_state = "plate_overlay_spaghetti"

/datum/recipe/cooker/spaghettimeat
	reagents = list("cornoil" = 5)
	items = list (
		/obj/item/reagent_containers/food/snacks/cooker/spaghettiboiled,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/grown/tomato
		)
	time = 20 SECONDS
	result = /obj/item/reagent_containers/food/snacks/cooker/spaghettimeat

/obj/item/reagent_containers/food/snacks/cooker/spaghettimeat
	name = "Spaghetti with meatballs"
	desc = "Yum, but better!"
	icon_state = "plate_overlay_spaghettimeat"
