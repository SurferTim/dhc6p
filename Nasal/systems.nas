####    DHC6 systems    ####
aircraft.livery.init("Aircraft/dhc6p/Models/Liveries");
setprop("controls/armament/station[5]/release-all",1);
setprop("controls/armament/station[6]/release-all",0);
var C_volume = props.globals.initNode("sim/sound/cabin",0.3);
var D_volume = props.globals.initNode("sim/sound/doors",0.7);
var E1_pitch = props.globals.initNode("sim/sound/engine[0]",0.0);
var E2_pitch = props.globals.initNode("sim/sound/engine[1]",0.0);
var E1_volume = props.globals.initNode("sim/sound/enginevol[0]",0.5);
var E2_volume = props.globals.initNode("sim/sound/enginevol[1]",0.5);

# SurferTim
var T1_pitch = props.globals.initNode("sim/sound/turbine[0]",0.0);
var T2_pitch = props.globals.initNode("sim/sound/turbine[1]",0.0);
var T1_volume = props.globals.initNode("sim/sound/turbinevol[0]",0.5);
var T2_volume = props.globals.initNode("sim/sound/turbinevol[1]",0.5);

var stall_volume = props.globals.initNode("sim/sound/stall-warning",0.0);
var hyd_pump_volume = props.globals.initNode("sim/sound/hyd-pump",0.0);
var ctn_counter=0;
var FDM ="";
Wiper=[];
props.globals.initNode("/controls/engines/engine[0]/condition", 0.0, "DOUBLE");
props.globals.initNode("/controls/engines/engine[1]/condition", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-sov-l", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-sov-r", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/torque-left", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/torque-right", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-flow-left", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-flow-right", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/oil-temp-left", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/oil-temp-right", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/oil-press-left", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/oil-press-right", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-qty-aft", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/fuel-qty-fwd", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/radar-alt", 0.0, "DOUBLE");
props.globals.initNode("/systems/electrical/outputs/va", 0.0, "DOUBLE");
props.globals.initNode("/engines/engine[0]/oil-temp-degc", 0.0, "DOUBLE");
props.globals.initNode("/engines/engine[1]/oil-temp-degc", 0.0, "DOUBLE");
props.globals.initNode("/instrumentation/engine-instruments/t5[0]/indicated-t5-degc", 0.0, "DOUBLE");
props.globals.initNode("/instrumentation/engine-instruments/t5[1]/indicated-t5-degc", 0.0, "DOUBLE");

var mousex =0;
var msx = 0;
var msxa = 0;
var mousey = 0;
var msy = 0;
var msya=0;
var lever_scale = getprop("controls/movement-scale");

var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);

### Set initial custom property ###
props.globals.initNode("controls/electric/aft-boost-pump", 0);
props.globals.initNode("controls/electric/fwd-boost-pump", 0);
props.globals.initNode("controls/engines/engine[0]/condition", 0.0);
props.globals.initNode("controls/engines/engine[1]/condition", 0.0);
props.globals.initNode("controls/engines/internal-engine-starter", 0.0);
props.globals.initNode("controls/electric/power-source",0);
props.globals.initNode("controls/switches/dme", 0);
props.globals.initNode("controls/switches/dme-gps-slave", 0);
props.globals.initNode("autopilot/internal/pitch-filter-gain",0.0,"DOUBLE");

###################################

