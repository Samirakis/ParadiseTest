#define TEMP_MINIMUM    28
#define TEMP_COOKING	100
#define TEMP_MAXIMUM	120
#define HEATING			5
#define COOLING 		2
#define TIME_TO_MESS 	30
#define LEFT_BURNER 	"left_cooker"
#define RIGHT_BURNER    "right_cooker"
#define COOKER_OVEN     "oven_slot"


/obj/machinery/electric_cooker
	name = "electric cooker"
	desc = "Электроплита. Настоящая!"
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "cooker_base"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/recipe_type = RECIPE_COOKER
	ru_names = list(NOMINATIVE = "электроплита", GENITIVE = "электроплиты", DATIVE = "электроплите", ACCUSATIVE = "электроплиту", INSTRUMENTAL = "электроплитой", PREPOSITIONAL = "электроплите")
	var/cooker_temperature = 30
	var/oven_temperature = 30
	var/cooker_on = FALSE
	var/oven_on = FALSE
	var/possible_cooker_items = list(
		/obj/item/storage/combinated/pan,
		/obj/item/storage/combinated/cookpot,
	)

	var/possible_oven_items = list(

	)

	var/list/cooker_slots = list(
		LEFT_BURNER = list("dishes", "recipe", "remain_time"),
		RIGHT_BURNER = list("dishes", "recipe", "remain_time"),
		COOKER_OVEN = list("dishes", "recipe", "remain_time")
	)


/obj/machinery/electric_cooker/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/oven(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	START_PROCESSING(SSmachines, src)
	initialize_list()


/obj/machinery/electric_cooker/process()
	thermal_process()

	for(var/i in cooker_slots)
		var/cooker_slot = cooker_slots[i]
		var/obj/item/storage/combinated/dishes = cooker_slot["dishes"]
		if(dishes && dishes.contents.len)
			cooking_process(i)


/obj/machinery/electric_cooker/examine(mob/user)
	. = ..()
	. += span_notice("[anchored ? "Прикручена" : "Откручена"]")
	. += span_notice("Конфорка [cooker_on ? "включена" : "выключена"], [cooker_temperature]℃")
	. += span_notice("Духовка [oven_on ? "включена" : "выключена"], [oven_temperature]℃")
	var/obj/item/stored_item = cooker_slots[LEFT_BURNER]["dishes"]
	if(stored_item)
		. += span_notice("Слева: [stored_item.declent_ru(NOMINATIVE)]")
	stored_item = cooker_slots[RIGHT_BURNER]["dishes"]
	if(stored_item)
		. += span_notice("Справа: [stored_item.declent_ru(NOMINATIVE)]")


/obj/machinery/electric_cooker/power_change(forced = FALSE)
	. = ..()
	if(stat & NOPOWER)
		turn_full_off()
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/electric_cooker/proc/cooking_process(slot_name)
	var/cooker_slot = cooker_slots[slot_name]
	var/datum/recipe/recipe = cooker_slot["recipe"]
	var/obj/item/reagent_containers/food/snacks/recipe_result = /obj/item/reagent_containers/food/snacks/badrecipe
	var/maximum_time = TIME_TO_MESS
	var/obj/item/storage/combinated/dishes = cooker_slot["dishes"]

	if(recipe)
		if((dishes.contents.len == 1) && (dishes.contents[1] == recipe_result))
			return //no need to burn burned mess again..

		recipe_result = recipe.result
		maximum_time = round(recipe.time / 10)

	if(get_slot_temperature(slot_name) > TEMP_COOKING)
		cooker_slot["remain_time"]--
		if(cooker_slot["remain_time"] == 0) //food is done, put it into our dishes and reset recipe
			finish_cooking(dishes, recipe_result)
			set_recipe(slot_name)
	else
		cooker_slot["remain_time"] = min(cooker_slot["remain_time"]++, maximum_time)


/obj/machinery/electric_cooker/proc/finish_cooking(obj/item/storage/combinated/dishes, result)
	for(var/obj/item/reagent_containers/ingredient in dishes.contents)
		qdel(ingredient)
	dishes.reagents.clear_reagents()
	var/obj/cooked = new result()
	cooked.forceMove(dishes)
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)


/obj/machinery/electric_cooker/proc/set_recipe(slot_name)
	var/slot = cooker_slots[slot_name]
	var/obj/item/dishes = slot["dishes"]
	if(dishes)
		if(!dishes.contents.len)
			slot["recipe"] = null
			slot["remain_time"] = null
			return

		var/datum/recipe/recipe = select_recipe(GLOB.cooking_recipes[recipe_type], dishes)
		slot["recipe"] = recipe ? recipe : null
		slot["remain_time"] = recipe ? (round(recipe.time / 10)) : TIME_TO_MESS

	else
		slot["recipe"] = null
		slot["remain_time"] = null


