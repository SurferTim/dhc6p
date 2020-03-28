props.globals.initNode("/systems/electrical/outputs/overhead-light-dim-factor", 0.0);
props.globals.initNode("/systems/electrical/outputs/overhead-light", 0.0);

var overheadLight = func {   
    var oh_lt_output = getprop("/systems/electrical/outputs/overhead-light") /
        23;
    var is_rembrandt = getprop("sim/rendering/rembrandt/enabled");
    var dim_factor = 0.0;
    if (oh_lt_output > 1 and is_rembrandt==0){
        dim_factor = 1;
    } else if (oh_lt_output <= 1 and is_rembrandt==0) {
        dim_factor = oh_lt_output;
    } else {
        dim_factor = 0;
    }
    setprop("/systems/electrical/outputs/overhead-light-dim-factor",
        dim_factor);
    settimer(overheadLight, 0.1);
};
setlistener("sim/signals/fdm-initialized",overheadLight);
