setprop("instrumentation/nav[0]/crs-catched", 0.0);
setprop("instrumentation/nav[0]/gs-catched", 0.0);
setprop("controls/autopilot/settings/navsetflag", 0.0);
setprop("controls/autopilot/settings/gssetflag", 0.0);
setprop("instrumentation/nav[0]/heading-needle-deflection", 10.0);
setprop("instrumentation/nav[0]/gs-needle-deflection-deg", 0.7);

var catch = func {

    var crs_ndl = getprop("instrumentation/nav[0]/heading-needle-deflection");
    var navflag = getprop("controls/autopilot/settings/navsetflag");
    var gs_ndl = getprop("instrumentation/nav[0]/gs-needle-deflection-deg");
    var gsflag = getprop("controls/autopilot/settings/gssetflag");

    if ((crs_ndl < 1 and crs_ndl > -1) and navflag == 1) {
        setprop("instrumentation/nav[0]/crs-catched", 1);
	setprop("controls/autopilot/settings/hdgsetflag", 0);
    }

    if ((gs_ndl < 0.07 and gs_ndl > -0.07) and gsflag == 1) {
        setprop("instrumentation/nav[0]/gs-catched", 1);
	setprop("controls/autopilot/settings/iasflag", 0);
	setprop("controls/autopilot/settings/vssetflag", 0);
	setprop("controls/autopilot/settings/altsetflag", 0);
    }

    if (gsflag != 1) {
        setprop("instrumentation/nav[0]/gs-catched", 0);
    }

    if (navflag != 1) {
        setprop("instrumentation/nav[0]/crs-catched", 0);
    }

    settimer(catch, 0.1);
}

setlistener("sim/signals/fdm-initialized", catch);
