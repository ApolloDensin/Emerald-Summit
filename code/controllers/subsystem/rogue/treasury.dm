#define RURAL_TAX 50 // Free money. A small safety pool for lowpop mostly
#define TREASURY_TICK_AMOUNT 6 MINUTES
#define FOREIGNER_TAX_MULTIPLIER 1.5 //Amount that the tax rate is multiplied by for foreigners //Script Rework 1

/proc/send_ooc_note(msg, name, job)
	var/list/names_to = list()
	if(name)
		names_to += name
	if(job)
		var/list/L = list()
		if(islist(job))
			L = job
		else
			L += job
		for(var/J in L)
			for(var/mob/living/carbon/human/X in GLOB.human_list)
				if(X.job == J)
					names_to |= X.real_name
	if(names_to.len)
		for(var/mob/living/carbon/human/X in GLOB.human_list)
			if(X.real_name in names_to)
				if(!X.stat)
					to_chat(X, span_biginfo("[msg]"))

SUBSYSTEM_DEF(treasury)
	name = "treasury"
	wait = 1
	priority = FIRE_PRIORITY_WATER_LEVEL
	var/tax_value = 0.11
	var/queens_tax = 0.10
	var/treasury_value = 0
	var/mint_multiplier = 0.8 // 1x is meant to leave a margin after standard 80% collectable. Less than Bathmatron.
	var/minted = 0
	var/autoexport_percentage = 0.6 // Percentage above which stockpiles will automatically export
	var/list/bank_accounts = list()
	var/list/noble_incomes = list()
	var/list/stockpile_datums = list()
	var/next_treasury_check = 0
	var/list/log_entries = list()
	var/economic_output = 0
	var/total_deposit_tax = 0
	var/total_rural_tax = 0
	var/total_noble_income = 0
	var/total_import = 0
	var/total_export = 0
	var/obj/structure/roguemachine/steward/steward_machine // Reference to the nerve master
	var/initial_payment_done = FALSE // Flag to track if initial round-start payment has been distributed
	//var/allow_scrip = TRUE //Script Rework I
	//var/list/stipends = list() //Script Rework I

/datum/controller/subsystem/treasury/Initialize()
	var/roundstart_pop = length(GLOB.human_list)
	var/seed = STOCKPILE_CROWN_PURCHASE_FLOOR_DEFAULT + rand(500, 1500) + (roundstart_pop * CROWN_PURSE_SEED_PER_PLAYER)
	royal_custom_threshold = ROYAL_CUSTOM_VOLUME_BASE + (roundstart_pop * ROYAL_CUSTOM_VOLUME_PER_POP)
	discretionary_fund = new /datum/fund("Crown's Purse", null, seed)
	burgher_pledge_fund = new /datum/fund("Burgher Pledge", null, BURGHER_PLEDGE_BASE_REFILL * BURGHER_PLEDGE_ROUNDSTART_MULTIPLIER)
	church_fund = new /datum/fund/church("Church Fund", null, CHURCH_FUND_SEED)
	merchant_fund = new /datum/fund/merchant("Merchant Fund", null, MERCHANT_FUND_SEED)
	bathhouse_fund = new /datum/fund/bathhouse("Bathhouse Fund", null, BATHHOUSE_FUND_SEED)
	innkeeper_fund = new /datum/fund/innkeeper("Tavern Earnings", null, INNKEEPER_FUND_SEED)
	treasury_value = discretionary_fund.balance
	force_set_round_statistic(STATS_STARTING_TREASURY, discretionary_fund.balance)
	record_round_statistic(STATS_PLEDGE_GENERATED, burgher_pledge_fund.balance)

	// AP parity: stockpile datums must come BEFORE bounty datums so gem items match their
	// stockpile entries first; the /bounty/treasure catch-all (item_type = /obj) only picks
	// up gems that fall through (accept toggle off / overflow mint path).
	for(var/path in subtypesof(/datum/roguestock/stockpile))
		var/datum/D = new path
		stockpile_datums += D
	for(var/path in subtypesof(/datum/roguestock/bounty))
		var/datum/D = new path
		stockpile_datums += D
	// Step 15: legacy /datum/roguestock/import entries replaced by GLOB.crown_imports.
	// AP parity (Step 15): pop-scale the auto-limited stockpile caps at roundstart.
	autoset_stockpile_limits()
	return ..()

