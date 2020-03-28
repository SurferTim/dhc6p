########## Initial Property Avoid Nil ##############

setprop("/systems/electrical/outputs/window-heat", 0.0);

########## Global Variable Definition #########
var fog_lvl = 0.0;
var frost_lvl = 0.0;
var is_warmer = 0;
var is_warmer_counter = 1;
var first_oat = 0;
var second_oat = 0;
###############################################

var rain_effects = func {


    ############ Rain drop ##########
    var airspeed = getprop("/velocities/airspeed-kt");

    var airspeed_max = 200;

    if (airspeed > airspeed_max) {airspeed = airspeed_max;}

    airspeed = math.sqrt(airspeed/airspeed_max);

    var splash_x = -0.1 - 2.0 * airspeed;
    var splash_y = 0.0;
    var splash_z = 1.0 - 1.35 * airspeed;

    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);
    
    settimer(rain_effects, 0);
}


############ Fog ##########

var isWarmer = func {
    is_warmer_counter = is_warmer_counter + 1;
    if (math.fmod(is_warmer_counter, 2) == 0) {
        first_oat = getprop("/environment/temperature-degc");
    } else {
        second_oat = getprop("/environment/temperature-degc");
        is_warmer = ((second_oat - first_oat) > 0.05);
    }
    settimer(isWarmer, 1.0);
}

var fog_effects = func {
    var window_heat_on = getprop("/systems/electrical/outputs/window-heat");
    var oat = getprop("/environment/temperature-degc");
    var dew_point = getprop("/environment/dewpoint-degc");
    var relative_humidity = getprop("/environment/relative-humidity");
    
    if (is_warmer ==1 and window_heat_on < 18) {
        fog_lvl = fog_lvl + 0.01;
        if (fog_lvl > (relative_humidity / 80)) {
            fog_lvl = relative_humidity / 80;
        }
        if (fog_lvl > 1) {
            fog_lvl = 1;
        }
    } 
    if (window_heat_on >=18 ) {
        fog_lvl = fog_lvl - 0.01;
        if (fog_lvl < 0) {
            fog_lvl = 0;
        }
    }

    setprop("/environment/aircraft-effects/fog-level", fog_lvl);

    settimer(fog_effects, 0.1);
}

############ Frost ##########
var frost_effects = func {

    var window_heat_on = getprop("/systems/electrical/outputs/window-heat");
    var oat = getprop("/environment/temperature-degc");
    var dew_point = getprop("/environment/dewpoint-degc");
    var relative_humidity = getprop("/environment/relative-humidity");

    if (oat <= dew_point and oat <= 0 and window_heat_on < 18 and
        relative_humidity > 50) {
        frost_lvl = frost_lvl + 0.01;
        if (frost_lvl > (math.abs(oat) / 10)){
            frost_lvl = math.abs(oat) / 10;
        }
        if (frost_lvl > 1){
            frost_lvl = 1;
        }
    } 
    if (oat > 0 or oat > dew_point or window_heat_on >= 18) {
        frost_lvl = frost_lvl - 0.01;
        if (frost_lvl < 0) {
            frost_lvl = 0;
        }
    }

    setprop("/environment/aircraft-effects/frost-level", frost_lvl);   
    settimer(frost_effects, 0.1);
}

############## Windshield Wipers ################
var wipers = func {
    var wipers_position = getprop("/controls/electric/wipers/position-norm");
    var use_wipers = getprop("/environment/aircraft-effects/use-wipers");
    if (wipers_position <= 0) {
        setprop("/environment/aircraft-effects/use-wipers", 0);
    } else if(wipers_position>0 and wipers_position < 0.5 and use_wipers == 0) {
        setprop("/environment/aircraft-effects/use-wipers", 0);
    } else {
        setprop("/environment/aircraft-effects/use-wipers", 1);
    }
    settimer(wipers, 0.1);
}

setlistener("/sim/signals/fdm-initialized", rain_effects);
setlistener("/sim/signals/fdm-initialized", fog_effects);
setlistener("/sim/signals/fdm-initialized", isWarmer);
setlistener("/sim/signals/fdm-initialized", frost_effects);
setlistener("/sim/signals/fdm-initialized", wipers);

#########################
##### THUNDER SOUND #####
#########################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after 0.2 seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

var speed_of_sound = func (t, re) {
    # Compute speed of sound in m/s
    #
    # t = temperature in Celsius
    # re = amount of water vapor in the air

    # Compute virtual temperature using mixing ratio (amount of water vapor)
    # Ratio of gas constants of dry air and water vapor: 287.058 / 461.5 = 0.622
    var T = 273.15 + t;
    var v_T = T * (1 + re/0.622)/(1 + re);

    # Compute speed of sound using adiabatic index, gas constant of air,
    # and virtual temperature in Kelvin.
    return math.sqrt(1.4 * 287.058 * v_T);
};

var thunder = func (name) {
    var thunderCalls = 0;

    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x, 2) + math.pow(lightning_pos_y, 2));

    # On the ground, thunder can be heard up to 16 km. Increase this value
    # a bit because the aircraft is usually in the air.
    if (lightning_distance > 20000)
        return;

    var t = getprop("/environment/temperature-degc");
    var re = getprop("/environment/relative-humidity") / 100;
    var delay_seconds = lightning_distance / speed_of_sound(t, re);

    # Maximum volume at 5000 meter
    var lightning_distance_norm = std.min(1.0, 1 / math.pow(lightning_distance / 5000.0, 2));

    settimer(func {
        var thunder1 = getprop("/sim/sound/click-thunder1");
        var thunder2 = getprop("/sim/sound/click-thunder2");
        var thunder3 = getprop("/sim//sound/click-thunder3");

        if (!thunder1) {
            thunderCalls = 1;
            setprop("/sim/sound/lightning/dist1", lightning_distance_norm);
        }
        else if (!thunder2) {
            thunderCalls = 2;
            setprop("/sim/sound/lightning/dist2", lightning_distance_norm);
        }
        else if (!thunder3) {
            thunderCalls = 3;
            setprop("/sim/sound/lightning/dist3", lightning_distance_norm);
        }
        else
            return;

        # Play the sound (sound files are about 9 seconds)
        click("thunder" ~ thunderCalls, 9.0, 0);
    }, delay_seconds);
};

setlistener("/environment/lightning/lightning-pos-y", thunder);
