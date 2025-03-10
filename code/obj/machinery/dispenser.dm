/*
		Oxygen and plasma tank dispenser
*/
/obj/machinery/dispenser
	desc = "A storage device for gas tanks. Holds 10 plasma and 10 oxygen tanks."
	name = "Tank Storage Unit"
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser-empty"
	density = 1
	status = REQ_PHYSICAL_ACCESS
	var/o2tanks = 10
	var/pltanks = 10
	anchored = 1.0
	mats = 24
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

/obj/machinery/dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				while(src.o2tanks > 0)
					new /obj/item/tank/oxygen( src.loc )
					src.o2tanks--
				while(src.pltanks > 0)
					new /obj/item/tank/plasma( src.loc )
					src.pltanks--
		else
	return

/obj/machinery/dispenser/blob_act(var/power)
	if (prob(25 * power / 20))
		while(src.o2tanks > 0)
			new /obj/item/tank/oxygen( src.loc )
			src.o2tanks--
		while(src.pltanks > 0)
			new /obj/item/tank/plasma( src.loc )
			src.pltanks--
		qdel(src)

/obj/machinery/dispenser/meteorhit()
	while(src.o2tanks > 0)
		new /obj/item/tank/oxygen( src.loc )
		src.o2tanks--
	while(src.pltanks > 0)
		new /obj/item/tank/plasma( src.loc )
		src.pltanks--
	qdel(src)
	return

/obj/machinery/dispenser/New()
	..()
	UnsubscribeProcess()
	UpdateIcon()

/obj/machinery/dispenser/process()
	return

/obj/machinery/dispenser/attack_ai(mob/user as mob)
	return src.Attackhand(user)


/obj/machinery/dispenser/update_icon()
	if (o2tanks > 0 && pltanks > 0)
		icon_state = "dispenser-both"
	else
		icon_state = "dispenser-empty"
		if (o2tanks > 0)
			icon_state = "dispenser-oxygen"
		if (pltanks > 0)
			icon_state = "dispenser-plasma"

/* INTERFACE */

/obj/machinery/dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TankDispenser", name)
		ui.open()

/obj/machinery/dispenser/ui_data(mob/user)
	. = list(
		"oxygen" = o2tanks,
		"plasma" = pltanks,
	)

/obj/machinery/dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("dispense-plasma")
			if(pltanks > 0)
				use_power(5)
				var/newtank = new /obj/item/tank/plasma(src.loc)
				usr.put_in_hand_or_eject(newtank)
				src.pltanks--
			. = TRUE
		if("dispense-oxygen")
			if (o2tanks > 0)
				use_power(5)
				var/newtank = new /obj/item/tank/oxygen(src.loc)
				usr.put_in_hand_or_eject(newtank)
				src.o2tanks--
			. = TRUE
	UpdateIcon()
