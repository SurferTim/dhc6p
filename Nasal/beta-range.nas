props.globals.initNode("engines/engine[0]/reverse",0.0);
props.globals.initNode("engines/engine[1]/reverse",0.0);
props.globals.initNode("/controls/engines/engine[0]/internal-throttle-rvrs",0.0);
props.globals.initNode("/controls/engines/engine[1]/internal-throttle-rvrs",0.0);
props.globals.initNode("engines/engine[0]/fuel-flow-gph",0.0);
props.globals.initNode("engines/engine[1]/fuel-flow-gph",0.0);
props.globals.initNode("engines/engine[0]/beta-range-nut-l",0.5);
props.globals.initNode("engines/engine[1]/beta-range-nut-r",0.5);

var betaRange = func {

    var reverse1 = getprop("engines/engine[0]/reverse");
    var reverse2 = getprop("engines/engine[1]/reverse");
    var beta_range_nut_l = getprop("engines/engine[0]/beta-range-nut-l");
    var beta_range_nut_r = getprop("engines/engine[1]/beta-range-nut-r");

    setprop("/controls/engines/engine[0]/internal-throttle-rvrs", beta_range_nut_l*getprop("/controls/engines/engine[0]/throttle-rvrs"));
    
    setprop("/controls/engines/engine[1]/internal-throttle-rvrs", beta_range_nut_r*getprop("/controls/engines/engine[1]/throttle-rvrs"));

    if (reverse1 != 0) {
        setprop("engines/engine[0]/fuel-flow-gph", (0.3+getprop("engines/engine[0]/reverse")*20));
    }

    if (reverse2 != 0) {
        setprop("engines/engine[1]/fuel-flow-gph", (0.3+getprop("engines/engine[1]/reverse")*20));
    }
    
     settimer(betaRange,0);
}
setlistener("/sim/signals/fdm-initialized", betaRange);

