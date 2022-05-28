props.globals.initNode("controls/engines/engine[0]/throttle",0.0);
props.globals.initNode("controls/engines/engine[1]/throttle",0.0);
props.globals.initNode("controls/engines/engine[0]/reverser",0);
props.globals.initNode("controls/engines/engine[1]/reverser",0);
props.globals.initNode("/fdm/jsbsim/propulsion/engine[0]/constant-speed-mode",1);
props.globals.initNode("/fdm/jsbsim/propulsion/engine[1]/constant-speed-mode",1);

var L_reverse = func {
    var throttle = getprop("controls/engines/engine[0]/throttle");
    var reverse = getprop("controls/engines/engine[0]/reverser");

    if (reverse) {
        setprop("/fdm/jsbsim/propulsion/engine[0]/constant-speed-mode",0);
    } else {
        setprop("/fdm/jsbsim/propulsion/engine[0]/constant-speed-mode",1);
    }

    settimer(L_reverse,0);
}
setlistener("/sim/signals/fdm-initialized", L_reverse);

var R_reverse = func {
    var throttle = getprop("controls/engines/engine[1]/throttle");
    var reverse = getprop("controls/engines/engine[1]/reverser");

    if (reverse) {
        setprop("/fdm/jsbsim/propulsion/engine[1]/constant-speed-mode",0);
    } else {
        setprop("/fdm/jsbsim/propulsion/engine[1]/constant-speed-mode",1);
    }

    settimer(R_reverse,0);
}
setlistener("/sim/signals/fdm-initialized", R_reverse);

#togglereverser = func {
#    r1 = props.globals.getNode("/fdm/jsbsim/propulsion/engine[0]");
#    r2 = props.globals.getNode("/fdm/jsbsim/propulsion/engine[1]");
#    r3 = props.globals.getNode("/controls/engines/engine[0]");
#    r4 = props.globals.getNode("/controls/engines/engine[1]");
#    r5 = props.globals.getNode("/sim/input/selected");
#    rv1 = props.globals.getNode("/engines/engine[0]/reverser-pos-norm");
#    rv2 = props.globals.getNode("/engines/engine[1]/reverser-pos-norm");

#    val = rv1.getValue();

#    if (val == 0 or val == nil) {
#        interpolate(rv1.getPath(), 1.0, 1.4); 
#        interpolate(rv2.getPath(), 1.0, 1.4);  
#        r1.getChild("reverser-angle-rad").setValue(math.pi);
#        r2.getChild("reverser-angle-rad").setValue(math.pi);
#        r3.getChild("reverser").setBoolValue(1);
#        r4.getChild("reverser").setBoolValue(1);
#        r5.getChild("engine[0]").setBoolValue(1);
#        r5.getChild("engine[1]").setBoolValue(1);
#    } else {
#        if (val == 1.0){
#            interpolate(rv1.getPath(), 0.0, 1.4); 
#            interpolate(rv2.getPath(), 0.0, 1.4);  
#            r1.getChild("reverser-angle-rad").setValue(0);
#            r2.getChild("reverser-angle-rad").setValue(0);
#            r3.getChild("reverser").setBoolValue(0);
#            r4.getChild("reverser").setBoolValue(0);
#            r5.getChild("engine[0]").setBoolValue(1);
#            r5.getChild("engine[1]").setBoolValue(1); 
#        }  
#    }
#}
