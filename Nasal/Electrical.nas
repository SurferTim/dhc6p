#### turboprop engine electrical system #### 
#### Syd Adams and Jonathan Schellhase  ####

var ammeter_ave = 0.0;
var outPut = "systems/electrical/outputs/";
var BattVolts = props.globals.getNode("systems/electrical/batt-volts",1);
var Volts = props.globals.getNode("/systems/electrical/volts",1);
var Amps = props.globals.getNode("/systems/electrical/amps",1);
var EXT  = props.globals.getNode("/controls/electric/external-power",1);
var increasing_counter0 = 0.0;
var increasing_counter1 = 0.0;
var fuel_rich0 = 0.0;
var fuel_rich1 = 0.0;

# Initialize electrical buses
props.globals.initNode("/systems/electrical/buses/L-28V-DC-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/L-28V-DC-volts",0.0,"DOUBLE");
props.globals.initNode("/systems/electrical/buses/R-28V-DC-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/R-28V-DC-volts",0.0,"DOUBLE");
props.globals.initNode("/systems/electrical/buses/Main-bat-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/Main-bat-volts",0.0,"DOUBLE");
props.globals.initNode("/systems/electrical/buses/Bat-ext-pwr-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/Bat-ext-pwr-volts",0.0,"DOUBLE");
props.globals.initNode("/systems/electrical/buses/AC-26V-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/AC-26V-volts",0.0,"DOUBLE");
props.globals.initNode("/systems/electrical/buses/AC-115V-servicable",0,"BOOL");
props.globals.initNode("/systems/electrical/buses/AC-115V-volts",0.0,"DOUBLE");

#strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
#aircraft.light.new("controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);
#beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
#aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);

var navLight = aircraft.light.new("/sim/model/lights/nav-lights", [0], "/controls/lighting/nav-lights");
var landingLightL = aircraft.light.new("/sim/model/lights/landing-light[0]", [0], "/controls/lighting/landing-light[0]");
var landingLightR = aircraft.light.new("/sim/model/lights/landing-light[1]", [0], "/controls/lighting/landing-light[1]");
var taxiLight = aircraft.light.new("/sim/model/lights/taxi-lights", [0], "/controls/lighting/taxi-lights");
var strobeLight = aircraft.light.new("/sim/model/lights/strobe", [0.08, 2.5], "/controls/lighting/strobe");
var beaconLight = aircraft.light.new("/sim/model/lights/beacon", [0.08, 0.08, 0.08, 2.5], "/controls/lighting/beacon");

# var battery = Battery.new(switch-prop,volts,amps,amp_hours,charge_percent,charge_amps);
Battery = {
    new : func(swtch,vlt,amp,hr,chp,cha){
    m = { parents : [Battery] };
            m.switch = props.globals.getNode(swtch,1);
            m.switch.setBoolValue(0);
            m.ideal_volts = vlt;
            m.ideal_amps = amp;
            m.amp_hours = hr;
            m.charge_percent = chp; 
            m.charge_amps = cha;
    return m;
    },
    apply_load : func(load,dt) {
        if(me.switch.getValue()){
        var amphrs_used = load * dt / 3600.0;
        var percent_used = amphrs_used / me.amp_hours;
        me.charge_percent -= percent_used;
        if ( me.charge_percent < 0.0 ) {
            me.charge_percent = 0.0;
        } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
        }
        var output =me.amp_hours * me.charge_percent;
        return output;
        }else return 0;
    },

    get_output_volts : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_volts * factor;
            return output;
        }else return 0;
    },

    get_output_amps : func {
        if(me.switch.getValue()){
            var x = 1.0 - me.charge_percent;
            var tmp = -(3.0 * x - 1.0);
            var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
            var output =me.ideal_amps * factor;
            return output;
        }else return 0;
    }
};

# var alternator = Alternator.new(num,switch,rpm_source,rpm_threshold,volts,amps);
Alternator = {
    new : func (num,switch,src,thr,vlt,amp){
        m = { parents : [Alternator] };
        m.switch =  props.globals.getNode(switch,1);
        m.switch.setBoolValue(0);
        m.meter =  props.globals.getNode("systems/electrical/gen-load["~num~"]",1);
        m.meter.setDoubleValue(0);
        m.gen_output =  props.globals.getNode("engines/engine["~num~"]/amp-v",1);
        m.gen_output.setDoubleValue(0);
        m.meter.setDoubleValue(0);
        m.rpm_source =  props.globals.getNode(src,1);
        m.rpm_threshold = thr;
        m.ideal_volts = vlt;
        m.ideal_amps = amp;
        return m;
    },

    apply_load : func(load, dt) {
        var cur_volt=me.gen_output.getValue();
        var cur_amp=me.meter.getValue();
        if(cur_volt >1){
            var factor=1/cur_volt;
            gout = (load+dt);
            if(gout>200)gout=200;
        }else{
            gout=0;
        }
        if(cur_amp > gout)me.meter.setValue(cur_amp - 0.1);
        if(cur_amp < gout)me.meter.setValue(cur_amp + 0.1);
    },

    get_output_volts : func {
        var out = 0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 )factor = 1.0;
            var out = (me.ideal_volts * factor);
        }
        me.gen_output.setValue(out);
        if (out > 1) return out;
        return 0;
    },

    get_output_amps : func {
        var ampout =0;
        if(me.switch.getBoolValue()){
            var factor = me.rpm_source.getValue() / me.rpm_threshold;
            if ( factor > 1.0 ) {
                factor = 1.0;
            }
            ampout = me.ideal_amps * factor;
        }
        return ampout;
    }
};

var battery = Battery.new("/sim/signals/fdm-initialized",24.75,30,36,1.0,60.0);
var alternator1 = Alternator.new(0,"controls/electric/engine[0]/generator-active","/engines/engine[0]/generator-rpm",30.0,28.5,200.0);
var alternator2 = Alternator.new(1,"controls/electric/engine[1]/generator-active","/engines/engine[1]/generator-rpm",30.0,28.5,200.0);

#####################################
setlistener("/sim/signals/fdm-initialized", func {
    BattVolts.setDoubleValue(0);
    settimer(update_electrical,5);
    print("Electrical System ... ok");

});

