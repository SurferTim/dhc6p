# This is a custom failure system.
srand();

props.globals.initNode("controls/engines/engine[0]/intake-deflector",0);
props.globals.initNode("gear/gear[1]/ground-friction-factor",1);
props.globals.initNode("controls/engines/engine[1]/intake-deflector",0);
props.globals.initNode("gear/gear[2]/ground-friction-factor",1);
props.globals.initNode("/engines/engine[0]/serviceable", 1);
props.globals.initNode("/engines/engine[1]/serviceable", 1);
props.globals.initNode("controls/anti-ice/pitot-heat",0);
#props.globals.initNode("instrumentation/airspeed-indicator/indicated-speed-kt",0);
props.globals.initNode("controls/anti-ice/prop-heat",0);
props.globals.initNode("hazards/icing/pitot",0);
props.globals.initNode("hazards/icing/propeller",0);
props.globals.initNode("hazards/icing/pitot-icing-lvl", 0, "DOUBLE");

var pitot_icing_lvl = 0;

var prop_icing_time = 0;
var prop_no_icing_time = 0;
var prop_icing_index = 0;

########################################################################
## Warning: these are infinite loops. You have to reset your program! ##
########################################################################
var engine0_completely_broken = func {
    setprop("/engines/engine[0]/serviceable", 0);
    setprop("/engines/engine[0]/running", 0);
    setprop("/engines/engine[0]/cutoff", 1);
    setprop("/fdm/jsbsim/propulsion/engine[0]/set-running", 0);
    setprop("controls/engines/engine[0]/internal-condition", 0);
    settimer(engine0_completely_broken, 0);
}

var engine1_completely_broken = func {
    setprop("/engines/engine[1]/serviceable", 0);
    setprop("/engines/engine[1]/running", 0);
    setprop("/engines/engine[1]/cutoff", 1);
    setprop("/fdm/jsbsim/propulsion/engine[1]/set-running", 0);
    setprop("controls/engines/engine[1]/internal-condition", 0);
    settimer(engine1_completely_broken, 0);
}
########################################################################

var sands_stones = func {
    var engine0_running = getprop("engines/engine[0]/running");
    var engine1_running = getprop("engines/engine[1]/running");
    var intake_deflector0 = getprop("controls/engines/engine[0]/intake-deflector");
    var gear1_ground_type = getprop("gear/gear[1]/ground-friction-factor");
    var ggrpm1 = getprop("instrumentation/engine-instruments/turbine[0]/indicated-speed");
    var wow1 = getprop("gear/gear[1]/wow");
    var intake_deflector1 = getprop("controls/engines/engine[1]/intake-deflector");
    var gear2_ground_type = getprop("gear/gear[2]/ground-friction-factor");
    var ggrpm2 = getprop("instrumentation/engine-instruments/turbine[1]/indicated-speed");
    var wow2 = getprop("gear/gear[2]/wow");
    
    if (intake_deflector0 == 0 and gear1_ground_type < 1 and engine0_running and ggrpm1 > 85 and wow1 and rand()>0.6) {
        print("Your left engine is damaged by sands and stones!");
	   engine0_completely_broken();
    }
    
    if (intake_deflector1 == 0 and gear2_ground_type < 1 and engine1_running and ggrpm2 > 85 and wow2 and rand()>0.6) {
        print("Your right engine is damaged by sands and stones!");
	   engine1_completely_broken();
    }
    settimer(sands_stones, 10);
}

var pitot_fail = func {
    var pitot_heat = getprop("controls/anti-ice/pitot-heat");
    var oat = getprop("environment/temperature-degc");
    var dew_point = getprop("environment/dewpoint-degc");
    var relative_humidity = getprop("/environment/relative-humidity");
    var internal_ias = getprop("velocities/airspeed-kt");
    var ias_serviceable =
#   getprop("instrumentation/vertical-speed-indicator/serviceable");
    getprop("systems/pitot[0]/serviceable");
    getprop("systems/pitot[1]/serviceable");

    if ((oat <= 0 and oat <= dew_point and relative_humidity > 50) and
    pitot_heat != 1) {
#       setprop("systems/pitot[0]/serviceable",0);
#       setprop("systems/pitot[1]/serviceable",0);
#       setprop("instrumentation/altimeter[0]/serviceable",0);
#       setprop("instrumentation/altimeter[1]/serviceable",0);
#       setprop("instrumentation/vertical-speed-indicator/serviceable",0);
#       setprop("instrumentation/vertical-speed-indicator/indicated-speed-fpm",0);
        pitot_icing_lvl = pitot_icing_lvl  + rand();
        if (pitot_icing_lvl > internal_ias) {
            pitot_icing_lvl = internal_ias;
        }
        setprop("hazards/icing/pitot-icing-lvl", pitot_icing_lvl);
        setprop("hazards/icing/pitot",1);
    } else {
#       setprop("instrumentation/altimeter[0]/serviceable",1);
#       setprop("instrumentation/altimeter[1]/serviceable",1);
#       setprop("instrumentation/vertical-speed-indicator/serviceable",1);
        pitot_icing_lvl = pitot_icing_lvl - rand()*2;
        setprop("hazards/icing/pitot-icing-lvl", pitot_icing_lvl);
        if (pitot_icing_lvl < 0) {
            pitot_icing_lvl = 0;
#           setprop("systems/pitot[0]/serviceable",1);
#           setprop("systems/pitot[1]/serviceable",1);
            setprop("hazards/icing/pitot",0);
        }
        
    }
#   if (ias_serviceable == 0) {
#       setprop("instrumentation/airspeed-indicator/indicated-speed-kt",
#       (internal_ias - pitot_icing_lvl));
#   }

    settimer(pitot_fail, 0.1);
}