controls.removeTiedowns = func{
    setprop("sim/model/equipment/left-pitot-cover",0);
    setprop("sim/model/equipment/right-pitot-cover",0);
    setprop("sim/model/equipment/left-tiedown-wheels",0);
    setprop("sim/model/equipment/right-tiedown-wheels",0);
    setprop("sim/model/equipment/rear-tiedown-wheels",0);
    setprop("sim/model/equipment/left-engine-cover",0);
    setprop("sim/model/equipment/right-engine-cover",0);
    setprop("sim/model/equipment/left-chock-fwd",0);
    setprop("sim/model/equipment/left-chock-aft",0);
    setprop("sim/model/equipment/right-chock-fwd",0);
    setprop("sim/model/equipment/right-chock-aft",0);
    setprop("sim/model/equipment/ground-services/external-power/enable",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/clean",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/transfer",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-aft",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-fwd",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/disconnect",1);
    setprop("sim/model/equipment/ground-services/fuel-truck/enable",0);
}


var Startup_yasim = func{
    setprop("sim/model/equipment/left-pitot-cover",0);
    setprop("sim/model/equipment/right-pitot-cover",0);
    setprop("sim/model/equipment/left-tiedown-wheels",0);
    setprop("sim/model/equipment/right-tiedown-wheels",0);
    setprop("sim/model/equipment/rear-tiedown-wheels",0);
    setprop("sim/model/equipment/left-engine-cover",0);
    setprop("sim/model/equipment/right-engine-cover",0);
    setprop("sim/model/equipment/left-chock-fwd",0);
    setprop("sim/model/equipment/left-chock-aft",0);
    setprop("sim/model/equipment/right-chock-fwd",0);
    setprop("sim/model/equipment/right-chock-aft",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/clean",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/transfer",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-aft",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-fwd",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/disconnect",1);
    setprop("sim/model/equipment/ground-services/fuel-truck/enable",0);
    setprop("controls/electric/dc-master",1);

    if (getprop("sim/aircraft") == "dhc6F") {
        setprop("sim/model/equipment/ground-services/external-power/enable",0);
        setprop("controls/electric/power-source",1);
    } else {
        setprop("sim/model/equipment/ground-services/external-power/enable",1);
        setprop("controls/electric/power-source",-1);
    }

    if (getprop("controls/electric/inverter") == 1) {
        setprop("controls/electric/inverter", 2);
    } else {
        setprop("controls/electric/inverter", 1);
    }


    setprop("controls/electric/master-avionics",0);
    setprop("controls/electric/ammeter-switch",0);
    setprop("controls/lighting/instrument-lights",1);
    setprop("controls/lighting/flight-comp",1);
    setprop("controls/lighting/cabin-lights",1);
    setprop("controls/lighting/beacon",1);
    setprop("controls/electric/aft-boost-pump",1);
    setprop("controls/electric/fwd-boost-pump",1);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("controls/engines/engine[0]/ignition",1);
    setprop("controls/engines/engine[1]/ignition",1);
    setprop("controls/engines/engine[0]/intake-deflector",1.00);
    setprop("controls/engines/engine[1]/intake-deflector",1.00);
    setprop("controls/engines/internal-engine-starter",1);
    setprop("controls/engines/engine[0]/throttle",0);
    setprop("controls/engines/engine[1]/throttle",0);
    setprop("controls/anti-ice/pitot-heat",1);
    setprop("controls/anti-ice/prop-heat",1);
    setprop("controls/anti-ice/window-heat",1);

    screen.log.write("Starting the engines. Please wait...", 1, 1, 1);
    
    var check_loop1 = func {
    
        if (getprop("controls/engines/internal-engine-starter") != 0) {
    
        if (getprop("engines/engine[0]/running") == 0 and getprop("engines/engine[1]/running") == 0) {
        }

        if (getprop("engines/engine[0]/n2") > 12.0) {
            setprop("controls/engines/engine[0]/condition",1);
            setprop("controls/engines/engine[0]/mixture",1);

        }

        if (getprop("engines/engine[0]/running") == 1 and getprop("engines/engine[1]/running") == 0) {
        setprop("controls/engines/internal-engine-starter",-1);
        }
        if (getprop("engines/engine[1]/n2") > 12.0) {
            setprop("controls/engines/engine[1]/condition",1);
            setprop("controls/engines/engine[1]/mixture",1);

        }
        if (getprop("engines/engine[0]/running") == 1 and getprop("engines/engine[1]/running") == 1 and getprop("engines/engine[1]/rpm") > 200) {
            setprop("controls/engines/internal-engine-starter",0);
            setprop("controls/electric/ammeter-switch",1);
            setprop("controls/electric/power-source",1);
            setprop("controls/electric/master-avionics",1);
            setprop("controls/engines/engine[0]/propeller-pitch",1);
            setprop("controls/engines/engine[1]/propeller-pitch",1);
            setprop("controls/lighting/no-smoking",1);
            setprop("controls/lighting/seat-belt",1);
            setprop("controls/electric/engine[0]/generator-active",1);
            setprop("controls/electric/engine[1]/generator-active",1);

# SurferTim changed
#            setprop("controls/lighting/landing-light[0]",1);
#            setprop("controls/lighting/landing-light[1]",1);

            setprop("controls/lighting/nav-lights",1);
            setprop("controls/lighting/strobe",1);
            setprop("controls/engines/auto-feather",1);
            setprop("controls/flight/flaplever",0.25);
            setprop("controls/flight/flaps",0.25);

# SurferTim changed
            setprop("controls/gear/parkingbrake-lever",1);
            setprop("instrumentation/garmin196/light",0.2);
            setprop("instrumentation/adf/ident-audible",1);

            setprop("controls/flight/elevator-trim",-0.2);
            setprop("controls/flight/rudder-trim",0.12);
            setprop("controls/pneumatic/engine[0]/bleed", 1);
            setprop("controls/pneumatic/engine[1]/bleed", 1);

            setprop("sim/model/equipment/ground-services/external-power/enable",0);
            screen.log.write("Startup procedure finished", 1, 1, 1);
            print("YASIM Startup complete");
        }
        settimer(check_loop1, 0.1);
        }
    }
    check_loop1();
}

var Startup_jsb = func{
    setprop("controls/engines/auto-feather",0);
    setprop("sim/model/equipment/left-pitot-cover",0);
    setprop("sim/model/equipment/right-pitot-cover",0);
    setprop("sim/model/equipment/left-tiedown-wheels",0);
    setprop("sim/model/equipment/right-tiedown-wheels",0);
    setprop("sim/model/equipment/rear-tiedown-wheels",0);
    setprop("sim/model/equipment/left-engine-cover",0);
    setprop("sim/model/equipment/right-engine-cover",0);
    setprop("sim/model/equipment/left-chock-fwd",0);
    setprop("sim/model/equipment/left-chock-aft",0);
    setprop("sim/model/equipment/right-chock-fwd",0);
    setprop("sim/model/equipment/right-chock-aft",0);
    setprop("sim/model/equipment/ground-services/external-power/enable",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/clean",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/transfer",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-aft",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/connect-fwd",0);
    setprop("sim/model/equipment/ground-services/fuel-truck/disconnect",1);
    setprop("sim/model/equipment/ground-services/fuel-truck/enable",0);
    setprop("controls/electric/master-avionics",1);
    setprop("controls/electric/battery-switch",1);
    setprop("controls/electric/dc-master",1);
    setprop("controls/electric/power-source",1);
    setprop("controls/electric/ammeter-switch",0);
    if (getprop("controls/electric/inverter") == 1) {
        setprop("controls/electric/inverter", 2);
    } else {
        setprop("controls/electric/inverter", 1);
    }
    setprop("controls/lighting/instrument-lights",1);
    setprop("controls/lighting/flight-comp",1);
    setprop("controls/lighting/cabin-lights",1);
    setprop("controls/lighting/beacon",1);
    setprop("controls/electric/aft-boost-pump",1);
    setprop("controls/electric/fwd-boost-pump",1);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("controls/engines/engine[0]/intake-deflector",1);
    setprop("controls/engines/engine[1]/intake-deflector",1);
    setprop("controls/engines/internal-engine-starter",0);
    setprop("controls/engines/engine[0]/throttle",0);
    setprop("controls/engines/engine[1]/throttle",0);
    setprop("controls/engines/auto-feather",1);
    setprop("engines/engine[0]/running",1);
    setprop("engines/engine[1]/running",1);
    setprop("controls/anti-ice/pitot-heat",1);
    setprop("controls/anti-ice/prop-heat",1);
    setprop("controls/anti-ice/window-heat",1);
    setprop("controls/engines/internal-engine-starter",0);
    setprop("controls/electric/ammeter-switch",1);
    setprop("controls/electric/power-source",1);
    setprop("controls/lighting/no-smoking",1);
    setprop("controls/lighting/seat-belt",1);
    setprop("controls/electric/engine[0]/generator-active",1);
    setprop("controls/electric/engine[1]/generator-active",1);
    setprop("controls/lighting/landing-light[0]",1);
    setprop("controls/lighting/landing-light[1]",1);
    setprop("controls/lighting/nav-lights",1);
    setprop("controls/lighting/strobe",1);
    setprop("controls/flight/flaplever",0.25);
    setprop("controls/flight/flaps",0.25);
    setprop("controls/gear/parkingbrake-lever",0);
    setprop("controls/flight/elevator-trim",-0.2);
    setprop("controls/flight/rudder-trim",0.12);
    setprop("controls/engines/engine[0]/condition",1);
    setprop("controls/engines/engine[0]/mixture",1);
    setprop("controls/engines/engine[1]/condition",1);
    setprop("controls/engines/engine[1]/mixture",1);
    setprop("fdm/jsbsim/propulsion/engine/n1",55);
    setprop("fdm/jsbsim/propulsion/engine[1]/n1",55);
    setprop("controls/engines/engine[0]/propeller-feather",0);
    setprop("controls/engines/engine[1]/propeller-feather",0);
    setprop("controls/engines/engine[0]/propeller-pitch",1);
    setprop("controls/engines/engine[1]/propeller-pitch",1);
    setprop("controls/pneumatic/engine[0]/bleed", 1);
    setprop("controls/pneumatic/engine[1]/bleed", 1);
    print("Startup complete");
};

var Shutdown = func{
    setprop("controls/electric/engine[0]/generator",0);
    setprop("controls/electric/engine[1]/generator",0);
    setprop("controls/pneumatic/engine[0]/bleed", 0);
    setprop("controls/pneumatic/engine[1]/bleed", 0);
    setprop("controls/electric/master-avionics",0);
    setprop("controls/electric/dc-master",0);
    setprop("controls/lighting/instrument-lights",0);
    setprop("controls/lighting/nav-lights",0);
    setprop("controls/lighting/beacon",0);
    setprop("controls/lighting/strobe",0);
    setprop("controls/lighting/flight-comp",0);
    setprop("controls/engines/engine[0]/throttle",0);
    setprop("controls/engines/engine[1]/throttle",0);
    setprop("controls/engines/engine[0]/mixture",0);
    setprop("controls/engines/engine[1]/mixture",0);
    setprop("controls/engines/engine[0]/propeller-pitch",0);
    setprop("controls/engines/engine[1]/propeller-pitch",0);
    setprop("controls/engines/engine[0]/condition",0);
    setprop("controls/engines/engine[1]/condition",0);
    setprop("controls/engines/engine[0]/internal-condition",0);
    setprop("controls/engines/engine[1]/internal-condition",0);
    setprop("controls/engines/engine[0]/ignition",0);
    setprop("controls/engines/engine[1]/ignition",0);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("engines/engine[0]/running",0);
    setprop("engines/engine[1]/running",0);
    setprop("controls/electric/aft-boost-pump",0);
    setprop("controls/electric/fwd-boost-pump",0);
    setprop("controls/electric/power-source",0);
    setprop("controls/engines/internal-engine-starter",0);
    setprop("controls/lighting/landing-light[0]",0);
    setprop("controls/lighting/landing-light[1]",0);
    setprop("controls/flight/flaplever",0);
    setprop("controls/flight/flaps",0);
    setprop("controls/gear/parkingbrake-lever",1);
    setprop("controls/engines/engine[0]/intake-deflector",0.00);
    setprop("controls/engines/engine[1]/intake-deflector",0.00);
    setprop("controls/lighting/flightcomp-lights",0);
    setprop("controls/lighting/cabin-lights",0);
    setprop("controls/lighting/no-smoking",0);
    setprop("controls/lighting/seat-belt",0);
    setprop("controls/anti-ice/pitot-heat",0);
    setprop("controls/anti-ice/prop-heat",0);
    setprop("controls/anti-ice/window-heat",0);
    setprop("controls/flight/elevator-trim",-0.2);
    setprop("controls/flight/rudder-trim",0.12);
    setprop("sim/model/equipment/left-pitot-cover",1);
    setprop("sim/model/equipment/right-pitot-cover",1);
    setprop("sim/model/equipment/left-tiedown-wheels",1);
    setprop("sim/model/equipment/right-tiedown-wheels",1);
    setprop("sim/model/equipment/rear-tiedown-wheels",1);
    setprop("sim/model/equipment/left-engine-cover",1);
    setprop("sim/model/equipment/right-engine-cover",1);
    setprop("sim/model/equipment/left-chock-fwd",1);
    setprop("sim/model/equipment/left-chock-aft",1);
    setprop("sim/model/equipment/right-chock-fwd",1);
    setprop("sim/model/equipment/right-chock-aft",1);
    setprop("sim/model/equipment/ground-services/external-power/enable",1);
}

var Wiper = {
    new : func (wiper_prop,power_prop){
        m = { parents : [Wiper] };
        m.direction = 0;
        m.delay_count = 0;
        m.spd_factor = 0;
        m.node = props.globals.initNode(wiper_prop);
        m.power = props.globals.initNode(power_prop,0.0,"DOUBLE");
        m.spd = m.node.initNode("arc-sec",1.0,"DOUBLE");
        m.delay = m.node.initNode("delay-sec",0.0,"DOUBLE");
        m.position = m.node.initNode("position-norm",0.0,"DOUBLE");
        m.switch = m.node.initNode("switch",0,"BOOL");
        return m;
    },
    active: func{
    if(me.power.getValue()<=5)return;
    var spd_factor = 1/me.spd.getValue();
    var pos = me.position.getValue();
    if(!me.switch.getValue()){
        if(pos <= 0.000)return;
        }
    if(pos >=1.000){
        me.direction=-1;
        }elsif(pos <=0.000){
        me.direction=0;
        me.delay_count+=getprop("/sim/time/delta-sec");
        if(me.delay_count >= me.delay.getValue()){
            me.delay_count=0;
            me.direction=1;
            }
        }
    var wiper_time = spd_factor*getprop("/sim/time/delta-sec");
    pos +=(wiper_time * me.direction);
    me.position.setValue(pos);
    }
};

var Caution_panel = {
    new : func (prop){
        m = { parents : [Caution_panel] };
        m.count=0;
        m.volts=0;
        m.caution_test=0;
        m.node = props.globals.initNode(prop);
        m.test = props.globals.initNode("controls/electric/caution-test");
        m.power = props.globals.initNode("systems/electrical/volts");
        
        m.l_gen_oheat=m.node.initNode("gen-oheat[0]",0,"BOOL");
        m.r_gen_oheat=m.node.initNode("gen-oheat[1]",0,"BOOL");
        m.l_gen=m.node.initNode("gen[0]",0,"BOOL");
        m.r_gen=m.node.initNode("gen[1]",0,"BOOL");
        m.l_oil_psi=m.node.initNode("oil[0]",0,"BOOL");
        m.r_oil_psi=m.node.initNode("oil[1]",0,"BOOL");
        m.l_cycle400=m.node.initNode("cycle400[0]",0,"BOOL");
        m.r_cycle400=m.node.initNode("cycle400[1]",0,"BOOL");
        m.low_press=m.node.initNode("low-press",0,"BOOL");
        m.prop_reset=m.node.initNode("prop-reset",0,"BOOL");
        m.fwd_fuel=m.node.initNode("low-fuel[0]",0,"BOOL");
        m.aft_fuel=m.node.initNode("low-fuel[1]",0,"BOOL");
        m.fwd_boost1=m.node.initNode("fwd-boost[0]",0,"BOOL");
        m.fwd_boost2=m.node.initNode("fwd-boost[1]",0,"BOOL");
        m.aft_boost1=m.node.initNode("aft-boost[0]",0,"BOOL");
        m.aft_boost2=m.node.initNode("aft-boost[1]",0,"BOOL");
        m.doors=m.node.initNode("doors",0,"BOOL");
        m.duct=m.node.initNode("duct-oheat",0,"BOOL");
        return m;
    },
    update: func{

        if(me.power.getValue()>5.0 and getprop("controls/electric/dc-master")==1 and getprop("controls/electric/power-source")!=0)me.volts=1 else me.volts=0;
        if(me.test.getValue()>5.0)me.caution_test=1 else me.caution_test=0;
        if(me.volts == 0){me.reset();return;} 
        if(me.caution_test == 1){me.lamp_test();return;}
        
        if(me.count==0)me.left_bank() else me.right_bank();
    },

    left_bank: func{
        # Left column
        if(getprop("systems/electrical/outputs/caution-lights/gen-overheat-left")>0.1)me.l_gen_oheat.setValue(me.volts) else me.l_gen_oheat.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/l-gen")>0.1)me.l_gen.setValue(me.volts) else me.l_gen.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/low-oil-press-left")>0.1)me.l_oil_psi.setValue(me.volts) else me.l_oil_psi.setValue(0);
        # Center column
        if(getprop("systems/electrical/outputs/caution-lights/low-fuel-fwd")>0.1)me.fwd_fuel.setValue(me.volts) else me.fwd_fuel.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/boost-pump-main-fwd-low-press")>0.1)me.fwd_boost1.setValue(me.volts) else me.fwd_boost1.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/boost-pump-main-aft-low-press")>0.1)me.aft_boost1.setValue(me.volts) else me.aft_boost1.setValue(0);
        # Right column
        if(getprop("systems/electrical/outputs/caution-lights/l-cycle-400")>0.1)me.l_cycle400.setValue(me.volts) else me.l_cycle400.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/doors-unlocked")>0.1)me.doors.setValue(me.volts) else me.doors.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/duct-overheat")>0.1)me.duct.setValue(me.volts) else me.duct.setValue(0);

        me.count=1-me.count;
    },

    right_bank: func{
        # Left column
        if(getprop("systems/electrical/outputs/caution-lights/r-cycle-400")>0.1)me.r_cycle400.setValue(me.volts) else me.r_cycle400.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/low-press")>0.1)me.low_press.setValue(me.volts) else me.low_press.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/reset-props")>0.1)me.prop_reset.setValue(me.volts) else me.prop_reset.setValue(0);
        # Center column
        if(getprop("systems/electrical/outputs/caution-lights/low-fuel-aft")>0.1)me.aft_fuel.setValue(me.volts) else me.aft_fuel.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/boost-pump-secondary-fwd-low-press")>0.1)me.fwd_boost2.setValue(me.volts) else me.fwd_boost2.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/boost-pump-secondary-aft-low-press")>0.1)me.aft_boost2.setValue(me.volts) else me.aft_boost2.setValue(0);
        # Right column
        if(getprop("systems/electrical/outputs/caution-lights/gen-overheat-right")>0.1)me.r_gen_oheat.setValue(me.volts) else me.r_gen_oheat.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/r-gen")>0.1)me.r_gen.setValue(me.volts) else me.r_gen.setValue(0);
        if(getprop("systems/electrical/outputs/caution-lights/low-oil-press-right")>0.1)me.r_oil_psi.setValue(me.volts) else me.r_oil_psi.setValue(0);
        
        me.count=1-me.count;
    },

    reset: func{
        me.l_gen_oheat.setValue(0);
        me.r_gen_oheat.setValue(0);
        me.l_gen.setValue(0);
        me.r_gen.setValue(0);
        me.l_oil_psi.setValue(0);
        me.r_oil_psi.setValue(0);
        me.l_cycle400.setValue(0);
        me.r_cycle400.setValue(0);
        me.low_press.setValue(0);
        me.prop_reset.setValue(0);
        me.fwd_fuel.setValue(0);
        me.aft_fuel.setValue(0);
        me.fwd_boost1.setValue(0);
        me.fwd_boost2.setValue(0);
        me.aft_boost1.setValue(0);
        me.aft_boost2.setValue(0);
        me.doors.setValue(0);
        me.duct.setValue(0);
    },
    lamp_test: func{
#        me.l_gen_oheat.setValue(me.caution_test);
#        me.r_gen_oheat.setValue(me.caution_test);
#        me.l_gen.setValue(me.caution_test);
#        me.r_gen.setValue(me.caution_test);
#        me.l_oil_psi.setValue(me.caution_test);
#        me.r_oil_psi.setValue(me.caution_test);
#        me.l_cycle400.setValue(me.c400_caution_test);
#        me.r_cycle400.setValue(me.c400_caution_test);
#        me.low_press.setValue(me.caution_test);
#        me.prop_reset.setValue(me.caution_test);
#        me.fwd_fuel.setValue(me.caution_test);
#        me.aft_fuel.setValue(me.caution_test);
#        me.fwd_boost1.setValue(me.caution_test);
#        me.fwd_boost2.setValue(me.caution_test);
#        me.aft_boost1.setValue(me.caution_test);
#        me.aft_boost2.setValue(me.caution_test);
#        me.doors.setValue(me.caution_test);
#        me.duct.setValue(me.caution_test);
    }
};

    var wiper = Wiper.new("controls/electric/wipers","systems/electrical/outputs/wipers");

    var Ctn_panel=Caution_panel.new("instrumentation/caution-panel");

