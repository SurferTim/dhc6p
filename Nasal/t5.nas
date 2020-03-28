

props.globals.initNode("environment/temperature-degc",0);
props.globals.initNode("engines/engine[0]/n2",0);
props.globals.initNode("engines/engine[1]/n2",0);
props.globals.initNode("position/altitude-ft",0);

var t5 = func {
    var pressure_alt = getprop("position/altitude-ft");
    var oat = getprop("environment/temperature-degc");
    var gg0 = getprop("engines/engine[0]/n2");
    var gg1 = getprop("engines/engine[1]/n2");
    var t5_0 = gg0 * 6.326530612 + oat;
    var t5_1 = gg1 * 6.326530612 + oat;
    var t5_startup0 = 0;
    var t5_startup1 = 0;
    
#####################################################
# These two lines are only for twisting purpose:    #
#                                                   #
#   if (getprop("engines/engine[0]/running") == 0)  #
#        setprop("engines/engine[0]/t5", 725);      #
#####################################################

    if (pressure_alt > 3000) {
	t5_0 = t5_0 + (pressure_alt * 0.004314286);	
	t5_1 = t5_1 + (pressure_alt * 0.004314286);
    }


    if ((getprop("engines/engine[0]/running"))) {
        setprop("engines/engine[0]/t5", t5_0);
    }

    if ((getprop("engines/engine[1]/running"))) {
        setprop("engines/engine[1]/t5", t5_1);
    }

    if ((getprop("engines/engine[0]/running"))==0) {
        setprop("engines/engine[0]/t5", (gg0 * 6.326530612 + oat));
    }
    
    if ((getprop("engines/engine[1]/running"))==0) {
        setprop("engines/engine[1]/t5", (gg1 * 6.326530612 + oat));
    }
    
    settimer(t5, 0);
}

setlistener("/sim/signals/fdm-initialized", t5);