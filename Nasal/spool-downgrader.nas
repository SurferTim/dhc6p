var spoolDowngrade = func {

    var throttle_fwd0 = getprop("/controls/engines/engine[0]/throttle-fwd");
    var throttle_fwd1 = getprop("/controls/engines/engine[1]/throttle-fwd");
    var intthrottle_fwd0 = getprop("/controls/engines/engine[0]/internal-throttle-fwd") or 0.00;
    var intthrottle_fwd1 = getprop("/controls/engines/engine[1]/internal-throttle-fwd") or 0.00;

    if(throttle_fwd0 > intthrottle_fwd0) {
        interpolate("/controls/engines/engine[0]/internal-throttle-fwd",throttle_fwd0,2.0);
    }
    else {
        interpolate("/controls/engines/engine[0]/internal-throttle-fwd",throttle_fwd0,1.0);
    }

    if(throttle_fwd1 > intthrottle_fwd1) {
        interpolate("/controls/engines/engine[1]/internal-throttle-fwd",throttle_fwd1,2.0);
    }
    else {
        interpolate("/controls/engines/engine[1]/internal-throttle-fwd",throttle_fwd1,1.0);
    }

    settimer(spoolDowngrade,0);
}
setlistener("/sim/signals/fdm-initialized", spoolDowngrade);