setlistener("/sim/signals/fdm-initialized", func {
    FDM=getprop("sim/flight-model");
    setprop("instrumentation/clock/flight-meter-hour",0);
    print("Systems ... Check!");
    Shutdown();
    settimer(update_systems, 1.1);
    settimer(annunciators, 1.2);
});


setlistener("/sim/signals/reinit", func {
    Shutdown();
});

setlistener("controls/fuel/tank-selector-pos", func(tk){
var pwr = getprop("systems/electrical/outputs/fuel-crossfeed") > 8;
var tnk = tk.getValue();
if(pwr and tnk < -0.8){
        setprop("consumables/fuel/tank[0]/selected",0);
        setprop("consumables/fuel/tank[1]/selected",1);
    }elsif(pwr and tnk > 0.8){
        setprop("consumables/fuel/tank[0]/selected",1);
        setprop("consumables/fuel/tank[1]/selected",0);
    }elsif(!pwr){
        setprop("consumables/fuel/tank[0]/selected",1);
        setprop("consumables/fuel/tank[1]/selected",1);
    }
});

setlistener("/sim/model/autostart-yasim", func(idle) {
    if (idle.getBoolValue()) {
        print("Startup...");
        Startup_yasim();
    } else {
        print("Shutdown");
        Shutdown();
    }
},0,0);

