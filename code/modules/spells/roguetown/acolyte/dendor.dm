// Druid
/obj/effect/proc_holder/spell/targeted/blesscrop
	name = "Bless Crops"
	range = 5
	overlay_state = "blesscrop"
	releasedrain = 30
	charge_max = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "The Treefather commands thee, be fruitful!"
	invocation_type = "shout" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/targeted/blesscrop/cast(list/targets,mob/user = usr)
	. = ..()
	var/growed = FALSE
	var/amount_blessed = 0
	for(var/obj/structure/soil/soil in view(4))
		soil.bless_soil()
		growed = TRUE
		amount_blessed++
		// Blessed only up to 5 crops
		if(amount_blessed >= 5)
			break
	if(growed)
		visible_message(span_green("[usr] blesses the nearby crops with Dendor's Favour!"))
	return growed

/obj/effect/proc_holder/spell/invoked/beasttame
	name = "Tame Beast"
	range = 5
	overlay_state = "tamebeast"
	releasedrain = 30
	chargetime = 15
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	charge_max = 15 SECONDS
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "Be still and calm, brotherbeast."
	invocation_type = "none" // can be none, whisper, emote, or shout
	miracle = TRUE
	devotion_cost = 30


/obj/effect/proc_holder/spell/invoked/beasttame/cast(list/targets, mob/user = usr)
	. = ..()
	visible_message(span_green("[usr] calms the beastblood with Dendor's blessing."))

	// This list should contain all the creatures that can be tamed with this spell.
	var/list/tame_types = list(
		/mob/living/simple_animal/hostile/retaliate/rogue/wolf,
		/mob/living/simple_animal/hostile/retaliate/rogue/bigrat,
		/mob/living/simple_animal/hostile/retaliate/rogue/spider,
		/mob/living/simple_animal/hostile/retaliate/rogue/saiga,
		/mob/living/simple_animal/hostile/retaliate/rogue/saigabuck,
	)

	if(!targets.len || !istype(targets[1], /mob/living/simple_animal) || targets[1].stat == DEAD)
		to_chat(user, span_warning("You must target a valid creature!"))
		return FALSE

	var/mob/living/simple_animal/target = targets[1]

	if(!(target.type in tame_types))
		to_chat(user, span_warning("You cannot tame that!"))
		return FALSE

	if(target.tame)
		to_chat(user, span_warning("This creature is already tamed!"))
		return FALSE

	else if(target.awakened)
		to_chat(user, span_warning("This creature is awakened!"))
		return FALSE

	target.visible_message(span_warning("The [target.real_name]'s body is engulfed by a calming aura..."), runechat_message = TRUE)
	target.faction = list("neutral") // Kind of a hacky fix to pacify, but it works. 
	target.tame = TRUE
	target.owner = user
	

	// Poll for candidates to control the tamed animal
	// Check if the druid already has two awakened beasts
	if(user.mind.awakened_beasts >= user.mind.awakened_max)
		to_chat(user, span_warning("I cannot sustain another self aware beast..."))
	else
		var/list/candidates = pollCandidatesForMob("Do you want to play as an awakened [target.real_name]?", null, null, null, 100, target, POLL_IGNORE_TAMED_BEAST)

		// If there are candidates, assign control to a player
		if(LAZYLEN(candidates))
			var/mob/C = pick(candidates)
			target.awaken_beast(user, C.ckey)
			target.visible_message(span_warning("The [target.real_name]'s eyes light up with intelligence as it awakens!"), runechat_message = TRUE)
			target.awakened = TRUE
			// Add the tamed beast to the druid's list
			user.mind.awakened_beasts += 1
			return TRUE
		// If there are no candidates, the animal will have been calmed but not controlled
		else
			target.visible_message(span_warning("The [target.real_name] seems calmer but remains mindless."), runechat_message = TRUE)
			
			return TRUE

	return FALSE

/mob/living/simple_animal/proc/awaken_beast(mob/living/carbon/human/master, ckey = null)
	if(ckey) // If a player is controlling the animal
		src.ckey = ckey
		to_chat(src, span_userdanger("I was once a creature of instinct, but now... completely new thoughts and ideas flood my mind! I can think! I am free!"))
	if(ai_controller) // Disable AI controller if it exists. This is to stop the AI from trying to control the animal.
		ai_controller = new /datum/ai_controller/basic_controller(src)

	return TRUE

/mob/living/simple_animal/proc/handle_awakened_death()
	var/mob/living/carbon/human/user = owner
	user.mind.awakened_beasts -= 1
	if(user.mind.awakened_beasts < 0)
		user.mind.awakened_beasts = 0
	to_chat(user, span_warning("I feel a disturbance in the wind. One of my awakened beasts has died."))


/obj/effect/proc_holder/spell/targeted/conjure_vines
	name = "Vine Sprout"
	range = 1
	overlay_state = "blesscrop"
	releasedrain = 80
	charge_max = 25 SECONDS
	chargetime = 20
	no_early_release = TRUE
	movement_interrupt = TRUE
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/items/dig_shovel.ogg'
	associated_skill = /datum/skill/magic/holy
	invocation = "Treefather, bring forth vines."
	invocation_type = "shout" //can be none, whisper, emote and shout
	devotion_cost = 40

/obj/effect/proc_holder/spell/targeted/conjure_vines/cast(list/targets, mob/user = usr)
	. = ..()
	var/turf/target_turf = get_step(user, user.dir)
	var/turf/target_turf_two = get_step(target_turf, turn(user.dir, 90))
	var/turf/target_turf_three = get_step(target_turf, turn(user.dir, -90))
	if(!locate(/obj/structure/spacevine) in target_turf)
		new /obj/structure/spacevine/dendor(target_turf)
	if(!locate(/obj/structure/spacevine) in target_turf_two)
		new /obj/structure/spacevine/dendor(target_turf_two)
	if(!locate(/obj/structure/spacevine) in target_turf_three)
		new /obj/structure/spacevine/dendor(target_turf_three)
	
	return TRUE
