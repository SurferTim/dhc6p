props.globals.initNode("instrumentation/heading-indicator-real-dg/lat-nut", 0);
props.globals.initNode("instrumentation/heading-indicator-real-dg/earth-err", 0.0);
props.globals.initNode("instrumentation/heading-indicator-real-dg/lat-nut-corr", 0.0);
props.globals.initNode("instrumentation/heading-indicator-real-dg/transport-wander", 0.0);

var earth_err = 0;
var lat_nut_corr = 0;

var earthRate = func {
    var current_lat = getprop("position/latitude-deg");
    var lat_nut = getprop("instrumentation/heading-indicator-real-dg/lat-nut");
    var earth_rate = -(15 * math.sin(current_lat * math.pi / 180) * (1/36000));
    var lat_nut_rate = (15 * math.sin(lat_nut * math.pi / 180) * (1/36000));
    earth_err = earth_err + earth_rate;
    lat_nut_corr = lat_nut_corr + lat_nut_rate;
    setprop("instrumentation/heading-indicator-real-dg/earth-err", earth_err);
    setprop("instrumentation/heading-indicator-real-dg/lat-nut-corr", lat_nut_corr);
    settimer(earthRate, 0.1);
}

setlistener("/sim/signals/fdm-initialized", earthRate);

# initial position:
var start_lat = getprop("position/latitude-deg");
var start_lon = getprop("position/longitude-deg");
var transport_wander = 0.0;

var transportWander = func {
    var end_lat = getprop("position/latitude-deg");
    var end_lon = getprop("position/longitude-deg");
    var mean_lat = (start_lat + end_lat)/2;
    var transport_wander_rate = -((end_lon - start_lon) * math.sin(mean_lat * math.pi / 180));
   
    transport_wander = transport_wander + transport_wander_rate;
    setprop("instrumentation/heading-indicator-real-dg/transport-wander", transport_wander);

    # re-initial position again:
    start_lat = getprop("position/latitude-deg");
    start_lon = getprop("position/longitude-deg");
    
    settimer(transportWander, 0.1);
}
setlistener("/sim/signals/fdm-initialized", transportWander);