setlistener("/sim/model/autostart-jsb", func(idle) {
    if (idle.getBoolValue()) {
        print("Startup...");
        Startup_jsb();
    } else {
        print("Shutdown");
        Shutdown();
    }
},0,0);

setlistener("controls/engines/engine[0]/cutoff", func(c1){
    setprop("controls/engines/engine[0]/internal-condition",1-c1.getValue());
},0,0);

setlistener("controls/engines/engine[1]/cutoff", func(c1){
    setprop("controls/engines/engine[1]/internal-condition",1-c1.getValue());
},0,0);

setlistener("/gear/gear[1]/wow", func(gr){
    if(gr.getBoolValue()){
    FHmeter.stop();
    }else{FHmeter.start();}
},0,0);

var flight_meter = func{
var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
var fminute = fmeter * 0.016666;
var fhour = fminute * 0.016666;
setprop("/instrumentation/clock/flight-meter-hour",fhour);
}

##### Main ###########

var update_engines = func {
    var FDM ="";
    FDM=getprop("sim/flight-model");

    if (FDM == "yasim") {
        return;
    }

    setprop("engines/engine[0]/rpm", getprop("engines/engine[0]/thruster/rpm"));
    setprop("engines/engine[1]/rpm", getprop("engines/engine[1]/thruster/rpm"));

    if (FDM == "jsb") {
        setprop("engines/engine[0]/generator-rpm", getprop("engines/engine[0]/n1"));
        setprop("engines/engine[1]/generator-rpm", getprop("engines/engine[1]/n1"));
        setprop("engines/engine[0]/turbine-rpm", getprop("engines/engine[0]/n1"));
        setprop("engines/engine[1]/turbine-rpm", getprop("engines/engine[1]/n1"));
    } else {
        setprop("engines/engine[0]/generator-rpm", getprop("engines/engine[0]/n2"));
        setprop("engines/engine[1]/generator-rpm", getprop("engines/engine[1]/n2"));
        setprop("engines/engine[0]/turbine-rpm", getprop("engines/engine[0]/n2"));
        setprop("engines/engine[1]/turbine-rpm", getprop("engines/engine[1]/n2"));
    }

    # Oil temp
    if (FDM == "jsb") return;
    setprop("engines/engine[0]/oil-temp-degc", getprop("instrumentation/engine-instruments/t5[0]/indicated-t5-degc"));
    setprop("engines/engine[1]/oil-temp-degc", getprop("instrumentation/engine-instruments/t5[1]/indicated-t5-degc"));

}

