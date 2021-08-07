props.globals.initNode("/systems/electrical/outputs/cabin-lights-dim-factor", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/cabin-lights", 0.0, "DOUBLE");

var cabinLight = func {   
    var cab_lgt_output = getprop("/systems/electrical/outputs/cabin-lights") /
        23;
    var dim_factor = 0.0;
    if (cab_lgt_output > 1){
        dim_factor = 1;
    } else if (cab_lgt_output <= 1) {
        dim_factor = cab_lgt_output;
    } else {
        dim_factor = 0;
    }
    setprop("/systems/electrical/outputs/cabin-lights-dim-factor",
        dim_factor);
    settimer(cabinLight, 0.1);
};
setlistener("sim/signals/fdm-initialized",cabinLight);
