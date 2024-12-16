/obj/item/dinnerware/plate
	name = "plate"
	desc = "Тарелка. Самая что ни на есть!"
	icon = 'icons/obj/dinnerware.dmi'
	icon_state = "plate"
	w_class = WEIGHT_CLASS_SMALL
	ru_names = list(NOMINATIVE = "тарелка", GENITIVE = "тарелки", DATIVE = "тарелке", ACCUSATIVE = "тарелку", INSTRUMENTAL = "тарелкой", PREPOSITIONAL = "тарелке")


/obj/item/dinnerware/plate/update_overlays()
	. = ..()
	underlays.Cut()
	if(contents)
		var/obj/item/reagent_containers/food/snacks/cooker/stored_food = contents[1]
		. += stored_food.icon_state


/obj/item/dinnerware/plate/attackby(obj/item, mob/user)
	if(istype(item, /obj/item/storage/combinated))
		//check if we can put some food into the plate
		take_or_place_to_dishes(item, user)
		return ATTACK_CHAIN_BLOCKED
	else
		return ATTACK_CHAIN_PROCEED


/obj/item/dinnerware/plate/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/storage/combinated))
		take_or_place_to_dishes(target, user)


/obj/item/dinnerware/plate/proc/take_or_place_to_dishes(obj/item/storage/combinated/dishes, mob/user)
	if(!istype(dishes))
		return FALSE

	var/need_update = FALSE

	if(contents.len)
		var/obj/item/reagent_containers/food/snacks/cooker/food = contents[1]
		if(dishes.can_be_inserted(food, FALSE))
			food.forceMove(dishes)
			to_chat(user, span_notice("Вы положили [food.declent_ru(ACCUSATIVE)] в [dishes.declent_ru(ACCUSATIVE)]."))
			need_update = TRUE

	else if((dishes.contents.len == 1) && istype(dishes.contents[1], /obj/item/reagent_containers/food/snacks/cooker))
		var/obj/item/reagent_containers/food/snacks/cooker/food = dishes.contents[1]
		food.forceMove(src)
		to_chat(user, span_notice("Вы положили [food.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		need_update = TRUE

	else if(!contents.len && !dishes.contents.len)
		user.balloon_alert(user, "пусто!")

	else if(dishes.contents.len > 1)
		user.balloon_alert(user, "слишком много ингредиентов!")

	else
		user.balloon_alert(user, "что-то не учли!")

	if(need_update)
		update_icon(UPDATE_OVERLAYS)







