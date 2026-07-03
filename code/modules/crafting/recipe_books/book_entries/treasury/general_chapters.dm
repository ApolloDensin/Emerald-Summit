// Economy 3 guidebook — Common chapters. Ported from Azure-Peak PR #7000
// (apsrc/main, code/modules/crafting/recipe_books/book_entries/treasury/general_chapters.dm)
// with content pared back to what Emerald Summit actually implements.
//
// Cut entirely vs AP (no corresponding ES system exists):
//  - Charters of the Realm: AP's Charter/decree suspend-restore system (Great Writ of Azuria,
//    Zenitstadt Concordat, Otavan Accords, Golden Bull, Covenant of Noc and Pestra, Guild
//    Charter of Arms, Indenture of War) reads SStreasury.decrees, which doesn't exist in ES
//    (see noticeboard.dm's own header note: "build_charters() ... stubbed/pared down: AP's
//    charter list reads SStreasury.decrees ... that does not exist in ES yet").
//  - Outlawry: entirely about losing Charter protection - no Charter system to lose.
//  - The Innkeeper and the Guild (Rumor contracts), Towner Contracts, The Grand Contract Ledger:
//    AP's Guild quest/contract-board economy (QUEST_*, RUMOR_*, GUILD_REFERRAL_FEE_PCT defines)
//    has no equivalent anywhere in ES's codebase - grepped for every define AP's text cites and
//    found none. Cutting rather than documenting a contract board that doesn't exist.
//  - Alderman & City Assembly: code/modules/roguetown/roguemachine/noticeboard/assembly_floor.dm
//    is an explicit compat stub ("Azure-Peak's assembly_floor.dm hosts a full Commons
//    democracy/governance TGUI ... that does not exist anywhere in Emerald Summit").
//
// Reworked vs AP (ES has a real but different implementation):
//  - Taxation and Levies: ES has no per-decree Charter exemptions and no in-game multi-category
//    tax-rate panel wired to a UI yet (SStreasury.set_tax_rate() exists as a proc but nothing
//    calls it from player-facing code); the legacy single-rate "Adjust Taxes" verb
//    (code/modules/jobs/job_types/roguetown/nobility/steward.dm) is what Stewards actually have.
//    Poll tax categories and caps are real (code/__DEFINES/banking.dm POLL_TAX_* /
//    POLL_TAX_CAT_*).
//  - Fines: Golden Bull specifics (per-stroke % cap, daily ceiling) don't exist as named defines;
//    only the general fine cap (GENERIC_RATE_CAP) is real.
//  - Patronage: all three writs are real as of the Step 16 Meister Panel port
//    (code/modules/banking/patronage_writ.dm; TRAIT_AGENT_MERCHANT/BATHHOUSE/CHURCH,
//    PATRON_CAP_* in code/__DEFINES/banking.dm). Drafted from the MEISTER's Patronage tab.
//  - Mercenary Statue: only the public mercenary roster is real
//    (code/game/objects/structures/roguetown/talkstatue_mercenary.dm + talkstatue_tgui.dm).
//    No "wretch roster" hidden tab exists anywhere in ES - cut that whole section.
//  - Zadcote and Zadcage: ported in the Step 12 Zadcote port
//    (code/modules/roguetown/roguemachine/zadcote/) consuming the 1:1 defines in
//    code/__DEFINES/economy/zadcote.dm. Chapter 07 below documents it. The Stewardry's
//    crown-import restock channel landed with the Step 15 crown-imports port.
//
// Kept close to AP (real, matching systems):
//  - Supply and Demand (economic events): code/controllers/subsystem/rogue/economy/economy.dm +
//    code/__DEFINES/economy/internal_trade_and_quests.dm match AP's values exactly.
//  - Jolly Tax Evasion: both dodge paths are real - Goldface's "secrets" toggle
//    (upgrade_flags & UPGRADE_NOTAX) and the Ship Fulfillment Crate's toggle_duty.