var annunciators = func {
    Ctn_panel.update();
    settimer(annunciators, 0.5);
}

var update_eng_sound = func {
    var tsv1 = getprop("instrumentation/engine-instruments/turbine[0]/indicated-speed");
    var tsv2 = getprop("instrumentation/engine-instruments/turbine[1]/indicated-speed");
    tsv1 *= 0.01;
    tsv2 *= 0.01;

    var tsvt1 = tsv1 * tsv1 + 0.25;
    var tsvt2 = tsv2 * tsv2 + 0.25;

# SurferTim changed
    var tst1 = (getprop("instrumentation/engine-instruments/propeller/indicated-rpm") * 0.0004);
    var tst2 = (getprop("instrumentation/engine-instruments/propeller[1]/indicated-rpm") * 0.0004);

    tst1+=getprop("engines/engine[0]/reverse") * 0.3;
    tst2+=getprop("engines/engine[1]/reverse") * 0.3;
    tsv1+=getprop("engines/engine[0]/reverse") * 0.3;
    tsv2+=getprop("engines/engine[1]/reverse") * 0.3;

    if(tst1 > 1.0) tst1 = 1.0;
    if(tst2 > 1.0) tst2 = 1.0;
    if(tsv1 > 1.0) tsv1 = 1.0;
    if(tsv2 > 1.0) tsv2 = 1.0;

    E1_pitch.setValue(tst1);
    E2_pitch.setValue(tst2);
    E1_volume.setValue(tsvt1);
    E2_volume.setValue(tsvt2);
    T1_pitch.setValue(tsv1);
    T2_pitch.setValue(tsv2);
    T1_volume.setValue(tsvt1);
    T2_volume.setValue(tsvt2);
}

