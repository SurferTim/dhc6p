props.globals.initNode("instrumentation/heading-indicator-real-dg/heading-bug-deg", 0);
props.globals.initNode("instrumentation/heading-indicator-real-dg/heading-bug-error-deg", 0);
props.globals.initNode("instrumentation/heading-indicator-real-dg/indicated-heading-deg", 0);
props.globals.initNode("systems/electrical/outputs/DG", 0.0, "DOUBLE");
srand();
var hdg_stop = rand() * 360;
var init_true_heading = getprop("orientation/heading-deg");
props.globals.initNode("instrumentation/heading-indicator-real-dg/offset-deg", (hdg_stop - getprop("orientation/heading-deg")));


var gyro = func {
    var offset = getprop("instrumentation/heading-indicator-real-dg/offset-deg");

    var transport_wander = getprop("instrumentation/heading-indicator-real-dg/transport-wander");
    
    var true_heading = getprop("orientation/heading-deg");

    var earth_err = getprop("instrumentation/heading-indicator-real-dg/earth-err");
    var lat_nut_corr = getprop("instrumentation/heading-indicator-real-dg/lat-nut-corr");

    var hdg = true_heading + earth_err + lat_nut_corr + transport_wander + offset;
    if (hdg >= 360) {
        hdg = hdg - 360;
    }

    if (getprop("systems/electrical/outputs/DG") > 8) {
        init_true_heading = hdg - offset;
        setprop("instrumentation/heading-indicator-real-dg/indicated-heading-deg", hdg);
    } else {
        setprop("instrumentation/heading-indicator-real-dg/indicated-heading-deg", (init_true_heading + offset));
   }
    
    var hdg_bug = getprop("instrumentation/heading-indicator-real-dg/heading-bug-deg");
    var hdg_error = hdg_bug - hdg;
    if (hdg_error > 180) {
        hdg_error = hdg_error - 360;
    }
    if (hdg_error < -180) {
        hdg_error = hdg_error + 360;
    }
    setprop("instrumentation/heading-indicator-real-dg/custom-heading-bug-error-deg",hdg_error);
    settimer(gyro, 0);
}

setlistener("/sim/signals/fdm-initialized", gyro);