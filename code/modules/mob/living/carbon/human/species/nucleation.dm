/datum/species/nucleation
	name = SPECIES_NUCLEATION
	name_plural = "Nucleations"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	blacklisted = TRUE
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = LANGUAGE_SOL_COMMON
	blood_color = "#ada776"
	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam
	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_BLOOD, NO_PAIN, NO_PAIN_FEEL, NO_SCAN, RADIMMUNE, VIRUSIMMUNE, NO_GERMS, NO_OBESITY)
	dies_at_threshold = TRUE
	var/touched_supermatter = FALSE

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG

	hunger_icon = 'icons/mob/screen_hunger_nucleation.dmi'
	hunger_type = "nucleation"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/crystal,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_STRANGE_CRYSTAL = /obj/item/organ/internal/nucleation/strange_crystal,
		INTERNAL_ORGAN_RESONANT_CRYSTAL = /obj/item/organ/internal/nucleation/resonant_crystal,
	)


	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/nucleation


/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	. =..()
	ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, SPECIES_TRAIT)
	H.update_movespeed_damage_modifiers()
	H.light_color = "#afaf21"
	H.set_light_range(2)


/datum/species/nucleation/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, SPECIES_TRAIT)
	H.update_movespeed_damage_modifiers()
	H.light_color = null
	H.set_light_on(FALSE)


/datum/species/nucleation/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	var/reagent_nutrition = 0

	switch(R.id)

		if("radium")
			if(R.volume < 1)
				return TRUE
			H.adjustBruteLoss(-3)
			H.adjustFireLoss(-3)
			H.reagents.remove_reagent(R.id, 1)
			if(H.radiation < 80)
				H.apply_effect(4, IRRADIATE, negate_armor = 1)
			if((H.nutrition < NUTRITION_LEVEL_FULL - 5) && !isvampire(H))
				reagent_nutrition = 5 // just for convenience
				H.adjust_nutrition(reagent_nutrition)
			return FALSE //Что бы не выводилось больше одного, который уже вывелся за счет прока

		if("uranium") // sugar for nucleations!
			reagent_nutrition = 5
		if("polonium") // 3 times more than sugar for unit
			reagent_nutrition = 15

		// uranuim-based drinks does 2 times less nutrition than sugar
		if("atomicbomb", "manhattan_proj", "threemileisland", "nagasaki", "singulo", "nuka_cola")
			reagent_nutrition = 2.5

		// mutagens = 5 times less
		if("mutagen")
			reagent_nutrition = 1
		if("stable_mutagen")
			if((H.nutrition < NUTRITION_LEVEL_FULL - 5) && !isvampire(H))
				reagent_nutrition = 1
				H.adjust_nutrition(reagent_nutrition * R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio)
			H.apply_effect(1, IRRADIATE, negate_armor = 1)
			H.reagents.remove_reagent(R.id, R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE // stable don`t work on nucleation, just remove it

		// now makes you hungry!
		if("potass_iodide")
			reagent_nutrition = -2.5 // -1 nutri/tick
		if("pen_acid")
			reagent_nutrition = -17.5 // -7 nutri/tick

		// now can`t make you hungry, but..
		if("lipolicide")
			if(isvampire(H))
				return TRUE // ..lipolicide works on all vampires
			H.reagents.remove_reagent(R.id, R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE

		// food makes no nutrition for nucleations, it works only for /reagent/consumable inside nucleation mob, won`t affect reagents in beakers\food
		else if (istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/Reagent = R
			if(Reagent.nutriment_factor)
				Reagent.nutriment_factor = 0

	if(!((H.nutrition > NUTRITION_LEVEL_FULL - 5 && reagent_nutrition >= 0) || isvampire(H))) // no abuses for 1000+ nutrition
		H.adjust_nutrition(reagent_nutrition * R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio) // absolutely no one using digestion_ratio, but..
	return TRUE

/datum/species/nucleation/handle_life(mob/living/carbon/human/H)
	if(H.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA - 50) // 50
		H.adjustBruteLoss(1)
	..()


/datum/species/nucleation/handle_death(gibbed, mob/living/carbon/human/H)
	if(H.health <= HEALTH_THRESHOLD_DEAD || !H.surgeries.len) // Needed to prevent brain gib on surgery debrain
		death_explosion(H)
		return
	H.adjustBruteLoss(15)
	H.do_jitter_animation(1000, 8)

/datum/species/nucleation/proc/death_explosion(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	H.visible_message(span_warning("Тело [H] взрывается, оставляя после себя множество микроскопических кристаллов!"))
	explosion(T, 0, 0, 3, 6, cause = H) // Create a small explosion burst upon death
	qdel(H)