/obj/machinery/electric_cooker/proc/radial_menu(mob/user)
	var/list/choises = list()

	var/obj/item/right_item = cooker_slots[RIGHT_BURNER]["dishes"]
	var/right_choise = (right_item ? "Взять справа" : "Поставить справа")

	var/obj/item/left_item = cooker_slots[LEFT_BURNER]["dishes"]
	var/left_choise = (left_item ? "Взять слева" : "Поставить слева")

	var/obj/item/oven_item = cooker_slots[COOKER_OVEN]["dishes"]
	var/oven_choise = (oven_item ? "Достать из духовки" : "Поставить в духовку")

	choises["Переключить"] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = "button_power")
	choises[right_choise] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = (right_item ? "button_pick_right" : "button_put_right"))
	choises[oven_choise] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = (oven_item ? "button_pick_oven" : "button_put_oven"))
	choises[left_choise] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = (left_item ? "button_pick_left" : "button_put_left"))

	var/choise = show_radial_menu(user, src, choises, require_near = TRUE)
	//closed
	if(!choise)
		return

	//toggling cooker/oven and selecting cooker slot for working with
	var/obj/item/storage/combinated/taken_item = null
	var/selected = null

	if(choise == "Переключить")
		activation_radial_menu(user)
		return
	else if(choise == right_choise)
		taken_item = right_item
		selected = RIGHT_BURNER
	else if(choise == left_choise)
		taken_item = left_item
		selected = LEFT_BURNER
	else if(choise == oven_choise)
		taken_item = oven_item
		selected = COOKER_OVEN

	var/need_update = FALSE
	var/obj/item/O = user.get_active_hand()

	//take item
	if(taken_item)
		if(user.put_in_hands(taken_item, ignore_anim = FALSE))
			to_chat(user, span_notice("Вы достали [taken_item.declent_ru(ACCUSATIVE)] из [src.declent_ru(GENITIVE)]."))
			cooker_slots[selected]["dishes"] = null
			need_update = TRUE

	//put item in
	else if(O)
		if((((choise == right_choise) || (choise == left_choise)) && (O.type in possible_cooker_items)) || ((choise == oven_choise) && (O.type in possible_oven_items)))
			user.drop_transfer_item_to_loc(O, src)
			cooker_slots[selected]["dishes"] = O
			to_chat(user, span_notice("Вы положили [O.declent_ru(ACCUSATIVE)] в [src.declent_ru(ACCUSATIVE)]."))
			need_update = TRUE
		else
			to_chat(user, span_warning("Ставить сюда [O.declent_ru(ACCUSATIVE)] - не лучшая идея."))

	//neither in hands nor in slot
	else
		user.balloon_alert(user, "нечего ставить!")

	if(need_update)
		set_recipe(selected)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/electric_cooker/proc/activation_radial_menu(mob/user)
	var/list/choises = list()
	choises[cooker_on ? "Выключить плиту" : "Включить плиту"] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = (cooker_on ? "button_cooker_off" : "button_cooker_on"))
	choises[oven_on ? "Выключить духовку" : "Включить духовку"] = image(icon = 'icons/obj/machines/cooking_machines.dmi', icon_state = (oven_on ? "button_oven_off" : "button_oven_on"))
	var/choise = show_radial_menu(user, src, choises, require_near = TRUE)
	var/need_update = FALSE

	if(!choise)
		return
	if(stat & NOPOWER)
		user.balloon_alert(user, "нет питания!")
		return FALSE
	if(!anchored)
		user.balloon_alert(user, "не прикручено!")
		return FALSE
	if((choise == "Выключить плиту") || (choise == "Включить плиту"))
		cooker_on = !cooker_on
		need_update = TRUE
	if((choise == "Выключить духовку") || (choise ==  "Включить духовку"))
		oven_on = !oven_on
		need_update = TRUE

	if(need_update)
		update_icon(UPDATE_OVERLAYS)


/*
/obj/machinery/electric_cooker/update_icon_state()
	if(is_full_off())
		icon_state = initial(icon_state)
*/


