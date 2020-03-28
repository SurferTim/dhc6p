props.globals.initNode("autopilot/internal/delay-change", 0);
props.globals.initNode("controls/autopilot/settings/iasflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/altsetflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/vssetflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/gssetflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/hdgflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/hdgsetflag", 0, "BOOL");
props.globals.initNode("controls/autopilot/settings/navsetflag", 0, "BOOL");

var smoothAnimate = func {

    var aileron = getprop("controls/flight/aileron");
    interpolate("controls/flight/aileron-smooth",aileron,1.5);

    var elevator = getprop("controls/flight/elevator");
    interpolate("controls/flight/elevator-smooth",elevator,1.5);

    settimer(smoothAnimate,0);
}

setlistener("/sim/signals/fdm-initialized", smoothAnimate);