var update_stall_sound = func {
    if (getprop("controls/electric/caution-test")) {
        interpolate("sim/sound/stall-warning", 10, 0.5);
    } else {
    var stall = (getprop("orientation/alpha-deg"));
    stall_volume.setValue(stall);
    }
}

var update_hyd_pump_sound = func {
    var pressure = (getprop("systems/hydraulic/indicated-pressure"));
    hyd_pump_volume.setValue(pressure);
}

var update_throttles = func {
    var LHrvr=getprop("controls/engines/engine[0]/reverser");
    var RHrvr=getprop("controls/engines/engine[1]/reverser");
    var THR1 =getprop("controls/engines/engine[0]/throttle");
    var THR2 =getprop("controls/engines/engine[1]/throttle");
    var running1 = getprop("engines/engine[0]/running");
    var running2 = getprop("engines/engine[1]/running");
    if(LHrvr==1 and running1==0) {
        setprop("controls/engines/engine[0]/throttle-rvrs-norunning",THR1);
    } else if (LHrvr==1 and running1==1) {
        setprop("controls/engines/engine[0]/throttle-rvrs",THR1);
    } else {
        setprop("controls/engines/engine[0]/throttle-fwd",THR1);
    }

    if(RHrvr==1 and running2==0) {
        setprop("controls/engines/engine[1]/throttle-rvrs-norunning",THR2);
    } else if (RHrvr==1 and running2==1) {
        setprop("controls/engines/engine[1]/throttle-rvrs",THR2);
    } else {
        setprop("controls/engines/engine[1]/throttle-fwd",THR2);
    }

}

var update_instruments = func {

    # Some engine gauges (torque, fuel flow, oil temp, oil press, fuel quantity) need electrical power to work
    # Left torque
    if (getprop("systems/electrical/outputs/torque-left") > 1) {
        setprop("instrumentation/engine-instruments/torque[0]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/torque[0]/serviceable", 0);
    }

    # Right torque
    if (getprop("systems/electrical/outputs/torque-right") > 1) {
        setprop("instrumentation/engine-instruments/torque[1]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/torque[1]/serviceable", 0);
    }

    # Left fuel flow
    if (getprop("systems/electrical/outputs/fuel-flow-left") > 1) {
        setprop("instrumentation/engine-instruments/fuel-flow[0]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/fuel-flow[0]/serviceable", 0);
    }

    # Right fuel flow
    if (getprop("systems/electrical/outputs/fuel-flow-right") > 1) {
        setprop("instrumentation/engine-instruments/fuel-flow[1]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/fuel-flow[1]/serviceable", 0);
    }

    # Left oil temp
    if (getprop("systems/electrical/outputs/oil-temp-left") > 1) {
        setprop("instrumentation/engine-instruments/oil-temp[0]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/oil-temp[0]/serviceable", 0);
    }

    # Right oil temp
    if (getprop("systems/electrical/outputs/oil-temp-right") > 1) {
        setprop("instrumentation/engine-instruments/oil-temp[1]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/oil-temp[1]/serviceable", 0);
    }

    # Left oil press
    if (getprop("systems/electrical/outputs/oil-press-left") > 1) {
        setprop("instrumentation/engine-instruments/oil-press[0]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/oil-press[0]/serviceable", 0);
    }

    # Right oil press
    if (getprop("systems/electrical/outputs/oil-press-right") > 1) {
        setprop("instrumentation/engine-instruments/oil-press[1]/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/oil-press[1]/serviceable", 0);
    }

    # Left (AFT) fuel quantity
    if (getprop("systems/electrical/outputs/fuel-qty-aft") > 1) {
        setprop("instrumentation/engine-instruments/fuel-qty-aft/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/fuel-qty-aft/serviceable", 0);
    }

    # Right (FWD) fuel quantity
    if (getprop("systems/electrical/outputs/fuel-qty-fwd") > 1) {
        setprop("instrumentation/engine-instruments/fuel-qty-fwd/serviceable", 1);
    } else {
        setprop("instrumentation/engine-instruments/fuel-qty-fwd/serviceable", 0);
    }

    # Radar altimeter
    if (getprop("systems/electrical/outputs/radar-alt") > 1) {
        setprop("instrumentation/radar-altimeter/serviceable", 1);
    } else {
        setprop("instrumentation/radar-altimeter/serviceable", 0);
    }

    # Volt-/Amperemeter
    if (getprop("systems/electrical/outputs/va") > 1) {
        setprop("instrumentation/volt-amp-meter/serviceable", 1);
    } else {
        setprop("instrumentation/volt-amp-meter/serviceable", 0);
    }
}

