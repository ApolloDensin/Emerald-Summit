/obj/item/recipe_book/leatherworking
	name = "The Tanned Hide Tome: Mastery of Leather and Craft"
	desc = "A book full of recipes and tips for tanning hides and working leather. Can be used as fuel in a pinch."
	icon_state = "book8_0"
	base_icon_state = "book8"

	types = list(
	/datum/crafting_recipe/roguetown/tallow,
	/datum/crafting_recipe/roguetown/leather, 		
	)

/obj/item/recipe_book/sewing
	name = "Threads of Destiny: A Tailor's Codex"
	desc = "A book full of recipes and tips for sewing cloth and stitching garments. Can be used as fuel in a pinch."
	icon_state = "book7_0"
	base_icon_state = "book7"

	types = list(
		/datum/crafting_recipe/roguetown/survival/cloth, // Screw it just in case
		/datum/crafting_recipe/roguetown/sewing,
		)

/obj/item/recipe_book/blacksmithing
	name = "The Smith’s Legacy"
	desc = "A book full of recipes and tips for smithing weapons, armor, and tools at the anvil. Can be used as fuel in a pinch."
	icon_state = "book3_0"
	base_icon_state = "book3"

	types = list(/datum/anvil_recipe)

/obj/item/recipe_book/engineering
	name = "The Artificer's Handbook"
	desc = "A book full of recipes and tips for engineering mechanisms and contraptions. Can be used as fuel in a pinch."
	icon_state = "book4_0"
	base_icon_state = "book4"

	types = list(/datum/crafting_recipe/roguetown/engineering)

// I gave up I will make better names later lol
// Was gonna do a carpenter + masonry handbook but 
// Both are under structures so I will just make them one and add categories
// Later 
/obj/item/recipe_book/builder
	name = "The Builder's Handbook - For Carpenters and Masons"
	desc = "A book full of recipes and tips for carpentry and masonry, covering structures of wood and stone alike. Can be used as fuel in a pinch."
	icon_state = "book5_0"
	base_icon_state = "book5"

	types = list(
		/datum/crafting_recipe/roguetown/structure
		)

/obj/item/recipe_book/ceramics
	name = "The Potter's Handbook"
	desc = "A book full of recipes and tips for shaping clay at the wheel and firing it into pottery. Can be used as fuel in a pinch."
	icon_state = "book5_0"
	base_icon_state = "book5"

	types = list(
		/datum/crafting_recipe/roguetown/structure/ceramicswheel,
		/datum/crafting_recipe/roguetown/ceramics
		)

// This book should be widely given to everyone
/obj/item/recipe_book/survival
	name = "The Survival Handbook"
	desc = "A book full of recipes and tips for surviving in the wild. Can be used as fuel in a pinch."
	icon_state = "book6_0"
	base_icon_state = "book6"

	types = list(
		/datum/crafting_recipe/roguetown/survival,
		/datum/crafting_recipe/roguetown/tallow,
		)

// TBD - Cauldron Recipes
/obj/item/recipe_book/alchemy
	name = "Secrets of Alchemy"
	desc = "A book full of recipes and tips for grinding reagents, brewing in the cauldron, and assembling alchemical apparatus. Can be used as fuel in a pinch."
	icon_state = "book3_0"
	base_icon_state = "book3"

	types = list(
		/datum/crafting_recipe/roguetown/structure/alch,
		/datum/crafting_recipe/roguetown/structure/cauldronalchemy,
		/datum/crafting_recipe/roguetown/survival/mortar,
		/datum/crafting_recipe/roguetown/survival/pestle,
		/datum/crafting_recipe/roguetown/alchemy,
		/datum/alch_grind_recipe,
		/datum/alch_cauldron_recipe
		)
 
/obj/item/recipe_book/cooking
	name = "The Culinary Codex"
	desc = "A book full of recipes and tips for cooking. This version looks very incomplete, and only contain brewing recipes. Perhaps it will be filled in later?"
	icon_state = "book2_0"
	base_icon_state = "book2"

	types = list(
		/datum/brewing_recipe,
		/datum/book_entry/brewing
	)

/obj/item/recipe_book/magic
	name = "The Magister's Grimoire"
	desc = "A book full of recipes and tips for crafting arcane focuses, gemstaves, and ritual runes. Can be used as fuel in a pinch."
	icon_state = "book4_0"
	base_icon_state = "book4"

	types = list(
		/datum/book_entry/magic1,
		/datum/crafting_recipe/roguetown/arcana,
		/datum/crafting_recipe/gemstaff,
		/datum/runeritual,
		)
