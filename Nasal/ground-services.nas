########################################################################
### Ground services configuration for the DHC-6 Twin Otter #############
### Taken from the A330-200 by theomegahangar ##########################
### Adapted for this project by Jonathan Schellhase (dg-505) ###########
### This file is licensed under the terms of the GNU GPL v2 or later ###
########################################################################

var ground_services = {
	init : func {
		me.UPDATE_INTERVAL = 0.02;
	me.loopid = 0;

	# External power
	setprop("/sim/model/equipment/ground-services/external-power/enable", 1);

	# Fuel Truck
	setprop("/sim/model/equipment/ground-services/fuel-truck/enable", 0);
	setprop("/sim/model/equipment/ground-services/fuel-truck/connect-fwd", 0);
	setprop("/sim/model/equipment/ground-services/fuel-truck/connect-aft", 0);
	setprop("/sim/model/equipment/ground-services/fuel-truck/disconnect", 1);
	setprop("/sim/model/equipment/ground-services/fuel-truck/transfer", 0);
	setprop("/sim/model/equipment/ground-services/fuel-truck/clean", 0);
	setprop("/sim/model/equipment/ground-services/fuel-truck/request-lbs", 0);

	# Set it to 0 if the aircraft is not stationary
	if (getprop("/velocities/groundspeed-kt") > 1) {
		setprop("/sim/model/equipment/ground-services/fuel-truck/enable", 0);
		setprop("/sim/model/equipment/ground-services/external-power/enable", 0);
	}

	me.reset();
	},
	update : func {

		# External Power
		if (getprop("/velocities/groundspeed-kt") > 1)
			setprop("/sim/model/equipment/ground-services/external-power/enable", 0);
		
		if (getprop("/sim/model/equipment/ground-services/external-power/enable") == 0)
			setprop("controls/electric/external-power", 0);

		# Fuel truck controls

		if (getprop("/sim/model/equipment/ground-services/fuel-truck/enable") and getprop("/sim/model/equipment/ground-services/fuel-truck/connect-fwd")) {

			if (getprop("/sim/model/equipment/ground-services/fuel-truck/transfer")) {

				if (getprop("/consumables/fuel/tank[0]/level-lbs") >= 1233) {
					setprop("/sim/model/equipment/ground-services/fuel-truck/transfer", 0);
					setprop("/consumables/fuel/tank[0]/level-lbs", 1233);
					setprop("/consumables/fuel/tank[0]/selected", 1);
					screen.log.write("Forward tank is full! Refuelling complete. Have a nice flight... :)", 0.8, 1, 0,);
				}

				if (getprop("/consumables/fuel/tank[0]/level-lbs") < getprop("/sim/model/equipment/ground-services/fuel-truck/request-lbs")) {
					setprop("/consumables/fuel/tank[0]/level-lbs", getprop("/consumables/fuel/tank[0]/level-lbs") + 2);

				} else {
					setprop("/sim/model/equipment/ground-services/fuel-truck/transfer", 0);
					setprop("/consumables/fuel/tank[0]/selected", 1);
					setprop("/consumables/fuel/tank[0]/level-lbs", getprop("/sim/model/equipment/ground-services/fuel-truck/request-lbs"));
					screen.log.write("Refueling complete! Have a nice flight... :)", 0, 1, 0.5);
				}				
			}

			if (getprop("/sim/model/equipment/ground-services/fuel-truck/clean")) {

				if (getprop("/consumables/fuel/tank[0]/level-lbs") > 5) {
					setprop("/consumables/fuel/tank[0]/level-lbs", getprop("/consumables/fuel/tank[0]/level-lbs") - 5);

				} else {
					setprop("/sim/model/equipment/ground-services/fuel-truck/clean", 0);
					setprop("/consumables/fuel/tank[0]/level-lbs", 0);
					screen.log.write("Finished draining the fuel tank...", 1, 1, 1);
				}	
			}
		}

		if (getprop("/sim/model/equipment/ground-services/fuel-truck/enable") and getprop("/sim/model/equipment/ground-services/fuel-truck/connect-aft")) {

			if (getprop("/sim/model/equipment/ground-services/fuel-truck/transfer")) {

				if (getprop("/consumables/fuel/tank[1]/level-lbs") >= 1349) {
					setprop("/sim/model/equipment/ground-services/fuel-truck/transfer", 0);
					setprop("/consumables/fuel/tank[1]/level-lbs", 1349);
					setprop("/consumables/fuel/tank[1]/selected", 1);
					screen.log.write("Rear tank is full! Refuelling complete. Have a nice flight... :)", 0.8, 1, 0,);
				}

				if (getprop("/consumables/fuel/tank[1]/level-lbs") < getprop("/sim/model/equipment/ground-services/fuel-truck/request-lbs")) {
					setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs") + 2);

				} else {
					setprop("/sim/model/equipment/ground-services/fuel-truck/transfer", 0);
					setprop("/consumables/fuel/tank[1]/selected", 1);
					setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/sim/model/equipment/ground-services/fuel-truck/request-lbs"));
					screen.log.write("Refueling complete! Have a nice flight... :)", 0, 1, 0.5);
				}				
			}

			if (getprop("/sim/model/equipment/ground-services/fuel-truck/clean")) {

				if (getprop("/consumables/fuel/tank[1]/level-lbs") > 5) {
					setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs") - 5);

				} else {
					setprop("/sim/model/equipment/ground-services/fuel-truck/clean", 0);
					setprop("/consumables/fuel/tank[1]/level-lbs", 0);
					screen.log.write("Finished draining the fuel tank...", 1, 1, 1);
				}
			}
		}
	},
	reset : func {
		me.loopid += 1;
		me._loop_(me.loopid);
	},
	_loop_ : func(id) {
		id == me.loopid or return;
		me.update();
		settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
	}
};
setlistener("sim/signals/fdm-initialized", func {
	ground_services.init();
	print("Ground Services available!");
});