var update_systems = func {
    var lfdoor_pos = getprop("controls/doors/LF-door/position-norm");
    var rfdoor_pos = getprop("controls/doors/RF-door/position-norm");
    var rrdoor_pos = getprop("controls/doors/RR-door/position-norm");
    var lrdoorf_pos = getprop("controls/doors/LR-door-F/position-norm");
    var lrdoorr_pos = getprop("controls/doors/LR-door-R/position-norm");
    var baggdoor_pos = getprop("controls/doors/Baggage-door/position-norm");
    var power = getprop("/controls/switches/master-panel");
    var FDM="";
    FDM=getprop("sim/flight-model");
    flight_meter();
    wiper.active();
    var wind = getprop("velocities/airspeed-kt");
    if(wind>40){
        if(getprop("controls/doors/LF-door/position-norm") > 0.01)setprop("controls/doors/LF-door/position-norm",0);
        if(getprop("controls/doors/RF-door/position-norm") > 0.01)setprop("controls/doors/RF-door/position-norm",0);
        if(getprop("controls/doors/LR-door-F/position-norm") > 0.01)setprop("controls/doors/LR-door-F/position-norm",0);
        if(getprop("controls/doors/LR-door-R/position-norm") > 0.01)setprop("controls/doors/LR-door-R/position-norm",0);
        if(getprop("controls/doors/RR-door/position-norm") > 0.01)setprop("controls/doors/RR-door/position-norm",0);
        if(getprop("controls/doors/Baggage-door/position-norm") > 0.01)setprop("controls/doors/Baggage-door/position-norm",0);
    }

    # Flap operation requires hydraulic pressure to be more than 1200 psi
    if(getprop("systems/hydraulic/indicated-pressure")<1200)setprop("controls/flight/flaps-serviceable", 0);
    if(getprop("systems/hydraulic/indicated-pressure")>1200)setprop("controls/flight/flaps-serviceable", 1);
    # 1000 is only an estimated value
    if(getprop("controls/flight/flaps-serviceable"))setprop("controls/flight/flaps", getprop("controls/flight/flaplever"));

    # Cutoff fuel when condition levers are below 0.01 or fuel emergency switches are off or fuel pressure is below 5 psi
    var fuel_select = getprop("controls/fuel/tank-selector");
    var tank0_select = getprop("consumables/fuel/tank[0]/selected");
    var tank1_select = getprop("consumables/fuel/tank[1]/selected");
    var bstpump0 = getprop("consumables/fuel/tank[0]/boost-pump-main-fwd-psi");
    var bstpump1 = getprop("consumables/fuel/tank[1]/boost-pump-main-aft-psi");
    var eng_cover0 = getprop("sim/model/equipment/left-engine-cover");
    var eng_cover1 = getprop("sim/model/equipment/right-engine-cover");
    # Left engine:
    if (getprop("controls/engines/engine[0]/condition") < 0.01 or eng_cover0==1 or getprop("systems/electrical/outputs/fuel-sov-l")>1 or ((fuel_select==-1 and tank1_select==1 and bstpump1<5) or (fuel_select==0 and bstpump1<5) or (fuel_select==1 and tank0_select==1 and bstpump0<5))) {
        setprop("controls/engines/engine[0]/cutoff", 1);
    } else {
        setprop("controls/engines/engine[0]/cutoff", 0);
    }
    # Right engine:
    if (getprop("controls/engines/engine[1]/condition") < 0.01 or eng_cover1==1 or getprop("systems/electrical/outputs/fuel-sov-r")>1 or ((fuel_select==-1 and tank1_select==1 and bstpump1<5) or (fuel_select==0 and bstpump0<5) or (fuel_select==1 and tank0_select==1 and bstpump0<5))) {
        setprop("controls/engines/engine[1]/cutoff", 1);
    } else {
        setprop("controls/engines/engine[1]/cutoff", 0);
    }

    if (FDM == "jsb") {
        setprop("gear/gear[0]/ground-friction-factor/", getprop("fdm/jsbsim/gear/unit[0]/static-friction-factor"));
        setprop("gear/gear[1]/ground-friction-factor/", getprop("fdm/jsbsim/gear/unit[1]/static-friction-factor"));
        setprop("gear/gear[2]/ground-friction-factor/", getprop("fdm/jsbsim/gear/unit[2]/static-friction-factor"));
    }

    setprop("gear/gear[0]/steering-norm", getprop("controls/gear/tiller"));


# SurferTim
#    print("U");
    update_engines();
    update_throttles();
    update_eng_sound();
    update_stall_sound();
    update_hyd_pump_sound();
    update_instruments();
    settimer(update_systems, 0);
}

