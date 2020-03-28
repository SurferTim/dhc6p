# print G force when touchdown.

props.globals.initNode("position/gear-agl-ft", 0);
var count = 10;

var printGforce = func {
    var vs = getprop("velocities/vertical-speed-fps") * 60;
    var ias = getprop("velocities/airspeed-kt");
    var ggl = getprop("position/gear-agl-ft");
    var gr1_cmprs = getprop("gear/gear[1]/compression-norm");
    var gr2_cmprs = getprop("gear/gear[2]/compression-norm");
    var gdamped = getprop("accelerations/pilot-gdamped");
    var replay_state = getprop("sim/freeze/replay-state");
    
    if (count <= 9 and (gr1_cmprs != 0 or gr2_cmprs != 0) and replay_state == 0) {
        print("Touchdown G Force: ", gdamped);
        print("Touchdown VS: ", vs);
	
	if (count == 9){
	    print("=======================================");
	    print("=======================================");
	}

        count = count + 1;
    }

    if (ggl > 30){
        count = 0;
    }
    
    settimer(printGforce, 0.01);
};
setlistener("/sim/signals/fdm-initialized", printGforce);