/datum/controller/subsystem/treasury/proc/has_account(target)
	return !isnull(bank_accounts[target])

// AP parity helper (Step 16 Meister Panel). ES deviation: player accounts are integer
// balances keyed by mob in bank_accounts, not /datum/fund accounts.
/datum/controller/subsystem/treasury/proc/get_balance(target)
	return bank_accounts[target] || 0

/datum/controller/subsystem/treasury/fire(resumed = 0)
	if(world.time > next_treasury_check)
		next_treasury_check = world.time + TREASURY_TICK_AMOUNT
		if(SSticker.current_state == GAME_STATE_PLAYING)
			if(!initial_payment_done) // Distribute initial payments once at round start
				initial_payment_done = TRUE
				distribute_daily_payments()
			// Legacy demand drift - still used by stockpile entries without a trade_good_id.
			for(var/datum/roguestock/X in stockpile_datums)
				if(!X.stable_price && !X.mint_item)
					if(X.demand < initial(X.demand))
						X.demand += rand(5,15)
					if(X.demand > initial(X.demand))
						X.demand -= rand(5,15)
			// AP parity: the old "remote stockpile" passive generation (held_items[2]) is gone -
			// regional supply now lives in SSeconomy's economic regions.
		var/area/A = GLOB.areas_by_type[/area/rogue/indoors/town/vault]
		for(var/obj/structure/roguemachine/vaultbank/VB in A)
			if(istype(VB))
				VB.update_icon()
		tick_rural_tax()
		if(GLOB.dayspassed != last_loan_tick_day)
			last_loan_tick_day = GLOB.dayspassed
			tick_loans()
		auto_export()

/datum/controller/subsystem/treasury/proc/create_bank_account(name, initial_deposit)
	if(!name)
		return
	if(name in bank_accounts)
		return
	bank_accounts += name
	if(initial_deposit)
		bank_accounts[name] = initial_deposit
	else
		bank_accounts[name] = 0
	return TRUE

// Legacy shim — callers should use mint(discretionary_fund, ...) directly when possible.
/datum/controller/subsystem/treasury/proc/give_money_treasury(amt, source, silent = FALSE)
	if(!amt)
		return
	mint(discretionary_fund, amt, source)
	// treasury_value is kept in sync by mint(); log_to_steward via old path for compat.
	if(silent)
		return
	log_to_steward("+[amt] to treasury ([source ? source : "unknown"])")

//pays to account from treasury (payroll)
// mint_new: credit is NEW money entering the realm (foreign ships paying for exports)
// rather than a payout from the Crown's Purse - AP parity kwarg
/datum/controller/subsystem/treasury/proc/give_money_account(amt, target, source, mint_new = FALSE)
	if(!amt)
		return
	if(!target)
		return
	amt = min(amt, 10000) //No exponentials, please!
	var/target_name = target
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		target_name = H.real_name
	var/found_account
	for(var/X in bank_accounts)
		if(X == target)
			if(amt > 0)
				// ES deviation from legacy (AP parity): account credits are drawn from the
				// Crown's Purse, not printed - otherwise selling to the stockpile duplicated
				// money forever since the treasury never actually paid anything out
				if(!mint_new && !burn(discretionary_fund, amt, source || "treasury payment to [target_name]"))
					send_ooc_note("<b>MEISTER:</b> Error: The Crown's Purse cannot cover this payment.", name = target_name)
					return FALSE
				bank_accounts[X] += amt  // Add funds into the player's account
			else
				// Check if the amount to be fined exceeds the player's account balance
				if(abs(amt) > bank_accounts[X])
					send_ooc_note("<b>MEISTER:</b> Error: Insufficient funds in the account to complete the fine.", name = target_name)
					return FALSE  // Return early if the player has insufficient funds
				bank_accounts[X] -= abs(amt)  // Deduct the fine amount from the player's account
				// AP parity: fined money returns to the Crown's Purse instead of vanishing
				mint(discretionary_fund, abs(amt), source || "fine levied on [target_name]")
			found_account = TRUE
			break
	if(!found_account)
		return FALSE

	if (amt > 0)
		// Player received money
		record_round_statistic(STATS_DIRECT_TREASURY_TRANSFERS, amt)
		if(source)
			send_ooc_note("<b>MEISTER:</b> You received [amt]m. ([source])", name = target_name)
			log_to_steward("+[amt] from treasury to [target_name] ([source])")
		else
			send_ooc_note("<b>MEISTER:</b> You received [amt]m.", name = target_name)
			log_to_steward("+[amt] from treasury to [target_name]")
	else
		// Player was fined
		record_round_statistic(STATS_FINES_INCOME, amt)
		if(source)
			send_ooc_note("<b>MEISTER:</b> You were fined [amt]m. ([source])", name = target_name)
			log_to_steward("[target_name] was fined [amt] ([source])")
		else
			send_ooc_note("<b>MEISTER:</b> You were fined [amt]m.", name = target_name)
			log_to_steward("[target_name] was fined [amt]")
	return TRUE

	return TRUE