/datum/book_entry/treasury_general
	abstract_type = /datum/book_entry/treasury_general
	category = "Common"

/datum/book_entry/treasury_general/levies
	name = "01. Taxation and Levies"

/datum/book_entry/treasury_general/levies/inner_book_html(mob/user)
	return {"
		<div>
		<p>The Crown draws revenue from a mix of direct and indirect taxes. There is no Charter system in Emerald Summit yet, so no class of subject is exempt by decree - taxation applies uniformly.</p>
		</div>

		<h3>Tax Categories</h3>
		<ul>
			<li><b>Contract Levy</b> - on contract payouts.</li>
			<li><b>Headeater Levy</b> - on bounty heads fed directly to the HEADEATER.</li>
			<li><b>Import Tariff</b> - on goods bought from merchant vendors including SILVERFACE and GOLDFACE.</li>
			<li><b>Export Duty</b> - on goods sold through the Navigator or the Ship Fulfillment Crate.</li>
			<li><b>Fine</b> - a one-off penalty struck against a subject's account.</li>
		</ul>

		<p>The Steward's dedicated per-category tax-rate panel is not yet wired up to any in-game interface, so in practice the Steward adjusts the realm's general rate with the legacy <b>"Adjust Taxes"</b> verb (found under the Stewardry category), which sets a single flat percentage rather than per-category rates. There is a short cooldown between adjustments, and the verb is unavailable while a Ruler or Regent occupies the throne.</p>

		<h3>Poll Tax</h3>
		<p>Poll tax is levied daily against every subject with a bank account, drained automatically. Categories exist per social station (noble, clergy, inquisition, courtier, garrison, guilds, merchant, burgher, adventurer, mercenary, peasant). Poll taxes are hardcapped at <b>[POLL_TAX_MAX_RATE]m/day</b>, and can be set as low as a subsidy of <b>-[POLL_TAX_MAX_SUBSIDY]m/day</b> (a negative rate pays subjects from the Crown's Purse instead).</p>

		<p>Unpaid poll tax accumulates arrears. After <b>[POLL_TAX_DEBT_DAYS_TO_DEBTOR]</b> day(s) of arrears, the subject is marked <b>destitute</b>. Poll tax arrears do not authorise kill-on-sight or attack-on-sight - treat arrears as a roleplay opportunity to recover or forgive the debt, not an ERP exemption.</p>
		</div>
	"}


/datum/book_entry/treasury_general/fines
	name = "02. Fines"

/datum/book_entry/treasury_general/fines/inner_book_html(mob/user)
	return {"
		<div>
		<p>A fine strikes a subject's account directly for a stated amount, capped at <b>[GENERIC_RATE_CAP * 100]%</b> of their current balance per stroke. There is no Golden Bull carve-out yet to soften this cap for any particular class of subject.</p>
		<p>Fines are voluntarily consented to by nature of holding an account under the Crown's jurisdiction; treat repeated or excessive fining as an IC matter to resolve, not a mechanical guarantee.</p>
		</div>
	"}


/datum/book_entry/treasury_general/patronage
	name = "03. Patronage: Writs and Rolls"

/datum/book_entry/treasury_general/patronage/inner_book_html(mob/user)
	return {"
		<div>
		<p>Three factions extend patronage. The faction's authority (the Merchant, the Nightmaster, or the Bishop/Martyr) drafts a writ from the <b>Patronage tab of any MEISTER</b> and hands it to a chosen bearer, who claims it by using it in hand. The same tab shows the current roll and lets the authority revoke a name.</p>

		<ul>
			<li><b>Writ of Charter</b> (Emerald Trading Company, up to [PATRON_CAP_MERCHANT] Agents) - the Agent gains Burgher residency, is recognised at GOLDFACE even if their day job is something else: they may browse and buy the Harbor tab's cultural stock, and may hail and send away ships on the Merchant's behalf. An Agent personally recognises ships from their own character origin as kin for buying purposes (see <i>The Kinship Bonus</i>). An Agent is locked out of the Market, Management, and Ledger controls.</li>
			<li><b>Token of the Bathhouse</b> (up to [PATRON_CAP_BATHHOUSE] Agents) - the Agent may operate the bathhouse zadcote.</li>
			<li><b>Letter of Benefaction</b> (the Church, up to [PATRON_CAP_CHURCH] Benefactors) - marks the bearer a friend of the faith.</li>
		</ul>

		<p>Writs expire two minutes after printing if unclaimed, cannot be claimed by their own issuer, and refuse a bearer already on the roll or a roll that is full.</p>
		</div>
	"}


/datum/book_entry/treasury_general/supply
	name = "04. Supply and Demand"

/datum/book_entry/treasury_general/supply/inner_book_html(mob/user)
	return {"
		<div>
		<p>Economic events last <b>[ECON_EVENT_DURATION]</b> day(s) and are posted on the noticeboard under <b>Economic Events</b>.</p>

		<ul>
			<li><b>Shortage</b> - affected goods spike in price. One urgent standing order is posted against the afflicted region, <b>provided fewer than [STANDING_ORDERS_MAX_URGENT] urgent orders are already standing</b>. Past that cap, the shortage's price spike still happens, but no urgent order is spawned.</li>
			<li><b>Oversupply</b> - affected goods drop in price.</li>
		</ul>

		<h3>Ending a Shortage Early</h3>
		<p>A shortage does not have to run its full <b>[ECON_EVENT_DURATION]</b>-day course. Every unit of an affected good that the Crown <b>exports</b> to a region that demands it counts toward relief.</p>

		<p>Once cumulative deliveries cross <b>[round(ECON_EVENT_SATURATION_MULT * 100)]%</b> of the average stockpile limit across the affected goods, the shortage ends immediately: prices snap back to normal and SCOM announces the relief.</p>
		</div>
	"}


/datum/book_entry/treasury_general/tax_evasion
	name = "05. Jolly Tax Evasion"

/datum/book_entry/treasury_general/tax_evasion/inner_book_html(mob/user)
	return {"
		<div>
		<p>Two legitimate dodge switches exist, both risk-bearing:</p>

		<ul>
			<li><b>GOLDFACE's Secrets menu</b> - ATC members (Merchant, Shophand) can toggle "Stop Paying Taxes" to skip the import tariff on purchases. The machine tracks tariff paid and tariff evaded per-machine, visible to ATC members only.</li>
			<li><b>The Ship Fulfillment Crate's underledger toggle</b> - Merchant/Shophand can toggle Crown export duty between PAID and DODGED on that crate. Evaded duty is tallied per-machine.</li>
		</ul>

		<p>The risk of being caught and penalised by the Crown falls on whoever is dodging. The Crown has no automatic audit tool - it can only guess and accuse, with or without proof.</p>
		</div>
	"}


/datum/book_entry/treasury_general/mercenary_statue
	name = "06. The Mercenary Statue"

/datum/book_entry/treasury_general/mercenary_statue/inner_book_html(mob/user)
	return {"
		<div>
		<p>The Mercenary Statue is a talkstatue that lets townsfolk reach registered mercenaries for hire.</p>

		<ul>
			<li>Mercenaries register with the statue and cycle their status: Available, Contracted, Do not Disturb.</li>
			<li>Anyone may open the statue, browse the roster, and send a registered mercenary a direct message. Recipients on Do not Disturb are hidden from the picker.</li>
			<li>A sender may also broadcast a message to every available mercenary at once.</li>
			<li>Each sender-recipient pairing has its own cooldown to prevent spam, and broadcasts carry a separate cooldown.</li>
			<li>Messages are logged. Senders must stand adjacent to the statue to send, and mercenaries reply with a simple YAE/NAE or a signal of interest.</li>
		</ul>
		</div>
	"}


/datum/book_entry/treasury_general/zadcote
	name = "07. Zadcote and Zadcage"

/datum/book_entry/treasury_general/zadcote/inner_book_html(mob/user)
	return {"
		<div>
		<p>The Zadcote is used to send messages, parcels, and for the nefarious - bottlebombs to linked zadcages. Each Zadcote is bound to a single faction - the Crown, the Azurian Trading Company, or the Bathhouse and accepts orders only from its faction.</p>

		<p>A Zadcage can ride in a pack, on a person, or be set down, and the zad will route to it reliably. Each zadcote spawns with its linked zadcages automatically..</p>

		<h3>Bonding a Zadcage</h3>
		<p>Strike a free Zadcage against a Zadcote to bond it to one of [ZADCOTE_SLOT_CAP] slots. The Zadcote operator may rename the slot in the interface. Bond persists until the operator severs it; the Zadcage holder cannot break it themselves. If you sever a slot while a zad is in flight, that zad completes its current trip before the bond goes dead.</p>

		<h3>Capacity tiers</h3>
		<p>Each dispatch chooses how many zads to send. Each of them may send a message, alongside a payload:</p>
		<ul>
			<li><b>1 zad</b> - A small item.</li>
			<li><b>2 zads</b> - A medium (normal) item or a pouch.</li>
			<li><b>3 zads</b> - A large / bulky item or container.</li>
		</ul>

		<h3>Flight time and turnback</h3>
		<p>A dispatched zad team takes about a minute to reach the Zadcage. If the Zadcage has been destroyed by then, the zads turn back with the payload intact. If the Zadcage is bonded but not on a person, delivery still completes - the Zadcote chimes to its operator so they know the cage was unattended.</p>

		<h3>Reply window</h3>
		<p>Once a zad lands, the Zadcage holder has three minutes to write a reply and place a return payload. After three minutes the zad lifts off on its own. Return capacity is equal to the dispatch capacity. <b>Auto-departure carries no message and no package.</b> The last 30 seconds tint the countdown red.</p>

		<h3>Attrition and Zadpacks</h3>
		<p>A returning zad has a small chance of being lost to exhaustion or harm. Bottlebomb flights are <b>one-way</b> - those zads are never recovered. A faction restocks its Zadcote with a Pack of Trained Zads bought through its supply machine: the ATC's at GOLDFACE, the Bathhouse's through BRASSFACE, and the Stewardry's through the NERVE MASTER's Crown imports. Strike the pack against the Zadcote to add [ZADPACK_BUNDLE_SIZE] fresh zads to the reserve.</p>

		<h3>Summoning</h3>
		<p>A Zadcage holder can actively summon zads from the linked zadcote, so they can send a message or package back proactively. The owner of the zadcote could turn it off if they are low on zads or think the bearer is abusing it.</p>

		<h3>Bombing!</h3>
		<p>The Zadcote can carry bottlebombs as a payload - up to three per dispatch. Bomb can only be sent once every five minutes. The Zadcage holder sees the zads arriving with bombs slung beneath, has time to drop or throw the cage, and may even weaponize it against someone they dislike. Admin logs every bomb dispatch by sender, receiver, and place of detonation.</p>

		<h3>Scrying (ATC and Bathhouse only)</h3>
		<p>The Merchant's Zadcote and the Bathmaster's Zadcote may scry through the bonded zad on a Zadcage. Scrying draws from a small <b>scrying fund</b> kept by the Zadcote itself. Feed coins of any denomination directly into the Zadcote to add to the fund, each scry deducts [ZAD_VOYEUR_COST_MAMMON] mammon. The Zadcage holder feels arcane energy stir, and the cage glows blue while the scrying is active. The view lasts three minutes, long enough to confirm the holder is safe - or to make trouble. The Steward and Crown have no scrying access through Zadcotes, they must relies on the Court Mage's expertise scrying.</p>

		<h3>Spare zadcages & zads</h3>
		<p>Spare Zadcages cost [ZADCOTE_NEW_CAGE_COST_MAMMON] mammon at the can be replaced by purchase from the faction's import machine. Trained zads sell as packs of [ZADPACK_BUNDLE_SIZE].</p>
		</div>
	"}
