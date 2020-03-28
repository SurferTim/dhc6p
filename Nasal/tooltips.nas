# Initialization
setprop("/tooltips-custom/radar-alt", 0.0);
setprop("/tooltips-custom/torque-pressure[0]", 0.0);
setprop("/tooltips-custom/torque-pressure[1]", 0.0);
setprop("/tooltips-custom/torque-ftlb[0]", 0.0);
setprop("/tooltips-custom/torque-ftlb[1]", 0.0);

var RadarAlt = func {
    var gear_alt = getprop("position/gear-agl-ft");
    if (gear_alt >= 2500) {
        setprop("/tooltips-custom/radar-alt", 2500.0);
    } else {
        setprop("/tooltips-custom/radar-alt", gear_alt);
    }
    settimer(RadarAlt, 0.3);
}
setlistener("/sim/signals/fdm-initialized", RadarAlt);

var TorquePressure = func {
    var torque0 = getprop("tooltips-custom/torque-ftlb[0]");
    var torque1 = getprop("tooltips-custom/torque-ftlb[1]");
    var torque_pressure0 = torque0 / 30.72;
    var torque_pressure1 = torque1 / 30.72;
    if (torque_pressure0 <= 0) {
        setprop("/tooltips-custom/torque-pressure[0]", 0.0);
    } else if (torque_pressure0 > 0 and torque_pressure0 <= 80) {
        setprop("/tooltips-custom/torque-pressure[0]", torque_pressure0);
    } else {
        setprop("/tooltips-custom/torque-pressure[0]", 80.0);
    }
    if (torque_pressure1 <= 0) {
        setprop("/tooltips-custom/torque-pressure[1]", 0.0);
    } else if (torque_pressure1 > 0 and torque_pressure1 <= 80) {
        setprop("/tooltips-custom/torque-pressure[1]", torque_pressure1);
    } else {
        setprop("/tooltips-custom/torque-pressure[1]", 80.0);
    }
    settimer(TorquePressure, 0.3);
}
setlistener("/sim/signals/fdm-initialized", TorquePressure);
