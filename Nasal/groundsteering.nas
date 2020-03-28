props.globals.initNode("sim/gui/dialogs/tiller/value",0.0,"DOUBLE");

var groundsteering = func {

    if(!getprop("/controls/gear/tiller-enabled")) setprop("/controls/gear/tiller", getprop("/controls/flight/rudder"));

    setprop("/sim/gui/dialogs/tiller/value", getprop("/controls/gear/tiller") * 60);

    settimer(groundsteering, 0);

}

setlistener("/sim/signals/fdm-initialized", groundsteering);