var prop_icing = func {

    var engine0_running = getprop("engines/engine[0]/running");
    var engine1_running = getprop("engines/engine[1]/running");
    var prop_heat = getprop("controls/anti-ice/prop-heat");
    var oat = getprop("environment/temperature-degc");
    var dew_point = getprop("environment/dewpoint-degc");
    var rand_prop_icing0 = rand()*50;
    var rand_prop_icing1 = rand()*50;

    # Set a mark #

    if (oat <= 0 and oat <= dew_point and prop_heat != 1) {
        setprop("hazards/icing/propeller",1);
    } else {
        setprop("hazards/icing/propeller",0);
    }

    if (oat <= 0 and oat <= dew_point and prop_heat != 1) {
        prop_icing_time = getprop("sim/time/elapsed-sec");
    }
    if (oat > 0 or oat <= dew_point or prop_heat == 1) {
        prop_no_icing_time = getprop("sim/time/elapsed-sec");
    }
    if (oat <= 0 and oat <= dew_point and prop_heat != 1) {
        prop_icing_index = prop_icing_time - prop_no_icing_time;
    }
    if ((oat > 0 or oat > dew_point or prop_heat == 1) and prop_icing_index > 0) {
        prop_icing_index = prop_icing_index - (prop_no_icing_time - prop_icing_time)/100;
    }
    if (prop_icing_index > 1600) {
        prop_icing_index = 1600;
    }

    if (prop_icing_index > 0 and oat <= 0 and oat <= dew_point and prop_heat != 1 and engine0_running and (getprop("engines/engine[0]/rpm") - prop_icing_index - rand_prop_icing0)>230) {
        setprop("engines/engine[0]/rpm", (getprop("engines/engine[0]/rpm") - prop_icing_index - rand_prop_icing0));
    }
    if (prop_icing_index > 0 and oat <= 0 and oat <= dew_point and prop_heat != 1 and engine1_running and (getprop("engines/engine[1]/rpm") - prop_icing_index - rand_prop_icing1)>230) {
        setprop("engines/engine[1]/rpm", (getprop("engines/engine[1]/rpm") - prop_icing_index - rand_prop_icing1));
    }
    if (prop_icing_index > 0 and oat <= 0 and oat <= dew_point and prop_heat != 1 and engine0_running and (getprop("engines/engine[0]/rpm") - prop_icing_index - rand_prop_icing0)<=230) {
        setprop("engines/engine[0]/rpm", 230);
    }
    if (prop_icing_index > 0 and oat <= 0 and oat <= dew_point and prop_heat != 1 and engine1_running and (getprop("engines/engine[1]/rpm") - prop_icing_index - rand_prop_icing1)<=230) {
        setprop("engines/engine[1]/rpm", 230);
    }


    if (prop_icing_index > 0 and (oat > 0 or oat > dew_point or prop_heat == 1)) {
        if ((getprop("engines/engine[0]/rpm") - prop_icing_index) <=230 or (getprop("engines/engine[1]/rpm") - prop_icing_index)<=230) {
	    setprop("engines/engine[0]/rpm", 230);
	    setprop("engines/engine[1]/rpm", 230);
	} else {
            setprop("engines/engine[0]/rpm", (getprop("engines/engine[0]/rpm") - prop_icing_index));
	    setprop("engines/engine[1]/rpm", (getprop("engines/engine[1]/rpm") - prop_icing_index));
        }
    }
    
    settimer(prop_icing, 0);
}

var apDisable = func {
    var pitot_icing = getprop("hazards/icing/pitot");
    var prop_icing = getprop("hazards/icing/propeller");
    if (pitot_icing == 1 or prop_icing == 1) {
        setprop("controls/autopilot/settings/apflag", 0);
        setprop("controls/autopilot/settings/altflag", 0);
        setprop("controls/autopilot/settings/iasflag", 0);
        setprop("controls/autopilot/settings/hdgflag", 0);
        setprop("controls/autopilot/settings/hdgsetflag", 0);
        setprop("controls/autopilot/settings/navsetflag", 0);
        setprop("controls/autopilot/settings/gssetflag", 0);
    }
    settimer(apDisable, 1);
}

setlistener("/sim/signals/fdm-initialized", sands_stones);
setlistener("/sim/signals/fdm-initialized", pitot_fail);
setlistener("/sim/signals/fdm-initialized", prop_icing);
setlistener("/sim/signals/fdm-initialized", apDisable);
