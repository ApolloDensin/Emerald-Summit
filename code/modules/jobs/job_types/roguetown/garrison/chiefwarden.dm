/datum/job/roguetown/chiefwarden
	title = "Chief Warden"
	flag = BOGGUARD
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = JCOLOR_SOLDIER
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD)
	tutorial = "Typically a denizen of the sparsely populated Emerald Summit woods, you volunteered up with the wardens--a group of ranger types who keep a vigil over the untamed wilderness. \
				Selected by your fellows, you act as a guiding force for their ranks. \
				Serve well and earn what you desire. - freedom and safety."
	display_order = JDO_CHIEFWARDEN
	whitelist_req = TRUE
	outfit = /datum/outfit/job/chiefwarden
	advclass_cat_rolls = list(CTAG_CHIEF = 20)
	give_bank_account = 50
	min_pq = 4
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_warden.ogg'
	social_rank = SOCIAL_RANK_PEASANT

	virtue_restrictions = list(
		/datum/virtue/utility/blacksmith, // we don't want you repairing your stuff in combat, sorry...
	)
	job_traits = list(TRAIT_OUTDOORSMAN, TRAIT_WOODSMAN, TRAIT_WOODWALKER, TRAIT_MEDIUMARMOR)

	job_subclasses = list(
		/datum/job/roguetown/chiefwarden
	)
	subclass_stats = list(
		STATKEY_STR = 2,//7 points weighted, same as MAA. They get temp buffs in the woods instead of in the city.
		STATKEY_CON = 1,
		STATKEY_END = 1,
		STATKEY_PER = 1
	)

	subclass_skills = list(
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/slings = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE, // This should let them fry meat on fires.
	)

/datum/outfit/job/chiefwarden
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded/warden
	cloak = /obj/item/clothing/cloak/wardencloak
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	gloves = /obj/item/clothing/gloves/roguetown/chain
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/chainlegs
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	beltr = /obj/item/rogueweapon/stoneaxe/woodcut/wardenpick
	id = /obj/item/scomstone/bad/garrison
	job_bitflag = BITFLAG_GARRISON
	backpack_contents = list(
		/obj/item/storage/keyring/guard = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/warden_horn = 1
	)

	H.verbs |= /mob/proc/haltyell
	H.set_blindness(0)

	var/helmets = list(
		"Path of the Woodsman"	= /obj/item/clothing/head/roguetown/helmet/bascinet/antler,
		"Path of the Buck" 		= /obj/item/clothing/head/roguetown/helmet/bascinet/antler/snouted,
		"Path of the Volf"		= /obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf,
		"Path of the Ram"		= /obj/item/clothing/head/roguetown/helmet/sallet/warden/goat,
		"Path of the Bear"		= /obj/item/clothing/head/roguetown/helmet/sallet/warden/bear,
		"None"
	)
	var/helmchoice = input(H, "Choose your Path.", "HELMET SELECTION") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	var/hoods = list(
		"Common Shroud" 	= /obj/item/clothing/head/roguetown/roguehood/warden,
		"Antlered Shroud"		= /obj/item/clothing/head/roguetown/roguehood/warden/antler,
		"None"
	)
	var/hoodchoice = input(H, "Choose your Shroud.", "HOOD SELECTION") as anything in hoods
	if(helmchoice != "None")
		mask = hoods[hoodchoice]

	. = ..()
	var/weapons = list("Bow", "Sword" , "Spear")
	var/weapon_choice = input(H,"Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Bow")
			beltl = /obj/item/quiver/arrows	
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/warden
		if("Sword")
			H.put_in_hands(new /obj/item/rogueweapon/sword/long(H), TRUE)
			beltl = /obj/item/rogueweapon/scabbard/sword
			H.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		if("Spear")
			r_hand = /obj/item/rogueweapon/spear