# Thrust reverse info
var reverse_info = screen.display.new(10,20);

var show_reverse_info = func() {
    var FDM="";
    FDM = getprop("sim/flight-model");
    if (FDM=="yasim") {
        reverse_info.add("/controls/engines/engine[0]/reverser");
        reverse_info.add("/controls/engines/engine[1]/reverser");
    } else {
        gui.popupTip(sprintf("Thrust reverse not yet implemented!"), 5);
    }
}

var close_reverse_info = func {
    reverse_info.close();
}

#var reverse_chg = func {
#    if (getprop("/sim/replay/replay-state") == 1) return;
#    if (getprop("/controls/engines/engine[0]/reverser")) {
#        mess_e0="Thrust reverse not yet implemented!"
#    } else {
#        mess_e0="Thrust reverse not yet implemented!"
#    }
#    if (getprop("/controls/engines/engine[1]/reverser")) {
#        mess_e1="Thrust reverse not yet implemented!"
#    } else {
#        mess_e1="Thrust reverse not yet implemented!"
#    }
#    gui.popupTip(sprintf("\n%s", mess_e0), 5,);
#}
#setlistener("/controls/engines/engine[0]/reverser", reverse_chg);
#setlistener("/controls/engines/engine[1]/reverser", reverse_chg);

#controls.applyParkingBrake = func (v) {
#    if (!v) {
#        return;
#    }
#
#    var p = "/controls/gear/parkingbrake-lever";
#    setprop(p, var i = !getprop(p));
#    return i;
#};

controls.flapsDown = func(step) {
    if(step == 0) return;
    if(props.globals.getNode("/sim/flaps") != nil and getprop("controls/flight/flaps-serviceable")) {
        stepProps("/controls/flight/flaplever", "/sim/flaps", step);
        return;
    }
    # Hard-coded flap lever movement in 8 equal steps:
    var val = 0.125 * step + getprop("/controls/flight/flaplever");
    setprop("/controls/flight/flaplever", val > 1 ? 1 : val < 0 ? 0 : val);
}

var stepProps = func(dst, array, delta) {
    dst = props.globals.getNode(dst);
    array = props.globals.getNode(array);
    if(dst == nil or array == nil) { return; }

    var sets = array.getChildren("setting");

    var curr = array.getNode("current-setting", 1).getValue();
    if(curr == nil) { curr = 0; }
    curr = curr + delta;
    if   (curr < 0)           { curr = 0; }
    elsif(curr >= size(sets)) { curr = size(sets) - 1; }

    array.getNode("current-setting").setIntValue(curr);
    dst.setValue(sets[curr].getValue());
}

var DMEinit = func {
    ki266.new(0);
};

setlistener("/sim/signals/fdm-initialized", DMEinit );

var DMESources = {
    1 : "/instrumentation/nav[0]/frequencies/selected-mhz",
    2 : "/instrumentation/dme/frequencies/selected-mhz",
    3 : "/instrumentation/nav[1]/frequencies/selected-mhz"
};

setlistener( "/instrumentation/dme/switch-position", func(n) {
    var v = n.getValue();
    v == nil and return;
    n.getParent().getNode( "frequencies/source", 1 ).setValue(DMESources[v]);
}, 1, 0 );

var battery_switch = func{
    if(getprop("/controls/electric/power-source") == 1 ) {
        setprop("controls/electric/battery-switch",1);
    } else {
        setprop("controls/electric/battery-switch",0);
    }
}

setlistener("/controls/electric/power-source", battery_switch);

# SurferTim added
props.globals.initNode("/autopilot/settings/heading-bug-deg", 0.0,"DOUBLE");
props.globals.initNode("/instrumentation/heading-indicator-real-dg/heading-bug-deg", 0.0,"DOUBLE");
props.globals.initNode("/instrumentation/radar-altimeter/alarm-alt", 0.0,"DOUBLE");

setlistener("/instrumentation/radar-altimeter/indicated-agl-ft", func(test){
     thisalt = test.getValue();
     targetalt = getprop("/instrumentation/altimeter/decision-height") or 0;
     alarm = thisalt - targetalt;
     setprop("/instrumentation/radar-altimeter/alarm-alt",alarm);
},0,0);

setlistener("/instrumentation/heading-indicator-real-dg/heading-bug-deg", func(test){
     setprop("/autopilot/settings/heading-bug-deg",test.getValue());
},0,0);

setlistener("/autopilot/settings/heading-bug-deg", func(test){
     setprop("/instrumentation/heading-indicator-real-dg/heading-bug-deg",test.getValue());
},0,0);

setlistener("/sim/signals/fdm-initialized", func(){
     setprop("/instrumentation/adf/volume-norm",0.0);
     setprop("/autopilot/settings/heading-bug-deg",getprop("/instrumentation/heading-indicator-real-dg/heading-bug-deg"));
},0,0);

setlistener("controls/engines/engine[0]/reverser", func(bpe0){
    if(bpe0.getBoolValue()) {
#        print("0 rev on");
        setprop("controls/engines/engine[0]/throttle-rvrs",1)
    } else {
#        print("0 rev off");
        setprop("controls/engines/engine[0]/throttle-rvrs",0)
    }
},0,0);

setlistener("controls/engines/engine[1]/reverser", func(bpe1){
    if(bpe1.getBoolValue()) {
#        print("1 rev on");
        setprop("controls/engines/engine[1]/throttle-rvrs",1)
    } else {
#        print("1 rev off");
        setprop("controls/engines/engine[1]/throttle-rvrs",0)
    }
},0,0);

