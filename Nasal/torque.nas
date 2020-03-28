# The IAS, heater, and intake deflector would influence the torque
# (torque pressure).

props.globals.initNode("engines/engine[0]/torque-ftlb",0);
props.globals.initNode("engines/engine[1]/torque-ftlb",0);
props.globals.initNode("velocities/airspeed-kt",0);
props.globals.initNode("controls/engines/engine[0]/intake-deflector",0);
props.globals.initNode("controls/engines/engine[1]/intake-deflector",0);
props.globals.initNode("controls/anti-ice/prop-heat",0);
setprop("/tooltips-custom/torque-ftlb[0]", 0.0);
setprop("/tooltips-custom/torque-ftlb[1]", 0.0);

var torque = func {
    var intake_deflector0 = getprop("controls/engines/engine[0]/intake-deflector");
    var intake_deflector1 = getprop("controls/engines/engine[1]/intake-deflector");
    var ias = getprop("velocities/airspeed-kt");
    var propdeice = getprop("controls/anti-ice/prop-heat");
    var torque0 = getprop("engines/engine[0]/torque-ftlb");
    var torque1 = getprop("engines/engine[1]/torque-ftlb");

    var ias_effect = math.pow((ias/10),2) * 0.06 * 30.72;
    var propdeice_effect = propdeice * 3 * 30.72;
    var intake_deflector_effect0 = intake_deflector0 * 30.72;
    var intake_deflector_effect1 = intake_deflector1 * 30.72;

    torque0 = torque0 + ias_effect - intake_deflector_effect0 - propdeice_effect;
    torque1 = torque1 + ias_effect - intake_deflector_effect1 - propdeice_effect;

    setprop("engines/engine[0]/torque-ftlb", torque0);
    setprop("engines/engine[1]/torque-ftlb", torque1);
    setprop("tooltips-custom/torque-ftlb[0]", torque0);
    setprop("tooltips-custom/torque-ftlb[1]", torque1);

    settimer(torque, 0);
}

setlistener("/sim/signals/fdm-initialized", torque);
