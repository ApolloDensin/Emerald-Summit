// Ratwood Character Customization UI — Emerald compatibility shims.
// Defines/stubs symbols the ported menu files (vices_menu.dm, loadout_menu.dm,
// loadoutmenu/loadout_menu.dm, language_menu.dm) expect but that don't yet exist
// in Emerald-Summit. Strictly UI-only — no behavior beyond the minimum needed to compile.

#define MAX_ICON_CACHE_SIZE 500

// vices_menu.dm filters virtues against pref_species.restricted_virtues. Emerald's species
// datum doesn't have that field; default to empty so no virtues are filtered.
/datum/species
	var/list/restricted_virtues = list()

// vices_menu.dm offers a colour picker for loadout slots, looking up hex by friendly name
// in GLOB.colorlist. Mirror the named colors Emerald already uses elsewhere.
GLOBAL_LIST_INIT(colorlist, list(
	"White" = "#FFFFFF",
	"Black" = "#000000",
	"Red" = "#C72929",
	"Orange" = "#D67C2D",
	"Yellow" = "#D6C32D",
	"Green" = "#3B8F3F",
	"Blue" = "#2E5DA8",
	"Purple" = "#6B3FA8",
	"Brown" = "#5C3A1E",
	"Grey" = "#808080",
	"Tan" = "#D2B48C",
	"Pink" = "#D67C9C",
	"Navy" = "#1E2D55",
	"Maroon" = "#5C1E1E",
	"Olive" = "#5C5C1E",
	"Teal" = "#1E5C5C",
))

