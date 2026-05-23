/datum/asset/spritesheet/loadout_items
	name = "loadout_items"

/datum/asset/spritesheet/loadout_items/create_spritesheets()
	// Emerald port: GLOB.loadout_items is `path -> datum` assoc; iterate keys and look up the datum
	// so REF(item) here matches the REF used in /datum/loadout_menu/ui_static_data.
	for(var/path as anything in GLOB.loadout_items)
		var/datum/loadout_item/item = GLOB.loadout_items[path]
		if(!item)
			continue
		var/obj/item/I = item.path
		var/icon = I::icon
		var/icon_state = I::icon_state

		if(!icon || !icon_state)
			continue

		Insert("[sanitize_css_class_name("loadout_item_[REF(item)]")]", icon, icon_state)