///Deposits money into a character's bank account. Taxes are deducted from the deposit and added to the treasury.
///@param amt: The amount of money to deposit.
///@param character: The character making the deposit.
///@return TRUE if the money was successfully deposited, FALSE otherwise.
/datum/controller/subsystem/treasury/proc/generate_money_account(amt, mob/living/carbon/human/character)
	if(!amt)
		return FALSE
	if(!character)
		return FALSE
	var/taxed_amount = 0
	var/original_amt = amt
	// route through the fund API (mint syncs treasury_value) so the legacy var and the
	// Crown's Purse can never diverge - direct writes were causing reserve-ratio drift
	mint(discretionary_fund, amt, "Bank deposit - [character.real_name]")
	if(character in bank_accounts)
		if(HAS_TRAIT(character, TRAIT_NOBLE))
			bank_accounts[character] += amt
		else if(HAS_TRAIT(character, TRAIT_OUTLANDER) && !HAS_TRAIT(character, TRAIT_INQUISITION)) //Outsiders who aren't inquisition get taxed extra
			taxed_amount = round(amt * tax_value * FOREIGNER_TAX_MULTIPLIER)
//			if(taxed_amount > amt) Mint Rework 
//				taxed_amount = amt Mint Rework i
			amt -= taxed_amount
			bank_accounts[character] += amt
		else
			taxed_amount = round(amt * tax_value)
			amt -= taxed_amount
			bank_accounts[character] += amt
	else
		return FALSE

	log_to_steward("+[original_amt] deposited by [character.real_name] of which taxed [taxed_amount]")

	return list(original_amt, taxed_amount)


/datum/controller/subsystem/treasury/proc/withdraw_money_account(amt, target)
	if(!amt)
		return
	var/target_name = target
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		target_name = H.real_name
	var/found_account
	for(var/X in bank_accounts)
		if(X == target)
			if(bank_accounts[X] < amt)  // Check if the withdrawal amount exceeds the player's account balance
				send_ooc_note("<b>MEISTER:</b> Error: Insufficient funds in the account to complete the withdrawal.", name = target_name)
				return  // Return without processing the transaction
			// fund-API-backed: burn() refuses (and syncs treasury_value) if the purse can't cover it
			if(!burn(discretionary_fund, amt, "Bank withdrawal - [target_name]"))
				send_ooc_note("<b>MEISTER:</b> Error: Insufficient funds in the treasury to complete the transaction.", name = target_name)
				return  // Return early if the treasury balance is insufficient
			bank_accounts[X] -= amt //The account accounts accountingly. Shame on you if you copy this, apple.
			found_account = TRUE
			break
	if(!found_account)
		return
	log_to_steward("-[amt] withdrawn by [target_name]")
	return TRUE


/datum/controller/subsystem/treasury/proc/log_to_steward(log)
	log_entries += log
	return

/datum/controller/subsystem/treasury/proc/distribute_estate_incomes()
	for(var/mob/living/welfare_dependant in noble_incomes)
		var/how_much = noble_incomes[welfare_dependant]
		record_round_statistic(STATS_NOBLE_INCOME_TOTAL, how_much)
		give_money_treasury(how_much, silent = TRUE)
		total_noble_income += how_much
		if(welfare_dependant.job == "Merchant")
			give_money_account(how_much, welfare_dependant, "The Guild")
		else
			give_money_account(how_much, welfare_dependant, "Noble Estate")

/datum/controller/subsystem/treasury/proc/distribute_daily_payments()
	if(!steward_machine || !steward_machine.daily_payments || !steward_machine.daily_payments.len)
		return