/obj/machinery/electric_cooker/update_overlays()
	. = ..()
	underlays.Cut()
	if(cooker_on)
		. += "overlay_cooker_on"
		. += emissive_appearance(icon, "overlay_cooker_on", src)
	if(oven_on)
		. += "overlay_oven_on"
		. += emissive_appearance(icon, "overlay_oven_on", src)
	if(cooker_slots[LEFT_BURNER]["dishes"])
		var/obj/item/storage/combinated/slot_item = cooker_slots[LEFT_BURNER]["dishes"]
		. += "overlay_left_[initial(slot_item.icon_state)]"
	if(cooker_slots[RIGHT_BURNER]["dishes"])
		var/obj/item/storage/combinated/slot_item = cooker_slots[RIGHT_BURNER]["dishes"]
		. += "overlay_right_[initial(slot_item.icon_state)]"


/obj/machinery/electric_cooker/attack_hand(mob/user)
	if(!user)
		return

	add_fingerprint(user)

	if(user.a_intent == INTENT_DISARM)
		turn_full_off()
		to_chat(user, span_notice("[capitalize(src.declent_ru(NOMINATIVE))] выключена."))

	if(user.a_intent == INTENT_HELP)
		radial_menu(user)


/obj/machinery/electric_cooker/attackby(obj/item/O, mob/user, params)
	if(is_full_off() && default_deconstruction_screwdriver(user, icon_state, O)) //its not working now
		add_fingerprint(user)
		return

	if(is_full_off() && O.tool_behaviour == TOOL_WRENCH)
		add_fingerprint(user)
		playsound(src, O.usesound, 50, 1)
		set_anchored(!anchored)
		if(anchored)
			user.balloon_alert(user, "[src.declent_ru(NOMINATIVE)] прикручена!")
		else
			user.balloon_alert(user, "[src.declent_ru(NOMINATIVE)] откручена!")
		return

	if(user.a_intent == INTENT_HELP)
		radial_menu(user)
	else
		. = ..()


/obj/machinery/electric_cooker/proc/initialize_list()
	if(!GLOB.cooking_recipes[recipe_type])
		GLOB.cooking_recipes[recipe_type] = list()
		GLOB.cooking_ingredients[recipe_type] = list()
		GLOB.cooking_reagents[recipe_type] = list()
	if(!length(GLOB.cooking_recipes[recipe_type]))
		for(var/type in subtypesof(GLOB.cooking_recipe_types[recipe_type]))
			var/datum/recipe/recipe = new type
			if(recipe in GLOB.cooking_recipes[recipe_type])
				qdel(recipe)
				continue
			if(recipe.result) // Ignore recipe subtypes that lack a result
				GLOB.cooking_recipes[recipe_type] += recipe
				for(var/item in recipe.items)
					GLOB.cooking_ingredients[recipe_type] |= item
				for(var/reagent in recipe.reagents)
					GLOB.cooking_reagents[recipe_type] |= reagent
			else
				qdel(recipe)
		GLOB.cooking_ingredients[recipe_type] |= /obj/item/reagent_containers/food/snacks/grown


/obj/machinery/electric_cooker/proc/is_full_off()
	return !(oven_on || cooker_on)


/obj/machinery/electric_cooker/proc/turn_full_off()
	cooker_on = FALSE
	oven_on = FALSE
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/electric_cooker/proc/grab_all_items(mob/user)
	for(var/i in cooker_slots)
		if(i)
			user.put_in_hands(cooker_slots[i]["dishes"])
			cooker_slots[i]["dishes"] = null
	to_chat(user, span_notice("Вы достали всё из [src.declent_ru(GENITIVE)]"))


/obj/machinery/electric_cooker/proc/thermal_process()
	/// temperature processing
	if(cooker_on)
		if(cooker_temperature < TEMP_MAXIMUM)
			cooker_temperature += HEATING
	else
		if(cooker_temperature > TEMP_MINIMUM)
			cooker_temperature -= COOLING
	if(oven_on)
		if(oven_temperature < TEMP_MAXIMUM)
			oven_temperature += HEATING
	else
		if(oven_temperature > TEMP_MINIMUM)
			oven_temperature -= COOLING


/obj/machinery/electric_cooker/proc/get_slot_temperature(var/slot_name)
	if((slot_name == LEFT_BURNER) || (slot_name == RIGHT_BURNER))
		. = cooker_temperature
	else if(slot_name == COOKER_OVEN)
		. = oven_temperature


#undef TEMP_MINIMUM
#undef TEMP_COOKING
#undef TEMP_MAXIMUM
#undef HEATING
#undef COOLING
#undef TIME_TO_MESS
#undef LEFT_BURNER
#undef RIGHT_BURNER
#undef COOKER_OVEN