########################
### ELECTRICAL BUSES ###
########################

# Main battery bus.
# Recieves power directly from the battery and is always connected to it.
# Consumers: Battery/External power bus and entrance lights
main_bat_bus = func(dt) {
    var PWR = getprop("systems/electrical/serviceable");
    var bus_volts = getprop("systems/electrical/batt-volts");
    var bat_extpwr_volts = getprop("systems/electrical/buses/Bat-ext-pwr-volts");
    var gen0_volts = getprop("engines/engine[0]/amp-v");

    var battery_volts = bus_volts;

    var load = 0.0;

    # Electrical system needs to be "servicable" to activate the main battery bus. If it's not sevicable, set voltage to 0.
    if (PWR == 1) {
        setprop("systems/electrical/buses/Main-bat-servicable", 1);
        setprop("systems/electrical/buses/Main-bat-volts", bus_volts);
    } else {
        setprop("systems/electrical/buses/Main-bat-servicable", 0);
        setprop("systems/electrical/buses/Main-bat-volts", 0);
        bus_volts = 0;
    }

    bus_volts *=PWR;

    # Entrance lights power
    if(getprop("controls/electric/circuit-breakers/overhead/cabin-lts") and getprop("controls/lighting/entrance-lights")) {
        setprop(outPut~"entrance-lights", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop(outPut~"entrance-lights", 0);
    }

    load += bat_extpwr_bus(dt);
    load += Left_28V_DC_bus(dt);
    load += Right_28V_DC_bus(dt);
    load += Bus_26V_AC(dt);
    load += Bus_115V_AC(dt);

    if (getprop("systems/electrical/buses/Main-bat-servicable") == 1 and gen0_volts<bus_volts) {
        battery.apply_load(load, dt);
    } elsif (getprop("systems/electrical/buses/Main-bat-servicable") == 1 and gen0_volts>bus_volts){
        alternator1.apply_load(load, dt);
    }

    if (getprop("systems/electrical/buses/Bat-ext-pwr-volts") > battery_volts and bus_volts < 24.75 and getprop("systems/electrical/buses/Bat-ext-pwr-servicable") and getprop("controls/electric/dc-master") and gen0_volts < bus_volts){
        battery.apply_load(-battery.charge_amps, dt);
        Amps.setValue(load - battery.charge_amps);
    } elsif(getprop("systems/electrical/buses/Bat-ext-pwr-volts") > battery_volts and bus_volts < 24.75 and getprop("systems/electrical/buses/Bat-ext-pwr-servicable") and getprop("controls/electric/dc-master") and gen0_volts > bus_volts) {
        alternator1.apply_load(-battery.charge_amps, dt);
        Amps.setValue(load - battery.charge_amps);
    } elsif (battery_volts = 24.75) {
        battery.apply_load(0, 0);
        Amps.setValue(load, dt);
    }

    if (getprop("systems/electrical/buses/Bat-ext-pwr-servicable") and getprop("controls/electric/dc-master")) {
        setprop("systems/electrical/volts", bat_extpwr_volts);
    } else {
        setprop("systems/electrical/volts", bus_volts);
    }

    ammeter = -load;

    alternator1.apply_load(load, dt);
    alternator2.apply_load(load, dt);

    return load;

}

# Battery/External power bus.
# Recieves power either from the main battery bus or from external power or from the LEFT generator.
# (depending on the EXTERNAL/BATTERY selector switch).
# Can be toggled on/off via the DC master switch.
# This bus works just like a relay between the power sources and the rest of the electrical system.
# Consumers: Only the left 28V DC bus and the starter motors (in reality the generators/alternators and the starters are one and the same device,
#            but when starting the engines the starters obviously don't recieve power from the generators).
bat_extpwr_bus = func(dt) {
    # Recieve power from main battery bus
    var PWR = getprop("systems/electrical/buses/Main-bat-servicable");
    var battery_volts = battery.get_output_volts();
    BattVolts.setValue(battery_volts);
    var alternator1_volts = alternator1.get_output_volts();
    var alternator2_volts = alternator2.get_output_volts();
    var external_volts = 28.0;
    var power_selector = getprop("controls/electric/power-source");
    var EXT_plugged = getprop("sim/model/equipment/ground-services/external-power/enable");
    var dc_master = getprop("controls/electric/dc-master");

    load = 0.0;
    bus_volts = 0.0;
    power_source = nil;

    # Determine power source
    if (power_selector == 1 and dc_master == 1 and battery_volts>alternator1_volts) {
        bus_volts = battery_volts;
        power_source = "battery";
    } elsif (power_selector == 1 and alternator1_volts > 22 and alternator1_volts > battery_volts+0.5 and dc_master == 1 and getprop("controls/electric/bus-tie")) {
        bus_volts = alternator1_volts;
        power_source = "alternator1";
    } elsif (power_selector == 1 and !getprop("controls/electric/bus-tie") and alternator1_volts>=alternator2_volts) {
        bus_volts = alternator1_volts;
        power_source = "alternator1";
    } elsif (power_selector == 1 and !getprop("controls/electric/bus-tie") and alternator2_volts>alternator1_volts) {
        bus_volts = alternator2_volts;
        power_source = "alternator2";
    }

    if (EXT_plugged == 1 and power_selector == -1 and dc_master == 1){
        setprop("controls/electric/external-power", 1);
        } else {
        setprop("controls/electric/external-power", 0);
    }

    if (EXT.getBoolValue() and (external_volts > bus_volts)) {
        power_source = "external";
        bus_volts = external_volts;
        Volts = external_volts;
        battery.apply_load(-battery.charge_amps, dt);
    }
    # END determine power source

#    bus_volts *=PWR;

    # Starter motors
    var internal_starter = getprop("controls/engines/internal-engine-starter");

    # Left starter
    if (bus_volts>10 and getprop("controls/electric/circuit-breakers/main/start-l") and internal_starter>0 and getprop("controls/electric/engine[0]/generator")==1) {
        setprop(outPut~"starter-l", bus_volts);
        setprop("controls/engines/engine[0]/starter", 1);
        load += 12;
    } else {
        setprop(outPut~"starter-l", 0);
        setprop("controls/engines/engine[0]/starter", 0);
    }

    # Right starter
    if (bus_volts>10 and getprop("controls/electric/circuit-breakers/main/start-r") and internal_starter<0 and getprop("controls/electric/engine[1]/generator")==1) {
        setprop(outPut~"starter-r", bus_volts);
        setprop("controls/engines/engine[1]/starter", 1);
        load += 12;
    } else {
        setprop(outPut~"starter-r", 0);
    }

    if (internal_starter == 0) {
        setprop("controls/engines/engine[0]/starter", 0);
        setprop("controls/engines/engine[1]/starter", 0);
    }


    ### Yasim engine ###
    update_engine = func(bv) {
        var bus_volts = bv;
        var load = 0.0;
        var srvc = 0.0;
        var starter_volts = 0.0;
        var starter_volts1 = 0.0;
        var start_n2_0 = 0.0;
        var start_n2_1 = 0.0;

        var internal_starter = getprop("controls/engines/internal-engine-starter");
        var if_engine0_running = getprop("engines/engine[0]/running");
        var if_engine1_running = getprop("engines/engine[1]/running");
        var if_engine0_serviceable = getprop("engines/engine[0]/serviceable");
        var if_engine1_serviceable = getprop("engines/engine[1]/serviceable");
        var if_engine0_cutoff = getprop("controls/engines/engine[0]/cutoff");    
        var if_engine1_cutoff = getprop("controls/engines/engine[1]/cutoff");
        var aft_boost = getprop("controls/electric/aft-boost-pump");
        var fwd_boost = getprop("controls/electric/fwd-boost-pump");
        var aft_boost_pumps_volts = bus_volts * aft_boost;
        var fwd_boost_pumps_volts = bus_volts * fwd_boost;
    
        if (internal_starter == 0) {
            increasing_counter0 = 0.0;
            increasing_counter1 = 0.0;
        }

        if (internal_starter < 0) {
            internal_starter = -internal_starter;
        starter_volts1 = bus_volts * internal_starter;
        } else if (internal_starter > 0) {
            starter_volts = bus_volts * internal_starter;
        }
    
        load += internal_starter * 5;
            start_n2_0 += starter_volts * 0.7;

        var increasing0 = func {
            if (getprop("engines/engine[0]/n2") < start_n2_0) {
                increasing_counter0 = increasing_counter0 + 0.00005;
                setprop("engines/engine[0]/n2", increasing_counter0);
            settimer(increasing0, 0);
            }
        }

        if (getprop("engines/engine[0]/n2") < start_n2_0) {
            increasing0();
        }
    
        load += internal_starter * 5;
        start_n2_1 += starter_volts1 * 0.7;
    
        var increasing1 = func {
            if (getprop("engines/engine[1]/n2") < start_n2_1) {
                increasing_counter1 = increasing_counter1 + 0.00005;
                setprop("engines/engine[1]/n2", increasing_counter1);
            settimer(increasing1, 0);
            }
        }

        if (getprop("engines/engine[1]/n2") < start_n2_1) {
            increasing1();
        }
    
        var internal_condition0 = getprop("controls/engines/engine[0]/condition");
        var internal_condition1 = getprop("controls/engines/engine[1]/condition");
        var min_n2_0 = getprop("engines/engine[0]/n2");
        var min_n2_1 = getprop("engines/engine[1]/n2");

        var fuel_rich_func0 = func {
            if (if_engine0_running == 0 and fuel_rich0 <= 200 and fuel_rich0>=0) {
                fuel_rich0 =  fuel_rich0 - min_n2_0 + (internal_condition0 * 5);
            settimer(fuel_rich_func0, 1);
            }
        }

        var fuel_rich_func1 = func {
            if (if_engine1_running == 0 and fuel_rich1 <= 200 and fuel_rich1>=0) {
                fuel_rich1 =  fuel_rich1 - min_n2_1 + (internal_condition1 * 5);
            settimer(fuel_rich_func1, 1);
            }
        }

        if (fuel_rich0 >200) {
            fuel_rich0 = 200;
        } else if (fuel_rich0 <0) {
            fuel_rich0 = 0;
        }

        if (fuel_rich1 >200) {
            fuel_rich1 = 200;
        } else if (fuel_rich1 <0) {
            fuel_rich1 = 0;
        }

        fuel_rich_func0();
        fuel_rich_func1();

        if_engine0_running = getprop("engines/engine[0]/running");
        if_engine1_running = getprop("engines/engine[1]/running");

        if (getprop("engines/engine[0]/n2") >= 12 and internal_condition0 > 0 and fuel_rich0 < 25 and fwd_boost != 0 and if_engine0_serviceable and if_engine0_cutoff==0 and internal_condition0>0.382 and !getprop("sim/model/equipment/left-engine-cover")) {
            setprop("controls/engines/engine[0]/internal-condition", 1);
        } else {
            setprop("controls/engines/engine[0]/internal-condition", 0);
        }

        if (getprop("engines/engine[1]/n2") >= 12 and internal_condition1 > 0 and fuel_rich1 < 25 and aft_boost != 0  and if_engine1_serviceable and if_engine1_cutoff==0 and internal_condition1>0.382 and !getprop("sim/model/equipment/right-engine-cover")) {
            setprop("controls/engines/engine[1]/internal-condition", 1);
        } else {
        setprop("controls/engines/engine[1]/internal-condition", 0);
        }
    
        var starter_total_volts = starter_volts + starter_volts1;
    
        setprop(outPut~"starter",starter_total_volts); 

    return load;
}


#    if (dc_master == 1) {
#        load += Left_28V_DC_bus(bus_volts);
#    } else {
#        load += Left_28V_DC_bus(0);
#    }

    ammeter = 0.0;
#    if ( bus_volts > 1.0 )load += 15.0;

    if ( power_source == "battery" ) {
        ammeter = -load;
        } else {
        ammeter = battery.charge_amps;
    }

    if (!PWR) {
        bus_volts = 0;
    }

    if (power_selector != 0){
        setprop("systems/electrical/buses/Bat-ext-pwr-servicable", 1);
        setprop("systems/electrical/buses/Bat-ext-pwr-volts", bus_volts);
    } else {
        setprop("systems/electrical/buses/Bat-ext-pwr-servicable", 0);
        setprop("systems/electrical/buses/Bat-ext-pwr-volts", bus_volts);
    }

    if (!getprop("controls/electric/bus-tie") and alternator2_volts>alternator1_volts) {
        setprop("systems/electrical/buses/L-28V-DC-volts", alternator2_volts);
        setprop("systems/electrical/buses/L-28V-DC-servicable", 1);
    } else {
        setprop("systems/electrical/buses/L-28V-DC-volts", getprop("systems/electrical/buses/Bat-ext-pwr-volts"));
        setprop("systems/electrical/buses/L-28V-DC-servicable", getprop("systems/electrical/buses/Bat-ext-pwr-servicable"));
    }

    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

    load += update_engine(bus_volts);

    return load;

}

# Left 28V DC bus.
# Recieves power from the DC master (i.e. the Battery/External power bus)
Left_28V_DC_bus = func(dt) {
    var PWR = getprop("systems/electrical/buses/L-28V-DC-servicable");
    var master_av = getprop("controls/electric/master-avionics");
    var bus_volts = getprop("systems/electrical/buses/L-28V-DC-volts");
    var load = 0.0;

    # Consumers:

    # No.1 static inverter. Provides alternating current (AC) for 26V and 115V AC buses
    if (getprop("controls/electric/circuit-breakers/overhead/inverter-1") and getprop("controls/electric/inverter") == 1) {
        setprop(outPut~"inverter-1", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"inverter-1", 0);
    }

    # Hydraulic oil pump
    if (getprop("controls/electric/circuit-breakers/main/hyd-oil-pump")) {
        setprop(outPut~"hydraulics",bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"hydraulics",0);
    }

    # Left bleed air
    if (getprop("controls/electric/circuit-breakers/main/bleed-air-l") and getprop("controls/pneumatic/engine[0]/bleed")) {
        setprop(outPut~"bleed-air-left", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop(outPut~"bleed-air-left", 0);
    }

    # Stall warning (currently no lamp, only horn)
    if (getprop("controls/electric/circuit-breakers/main/stall-warn") and getprop("sim/sound/stall-warning") > 4) {
        setprop(outPut~"stall-warn", bus_volts);
        load += bus_volts / 35;
    } else {
        setprop(outPut~"stall-warn", 0);
    }

    # Airframe deice (currently not simulated)

    # Prop deice
    if (getprop("controls/electric/circuit-breakers/main/prop-deice") and getprop("controls/anti-ice/prop-heat")) {
        setprop(outPut~"prop-deice", bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"prop-deice", 0);
    }

    # Volt/Ampere meter
    if (getprop("controls/electric/circuit-breakers/main/va")) {
        setprop(outPut~"va", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"va", 0);
    }

    # Left 400 cycle caution light
    var condition = (getprop("controls/electric/caution-test") or (getprop("systems/electrical/outputs/inverter-1")<0.1 and getprop("controls/electric/inverter") == 1)) and getprop("controls/electric/circuit-breakers/main/c400-fail");
    if (condition) {
        setprop(outPut~"caution-lights/l-cycle-400", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/l-cycle-400", 0);
    }

    # Right generator overheat caution light (currently not simulated).
    if (getprop("controls/electric/caution-test")) {
        setprop(outPut~"caution-lights/gen-overheat-right", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/gen-overheat-right", 0);
    }

    # Prop sync (currently not simulated)

    # Cabin vent fan (not yet modeled)
    if (getprop("controls/electric/circuit-breakers/overhead/cabin-vent-fan") and getprop("controls/fans/cabin-vent-fan")){
        setprop(outPut~"cabin-vent-fan", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"cabin-vent-fan", 0);
    }

    # Pneumatic low pressure caution light
    var condition = (getprop("controls/electric/caution-test") or (getprop("systems/pneumatic/bleed-air-psi[0]")<22 and getprop("systems/pneumatic/bleed-air-psi[1]")<22) and !getprop("controls/pneumatic/engine[0]bleed") and !getprop("controls/pneumatic/engine[1]bleed")) and getprop("controls/electric/circuit-breakers/overhead/pneumatic-press");
    if (condition) {
        setprop(outPut~"caution-lights/low-press", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/low-press", 0);
    }

    # Prop autofeather
    if (getprop("controls/electric/circuit-breakers/main/prop-auto-feath") and getprop("controls/engines/auto-feather")){
        setprop(outPut~"auto-feather", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"auto-feather", 0);
    }

    # Left cabin reading lights (not yet simulated)
    if (getprop("controls/electric/circuit-breakers/overhead/reading") and getprop("controls/electric/circuit-breakers/overhead/cabin-lts") and getprop("controls/lighting/reading")){
        setprop(outPut~"reading-lights-left", bus_volts);
        load += bus_volts / 25;
    } else {
        setprop(outPut~"reading-lights-left", 0);
    }

    # Left and right fire detection fault indicators and fire extinguishers currently not simulated

    # Right fire detector (engine fire currently not simulated)
    if (getprop("controls/electric/circuit-breakers/main/fire-det-r") and getprop("controls/engines/fire-test")) {
        setprop(outPut~"fire-detector-r", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"fire-detector-r", 0);
    }

    # Left fire detector (engine fire currently not simulated)
    if (getprop("controls/electric/circuit-breakers/main/fire-det-l") and getprop("controls/engines/fire-test")) {
        setprop(outPut~"fire-detector-l", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"fire-detector-l", 0);
    }

    # Fire bell (connected to fire detectors)
    var condition = (getprop("controls/electric/circuit-breakers/main/fire-det-l") or getprop("controls/electric/circuit-breakers/main/fire-det-r")) and getprop("controls/engines/fire-test") and !getprop("controls/switches/firebell-switch");
    if (condition) {
        setprop(outPut~"fire-bell", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"fire-bell", 0);
    }

    # Left landing light
    if (getprop("controls/electric/circuit-breakers/main/ldg-lt-l") and getprop("controls/lighting/landing-light[0]")) {
        setprop(outPut~"landing-light-left", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop(outPut~"landing-light-left", 0);
    }

    # Rear tank low fuel level caution light
    var condition = (getprop("controls/electric/caution-test") or getprop("instrumentation/engine-instruments/fuel-qty-aft/indicated-fuelqty-lbs")<110) and getprop("controls/electric/circuit-breakers/main/fuel-l-level-aft");
    if (condition) {
        setprop(outPut~"caution-lights/low-fuel-aft", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/low-fuel-aft", 0);
    }

    # Left fuel shutoff valve (SOV)
    if (getprop("controls/electric/circuit-breakers/main/fuel-sov-l") and getprop("controls/engines/engine[0]/emerg-cutoff")) {
        setprop(outPut~"fuel-sov-l", bus_volts);
        load += bus_volts / 45;
    } else {
        setprop(outPut~"fuel-sov-l", 0);
    }

    # Left intake de-ice (currently not simulated)

    # Cabin heat/vent (curently not simulated)

    # Pilot's turn coordinator
    if (getprop("controls/electric/circuit-breakers/center/tc1")) {
        setprop(outPut~"turn-coordinator[0]", bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"turn-coordinator[0]", 0);
    }

    # Pilot's instrument and engine panel lighting
    plt_eng_emer_lts_dimmer = getprop("controls/lighting/plt-eng-inst-emer-pnl-lts");
    if (getprop("controls/electric/circuit-breakers/main/pilot-eng-cons-trim-pnl-lt")) {
        var lights = bus_volts * plt_eng_emer_lts_dimmer;
        setprop(outPut~"plt-eng-inst-emer-pnl-lts", lights);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"plt-eng-inst-emer-pnl-lts", 0);
    }

    # Flap and trim console lighting
    flap_trim_pnl_lts_dimmer = getprop("controls/lighting/flap-cons-trim-pnl-lts");
    if (getprop("controls/electric/circuit-breakers/main/pilot-eng-cons-trim-pnl-lt")) {
        var lights = bus_volts * flap_trim_pnl_lts_dimmer;
        setprop(outPut~"flap-cons-trim-pnl-lts", lights);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"flap-cons-trim-pnl-lts", 0);
    }

    # Left pitot heat
    if (getprop("controls/electric/circuit-breakers/main/pitot-htr-l") and getprop("controls/anti-ice/pitot-heat")) {
        setprop(outPut~"pitot-heat-left", bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"pitot-heat-left", 0);
    }

    # Primary boost pump AFT
    if (getprop("controls/electric/circuit-breakers/main/bst-pump-aft-1") and getprop("controls/electric/aft-boost-pump")) {
        setprop(outPut~"boost-pump-main-aft", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop(outPut~"boost-pump-main-aft", 0);
    }

    # Primary boost pump FWD
    if (getprop("controls/electric/circuit-breakers/main/bst-pump-fwd-1") and getprop("controls/electric/fwd-boost-pump")) {
        setprop(outPut~"boost-pump-main-fwd", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop(outPut~"boost-pump-main-fwd", 0);
    }

    # Boost pump pressure caution light: Primary AFT
    if ((getprop("controls/electric/caution-test") or getprop("consumables/fuel/tank[1]/boost-pump-main-aft-psi")<2) and getprop("controls/electric/circuit-breakers/main/bst-pump-press-l-pos")) {
        setprop(outPut~"caution-lights/boost-pump-main-aft-low-press", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/boost-pump-main-aft-low-press", 0);
    }

    # Boost pump pressure caution light: Primary FWD
    if ((getprop("controls/electric/caution-test") or getprop("consumables/fuel/tank[0]/boost-pump-main-fwd-psi")<2) and getprop("controls/electric/circuit-breakers/main/bst-pump-press-l-pos")) {
        setprop(outPut~"caution-lights/boost-pump-main-fwd-low-press", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/boost-pump-main-fwd-low-press", 0);
    }

    # Left oil temp gauge
    if (getprop("controls/electric/circuit-breakers/main/oil-temp-l")) {
        setprop(outPut~"oil-temp-left", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"oil-temp-left", 0);
    }

    # Left low oil press caution light
    var condition = (getprop("controls/electric/caution-test") or getprop("engines/engine[0]/oil-pressure-real-psi")<42) and getprop("controls/electric/circuit-breakers/main/oil-low-press-l");
    if (condition) {
        setprop(outPut~"caution-lights/low-oil-press-left", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/low-oil-press-left", 0);
    }

    # Position lights
    if (getprop("controls/electric/circuit-breakers/main/posn-lt") and getprop("sim/model/lights/nav-lights/state")) {
        setprop(outPut~"nav-lights", bus_volts);
        load += bus_volts / 35;
    } else {
        setprop(outPut~"nav-lights", 0);
    }

    # Beacon
    if (getprop("controls/electric/circuit-breakers/main/anti-coll-lt") and getprop("sim/model/lights/beacon/state")) {
        setprop(outPut~"beacon", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"beacon", 0);
    }

    # Strobe lights
    if (getprop("controls/electric/circuit-breakers/main/anti-coll-lt") and getprop("sim/model/lights/strobe/state")) {
        setprop(outPut~"strobe", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"strobe", 0);
    }

    # Windshield wipers
    if (getprop("controls/electric/circuit-breakers/main/ws-wiper")) {
        setprop(outPut~"wipers", bus_volts);
        if (getprop("controls/electric/wipers/position-norm") > 0.1 and bus_volts > 0 and getprop("controls/electric/circuit-breakers/main/ws-wiper")) {
            load += bus_volts / 45;
        } else {
            load += 0.0;
        }
    } else {
        setprop(outPut~"wipers", 0);
    }

    # Right generator caution light
    if ((getprop("controls/electric/caution-test") or (!getprop("controls/electric/engine[1]/generator-active") or getprop("engines/engine[1]/amp-v")<=22 or getprop("engines/engine[1]/amp-v")<getprop("systems/electrical/batt-volts")+0.5) and getprop("controls/engines/internal-engine-starter") != -1) and getprop("controls/electric/circuit-breakers/main/r-gen-fail")) {
        setprop(outPut~"caution-lights/r-gen", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/r-gen", 0);
    }

    # Duct overheat caution light (not simulated)
    if (getprop("controls/electric/caution-test")) {
        setprop(outPut~"caution-lights/duct-overheat", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/duct-overheat", 0);
    }

    # Reset props caution light
    if (getprop("controls/electric/caution-test") or (getprop("controls/engines/engine[0]/throttle")<75 and getprop("controls/engines/engine[0]/propeller-pitch")<0.95) or (getprop("controls/engines/engine[1]/throttle")<75 and getprop("controls/engines/engine[1]/propeller-pitch")<0.95)) {
        setprop(outPut~"caution-lights/reset-props", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/reset-props", 0);
    }

    # Wing tanks and air conditioning unit don't exist in this version


    # Avionics:

    # Left audio (not yet simulated)

    # Left COM
    if (getprop("controls/electric/circuit-breakers/center/lh-com1") and getprop("instrumentation/comm[0]/serviceable") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"comm[0]", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"comm[0]", 0);
    }

    # Left NAV
    if (getprop("controls/electric/circuit-breakers/center/lh-nav1") and getprop("instrumentation/nav[0]/serviceable") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"nav[0]", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"nav[0]", 0);
    }

    # Left ADF
    if (getprop("controls/electric/circuit-breakers/center/lh-adf1") and getprop("instrumentation/adf[0]/serviceable") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"adf[0]", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"adf[0]", 0);
    }

    # DME
    if (getprop("controls/electric/circuit-breakers/center/dme") and getprop("instrumentation/dme/power-btn") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"dme", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"dme", 0);
    }

    # Transponder
    if (getprop("controls/electric/circuit-breakers/center/xpdr") and getprop("instrumentation/transponder/inputs/knob-mode")!=0 and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"transponder", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"transponder", 0);
    }

    # GPS (The Garmin 196 has it's own battery, and there is no other GPS isntalled)

    # Autopilot (isn't embedded into the electrical system)

    return load;
}

# Right 28V DC bus.
# Recieves power only from the right generator
Right_28V_DC_bus = func(dt) {
    var PWR = getprop("systems/electrical/buses/R-28V-DC-servicable");
    var master_av = getprop("controls/electric/master-avionics");
    var bus_volts = getprop("systems/electrical/buses/R-28V-DC-volts");
    var load = 0.0;

    # No.2 static inverter. Provides alternating current (AC) for 26V and 115V AC buses
    if (getprop("controls/electric/circuit-breakers/overhead/inverter-2") and getprop("controls/electric/inverter") == 2) {
        setprop(outPut~"inverter-2", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"inverter-2", 0);
    }

    # Intake deflector: Left engine
    if (getprop("controls/electric/circuit-breakers/main/int-defl") and getprop("controls/engines/engine[0]/intake-deflector-extend") != 0) {
        setprop(outPut~"intake-deflector-left", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"intake-deflector-left", 0);
    }

    # Intake deflector: Right engine
    if (getprop("controls/electric/circuit-breakers/main/int-defl") and getprop("controls/engines/engine[1]/intake-deflector-extend") != 0) {
        setprop(outPut~"intake-deflector-right", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"intake-deflector-right", 0);
    }

    # Wing inspection lights (currently not simulated)

    # Taxi light (uses the right landing light circuit breaker)
    if (getprop("controls/electric/circuit-breakers/main/ldg-lt-r") and getprop("controls/lighting/taxi-lights")) {
        setprop(outPut~"taxi-light", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop(outPut~"taxi-light", 0);
    }

    # Airframe deice (currently not simulated)

    # Right bleed air
    if (getprop("controls/electric/circuit-breakers/main/bleed-air-l") and getprop("controls/pneumatic/engine[1]/bleed")) {
        setprop(outPut~"bleed-air-right", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop(outPut~"bleed-air-right", 0);
    }

    # Overspeed govenor
    if (getprop("controls/electric/circuit-breakers/main/over-speed-gov")) {
        setprop(outPut~"overspeed-gov", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"overspeed-gov", 0);
    }

    # Fuel crossfeed valve
    if (getprop("controls/electric/circuit-breakers/main/fuel-xfeed") and getprop("controls/fuel/tank-selector") != 0) {
        setprop(outPut~"fuel-crossfeed", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"fuel-crossfeed", 0);
    }

    # Right landing light
    if (getprop("controls/electric/circuit-breakers/main/ldg-lt-r") and getprop("controls/lighting/landing-light[1]")) {
        setprop(outPut~"landing-light-right", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop(outPut~"landing-light-right", 0);
    }

    # Copilot's instruments, radios and volt/amperemeter lighting
    coplt_rad_va_lts_dimmer = getprop("controls/lighting/coplt-radio-va-pnl-lts");
    if (getprop("controls/electric/circuit-breakers/main/copilot-rad-va-pnl-lt")) {
        var lights = bus_volts * coplt_rad_va_lts_dimmer;
        setprop(outPut~"coplt-radio-va-pnl-lts", lights);
        load += bus_volts / 45;
    } else {
        setprop(outPut~"coplt-radio-va-pnl-lts", 0);
    }

    # Windshield heat
    var condition = (getprop("controls/electric/circuit-breakers/overhead/ws-heat-l") or getprop("controls/electric/circuit-breakers/overhead/ws-heat-r")) and getprop("controls/anti-ice/window-heat");
    if (condition) {
        setprop(outPut~"window-heat", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop(outPut~"window-heat", 0);
    }

    # Right fuel shutoff valve (SOV)
    if (getprop("controls/electric/circuit-breakers/main/fuel-sov-r") and getprop("controls/engines/engine[1]/emerg-cutoff")) {
        setprop(outPut~"fuel-sov-r", bus_volts);
        load += bus_volts / 45;
    } else {
        setprop(outPut~"fuel-sov-r", 0);
    }

    # Fowrard tank low fuel level caution light
    var condition = (getprop("controls/electric/caution-test") or getprop("instrumentation/engine-instruments/fuel-qty-fwd/indicated-fuelqty-lbs")<75) and getprop("controls/electric/circuit-breakers/main/fuel-l-level-fwd");
    if (condition) {
        setprop(outPut~"caution-lights/low-fuel-fwd", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/low-fuel-fwd", 0);
    }

    # Right pitot heat
    if (getprop("controls/electric/circuit-breakers/main/pitot-htr-r") and getprop("controls/anti-ice/pitot-heat")) {
        setprop(outPut~"pitot-heat-right", bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"pitot-heat-right", 0);
    }

    # Copilot's turn coordinator
    if (getprop("controls/electric/circuit-breakers/center/tc2")) {
        setprop(outPut~"turn-coordinator[1]", bus_volts);
        load += bus_volts / 20;
    } else {
        setprop(outPut~"turn-coordinator[1]", 0);
    }

    # Secondary boost pump AFT (Standby boost pumps not yet simulated)
    if (getprop("controls/electric/circuit-breakers/main/bst-pump-aft-2")) {
        setprop(outPut~"boost-pump-secondary-aft", bus_volts);
#        load += bus_volts / 5;
    } else {
        setprop(outPut~"boost-pump-secondary-aft", 0);
    }

    # Secondary boost pump FWD (Standby boost pumps not yet simulated)
    if (getprop("controls/electric/circuit-breakers/main/bst-pump-fwd-2")) {
        setprop(outPut~"boost-pump-secondary-fwd", bus_volts);
#        load += bus_volts / 5;
    } else {
        setprop(outPut~"boost-pump-secondary-fwd", 0);
    }

    # Boost pump pressure caution light: Secondary AFT (Standby boost pumps not yet simulated)
    if (getprop("controls/electric/caution-test") and getprop("controls/electric/circuit-breakers/main/bst-pump-press-r-pos")) {
        setprop(outPut~"caution-lights/boost-pump-secondary-aft-low-press", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/boost-pump-secondary-aft-low-press", 0);
    }

    # Boost pump pressure caution light: Secondary FWD (Standby boost pumps not yet simulated)
    if (getprop("controls/electric/caution-test") and getprop("controls/electric/circuit-breakers/main/bst-pump-press-r-pos")) {
        setprop(outPut~"caution-lights/boost-pump-secondary-fwd-low-press", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/boost-pump-secondary-fwd-low-press", 0);
    }

    # Caution lights dimmer (not implemented)

    # Cabin signs: Fasten seatbelt
    if (getprop("controls/lighting/seat-belt")) {
        setprop(outPut~"seatbelt", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"seatbelt", 0);
    }

    # Cabin signs: No smoking
    if (getprop("controls/lighting/no-smoking")) {
        setprop(outPut~"no-smoking", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"no-smoking", 0);
    }

    # Flightdeck lights
    if (getprop("controls/electric/circuit-breakers/main/flt-comp-lt") and getprop("controls/lighting/flight-comp")) {
        setprop(outPut~"flightcomp-lights", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"flightcomp-lights", 0);
    }

    # Copilot overhead lights
    if (getprop("controls/electric/circuit-breakers/main/flt-comp-lt") and getprop("controls/lighting/overhead-light")) {
        setprop(outPut~"overhead-light", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"overhead-light", 0);
    }

    # C/B panel background lights
    if (getprop("controls/electric/circuit-breakers/main/flt-comp-lt") and getprop("controls/lighting/instrument-lights") == 1) {
        setprop(outPut~"instrument-lights", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"instrument-lights", 0);
    }

    # Right 400 cycle caution light
    var condition = (getprop("controls/electric/caution-test") or (getprop("systems/electrical/outputs/inverter-2")<0.1 and getprop("controls/electric/inverter") == 2)) and getprop("controls/electric/circuit-breakers/main/c400-fail");
    if (condition) {
        setprop(outPut~"caution-lights/r-cycle-400", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/r-cycle-400", 0);
    }

    # Left generator overheat caution light (currently not simulated)
    if (getprop("controls/electric/caution-test")) {
        setprop(outPut~"caution-lights/gen-overheat-left", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/gen-overheat-left", 0);
    }

    # Aileron trim actuator
    if (getprop("controls/electric/circuit-breakers/main/ail-trim-act") and getprop("controls/flight/aileron-trim-actuated") != 0) {
        setprop(outPut~"ail-trim-act", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"ail-trim-act", 0);
    }

    # Aileron trim indicator
    if (getprop("controls/electric/circuit-breakers/main/ail-trim-ind")) {
        setprop(outPut~"ail-trim-ind", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"ail-trim-ind", 0);
    }

    # Left generator caution light
    if ((getprop("controls/electric/caution-test") or (!getprop("controls/electric/engine[0]/generator-active") or getprop("engines/engine[0]/amp-v")<=22 or getprop("engines/engine[0]/amp-v")<getprop("systems/electrical/batt-volts")+0.5) and getprop("controls/engines/internal-engine-starter") != 1) and getprop("controls/electric/circuit-breakers/main/l-gen-fail")) {
        setprop(outPut~"caution-lights/l-gen", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/l-gen", 0);
    }

    # Left intake de-ice (currently not simulated)

    # Beta system (currently not simulated)

    # Flightdeck fans (not yet modeled/implemented)

    # Doors unlocked caution light
    if ((getprop("controls/electric/caution-test") or getprop("controls/doors/Baggage-door/position-norm")>0.01 or getprop("controls/doors/LF-door/position-norm")>0.01 or getprop("controls/doors/LR-door-F/position-norm")>0.01 or getprop("controls/doors/LR-door-R/position-norm")>0.01 or getprop("controls/doors/RF-door/position-norm")>0.01 or getprop("controls/doors/RR-door/position-norm")>0.01) and getprop("controls/electric/circuit-breakers/overhead/doors-unlocked")) {
        setprop(outPut~"caution-lights/doors-unlocked", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/doors-unlocked", 0);
    }

    # Right low oil press caution light
    var condition = (getprop("controls/electric/caution-test") or getprop("engines/engine[1]/oil-pressure-real-psi")<42) and getprop("controls/electric/circuit-breakers/main/oil-low-press-r");
    if (condition) {
        setprop(outPut~"caution-lights/low-oil-press-right", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"caution-lights/low-oil-press-right", 0);
    }

    # Right oil temp gauge
    if (getprop("controls/electric/circuit-breakers/main/oil-temp-r")) {
        setprop(outPut~"oil-temp-right", bus_volts);
        load += bus_volts / 40;
    } else {
        setprop(outPut~"oil-temp-right", 0);
    }

    # Cabin lights
    if (getprop("controls/electric/circuit-breakers/main/flt-comp-lt") and getprop("controls/lighting/cabin-lights")) {
        setprop(outPut~"cabin-lights", bus_volts);
        load += bus_volts / 30;
    } else {
        setprop(outPut~"cabin-lights", 0);
    }

    # Right cabin reading lights (not yet simulated)
    if (getprop("controls/electric/circuit-breakers/overhead/reading") and getprop("controls/electric/circuit-breakers/overhead/cabin-lts") and getprop("controls/lighting/reading")) {
        setprop(outPut~"reading-lights-right", bus_volts);
        load += bus_volts / 25;
    } else {
        setprop(outPut~"reading-lights-right", 0);
    }

    # Avionics:

    # Right audio (not yet simulated)

    # Right COM
    if (getprop("controls/electric/circuit-breakers/center/lh-com1") and getprop("instrumentation/comm[0]/serviceable") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"comm[1]", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"comm[1]", 0);
    }

    # Right NAV
    if (getprop("controls/electric/circuit-breakers/center/lh-nav1") and getprop("instrumentation/nav[0]/serviceable") and getprop("controls/electric/master-avionics")) {
        setprop(outPut~"nav[1]", bus_volts);
        load += bus_volts / 50;
    } else {
        setprop(outPut~"nav[1]", 0);
    }

    # Right ADF (doesn't exist yet)
#    if (getprop("controls/electric/circuit-breakers/center/lh-adf2") and getprop("instrumentation/adf[1]/serviceable") and getprop("controls/electric/master-avionics")) {
#        setprop(outPut~"adf[1]", bus_volts);
#        load += bus_volts / 50;
#    } else {
#        setprop(outPut~"adf[1]", 0);
#    }

    return load;

}

# 26V AC bus
Bus_26V_AC = func(dt) {
    # Recieve power from either the No. 1 or the No. 2 inverter
    if (getprop("systems/electrical/outputs/inverter-1") > 5) {
        setprop("systems/electrical/buses/AC-26V-servicable", 1);
        setprop("systems/electrical/buses/AC-26V-volts", 26);
    } elsif (getprop("systems/electrical/outputs/inverter-2") > 5) {
        setprop("systems/electrical/buses/AC-26V-servicable", 1);
        setprop("systems/electrical/buses/AC-26V-volts", 26);
    } else {
        setprop("systems/electrical/buses/AC-26V-servicable", 0);
        setprop("systems/electrical/buses/AC-26V-volts", 0);
    }

    var bus_volts = getprop("systems/electrical/buses/AC-26V-volts");

    var load = 0.0;

    # Left torque pressure
    setprop(outPut~"torque-left", bus_volts);
    load += bus_volts / 40;

    # Right torque pressure
    setprop(outPut~"torque-right", bus_volts);
    load += bus_volts / 40;

    # Left fuel flow gauge
    setprop(outPut~"fuel-flow-left", bus_volts);
    load += bus_volts / 50;

    # Right fuel flow gauge
    setprop(outPut~"fuel-flow-right", bus_volts);
    load += bus_volts / 50;

    # Left oil pressure gauge
    setprop(outPut~"oil-press-left", bus_volts);
    load += bus_volts / 50;

    # Right oil pressure gauge
    setprop(outPut~"oil-press-right", bus_volts);
    load += bus_volts / 50;

    # Radar altimeter
    if (getprop("controls/electric/circuit-breakers/center/ralt")) {
        setprop(outPut~"radar-alt", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"radar-alt", 0);
    }

    return load;
x
}

# 115V AC bus
Bus_115V_AC = func(dt) {
    # Recieve power from either the No. 1 or the No. 2 inverter
    if (getprop("systems/electrical/outputs/inverter-1") > 5) {
        setprop("systems/electrical/buses/AC-115V-servicable", 1);
        setprop("systems/electrical/buses/AC-115V-volts", 115);
    } elsif (getprop("systems/electrical/outputs/inverter-2") > 5) {
        setprop("systems/electrical/buses/AC-115V-servicable", 1);
        setprop("systems/electrical/buses/AC-115V-volts", 115);
    } else {
        setprop("systems/electrical/buses/AC-115V-servicable", 0);
        setprop("systems/electrical/buses/AC-115V-volts", 0);
    }

    var bus_volts = getprop("systems/electrical/buses/AC-115V-volts");

    var load = 0.0;

    # Left (AFT) fuel quantity
    setprop(outPut~"fuel-qty-aft", bus_volts);
    load += bus_volts / 80;

    # Right (FWD) fuel quantity
    setprop(outPut~"fuel-qty-fwd", bus_volts);
    load += bus_volts / 80;

    # Directional gyro
    if (getprop("controls/electric/circuit-breakers/center/lh-hsi1")) {
        setprop(outPut~"DG", bus_volts);
        load += bus_volts / 60;
    } else {
        setprop(outPut~"DG", 0);
    }

    return load;
}

update_electrical = func {
    var scnd = getprop("sim/time/delta-sec");
    main_bat_bus(scnd);
    bat_extpwr_bus(scnd);
    Left_28V_DC_bus(scnd);
    Right_28V_DC_bus(scnd);
    Bus_26V_AC(scnd);
    Bus_115V_AC(scnd);

    if (!getprop("controls/electric/bus-tie") and getprop("systems/electrical/buses/L-28V-DC-volts") > getprop("engines/engine[1]/amp-v")){
        setprop("systems/electrical/buses/R-28V-DC-volts", getprop("systems/electrical/buses/L-28V-DC-volts"));
    } else {
        setprop("systems/electrical/buses/R-28V-DC-volts", getprop("engines/engine[1]/amp-v"));
    }
    if (getprop("systems/electrical/buses/R-28V-DC-volts")>0.01) {
        setprop("systems/electrical/buses/R-28V-DC-servicable", 1);
    } else {
        setprop("systems/electrical/buses/R-28V-DC-servicable", 0);
    }

settimer(update_electrical, 0);
}