/* Mint Rework i
/datum/controller/subsystem/treasury/proc/distribute_daily_payments()
	if(!steward_machine)
		return

	for(var/job_name in steward_machine.mark_stipend)
		var/payment_amount = steward_machine.mark_stipend[job_name]
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.job == job_name)
				var/target_name = H.real_name
				if(stipends[H])
					send_ooc_note("<b>MEISTER:</b> You received a [payment_amount] mark stipend.", name = target_name)
					stipends[H] += payment_amount
				else
					send_ooc_note("<b>MEISTER:</b> You received a [payment_amount] mark stipend.", name = target_name)
					stipends[H] = payment_amount

	if(!steward_machine.daily_payments || !steward_machine.daily_payments.len)
		return
*/
	var/total_paid = 0
	for(var/job_name in steward_machine.daily_payments)
		var/payment_amount = steward_machine.daily_payments[job_name]
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.job == job_name)
				// Skip payment if wages are suspended
				if(HAS_TRAIT(H, TRAIT_WAGES_SUSPENDED))
					continue
				if(give_money_account(payment_amount, H, "Daily Wage"))
					total_paid += payment_amount
					record_round_statistic(STATS_WAGES_PAID)

	if(total_paid > 0)
		log_to_steward("Daily wages distributed: [total_paid]m total")

/datum/controller/subsystem/treasury/proc/do_export(var/datum/roguestock/D, silent = FALSE)
	if(D.stockpile_amount < D.importexport_amt)
		return FALSE
	var/amt = D.get_export_price()
	D.stockpile_amount -= D.importexport_amt
	dirty_market_view()

	mint(discretionary_fund, amt, "exported [D.name]")
	SStreasury.total_export += amt
	economic_output += amt
	record_round_statistic(STATS_STOCKPILE_EXPORTS_VALUE, amt)
	return amt

/datum/controller/subsystem/treasury/proc/auto_export()
	var/total_value_exported = 0
	// Legacy non-trade-good entries: keep the old profitability guard. Trade-good entries
	// (the bulk of the warehouse) flow through mass_export_surplus() below.
	for(var/datum/roguestock/D in stockpile_datums)
		if(!D.importexport_amt || D.trade_good_id)
			continue
		if((autoexport_percentage * D.stockpile_limit) >= D.stockpile_amount)
			continue
		if(D.get_export_price() <= (D.payout_price * D.importexport_amt))
			continue
		if(D.stockpile_amount >= D.importexport_amt)
			total_value_exported += do_export(D, TRUE)
	var/list/surplus_result = mass_export_surplus(silent = TRUE)
	total_value_exported += surplus_result["revenue"]

/// Walks every auto-priced trade-good stockpile entry and exports stock above the
/// daily auto-export floor (limit * autoexport_percentage) to its best-paying region,
/// capped at that region's remaining demand for the day. The Crown's daily sweep
/// fires this with silent=TRUE; the Steward's "Export Surplus" button fires it with
/// silent=FALSE for a per-good chat breakdown.
///
/// Returns: list("revenue" = total mammon, "units" = total units exported,
/// "lines" = list of "[qty] [name] -> [region] for [revenue]m" strings).
/datum/controller/subsystem/treasury/proc/mass_export_surplus(silent = FALSE)
	var/total_revenue = 0
	var/total_units = 0
	var/list/lines = list()
	for(var/datum/roguestock/D in stockpile_datums)
		if(!D.trade_good_id)
			continue
		if(!D.automatic_price)
			continue
		if(!D.importexport_amt)
			continue
		var/keep = round(autoexport_percentage * D.stockpile_limit)
		if(is_auto_import_active(D.trade_good_id))
			keep = max(keep, AUTO_IMPORT_FLOOR)
		var/surplus = D.stockpile_amount - keep
		if(surplus <= 0)
			continue
		var/list/best = SSeconomy.get_best_export_region(D.trade_good_id)
		if(!best || !best["region_id"])
			continue
		var/datum/economic_region/region = GLOB.economic_regions[best["region_id"]]
		if(!region)
			continue
		var/remaining_demand = region.demands_today[D.trade_good_id] || 0
		if(remaining_demand <= 0)
			continue
		var/export_qty = min(surplus, remaining_demand)
		var/revenue = SSeconomy.manual_export(null, region.region_id, D.trade_good_id, export_qty)
		if(!revenue)
			continue
		total_revenue += revenue
		total_units += export_qty
		if(!silent)
			lines += "[export_qty] [D.name] to [region.name] for [revenue]m"
	return list("revenue" = total_revenue, "units" = total_units, "lines" = lines)
