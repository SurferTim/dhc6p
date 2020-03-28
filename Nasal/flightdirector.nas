#############################################################################
# Collins FCP-65 Flight Control Panel
#Syd Adams
#############################################################################

# 0 - Off: v-bars hidden
# lnav -0=off-wing-level,1=HDG,2=NAV arm,3=NAV cap,
# 4=APR arm,5=APR cap
# vnav - 0=off,1=ALT,2=ALT SELECT,3=VS, 4= DCS,5 = CLIMB
#
# Roll limit 25
#Half bank 12.5
#Pitch limits +20 & -10
#GA = wing level & +10 pitch hold
#

var LN_txt=["wing-leveler","dg-heading-hold","dg-heading-hold","nav1-hold","dg-heading-hold","nav1-hold"];
var VN_txt=["pitch-hold","altitude-hold","pitch-hold","vertical-speed-hold","dcs-hold","pitch-hold"];

var MTR2KT=0.000539956803;
var alt_alert = 0.0;
var course = 0.0;
var Slaved = 0;
var mag_offset=0;
var AP_hdg = "autopilot/locks/heading";
var AP_alt = "autopilot/locks/altitude";
var AP_spd = "autopilot/locks/speed";

var FD_defl = "instrumentation/flightdirector/deflection";
var FD_hdg = "/instrumentation/flightdirector/hdg-deg";
var FD_dtk = "/instrumentation/flightdirector/dtk";
var FD_to = "/instrumentation/flightdirector/to-flag";
var FD_from = "/instrumentation/flightdirector/from-flag";
var FD_nav1 = "/instrumentation/flightdirector/nav-hdg-deg";
var FD_asel = "/instrumentation/flightdirector/selected-alt-ft";

var FD_lnav = "instrumentation/flightdirector/lnav";
var FD_vnav = "instrumentation/flightdirector/vnav";
var FD_spd = "instrumentation/flightdirector/spd";

####   Init  ####

setlistener("sim/signals/fdm-initialized", func {
    setprop(AP_hdg,LN_txt[0]);
    setprop(AP_alt,VN_txt[0]);
    setprop(FD_lnav,0);
    setprop(FD_vnav,0);
    setprop(FD_spd,0);
    setprop(FD_defl,0);
    setprop(FD_hdg,0);
    setprop(FD_dtk,0);
    setprop(FD_to,0);
    setprop(FD_nav1,0);
    setprop(FD_asel,0);
    mag_offset=getprop("/environment/magnetic-variation-deg");
    settimer(update, 5);
    print("Flight Director ...Check");
});

setlistener("instrumentation/flightdirector/lnav", func(ln) {
    setprop("/instrumentation/nav/back-course-btn",0);
    update_lnav(ln.getValue());
},0,0);

setlistener("instrumentation/nav/back-course-btn", func(bc) {
    if(bc.getBoolValue()){
        var mode = getprop(FD_lnav);
        if(mode !=3 or mode !=5)setprop("instrumentation/nav/back-course-btn",0);
    }
},0,0);

setlistener("instrumentation/flightdirector/vnav", func(vn){
    var vnav = vn.getValue();
    
    update_vnav(vnav);
},0,0);

setlistener("instrumentation/flightdirector/spd", func(sp){
    spd = sp.getValue();
    if(spd == 1){
        setprop(AP_spd,"speed-with-throttle");
        }else{
            setprop(AP_spd,"");
        }
},0,0);

setlistener("instrumentation/nav/slaved-to-gps", func(slv){
    Slaved = slv.getValue();
    if(Slaved ==1){
        if(getprop("instrumentation/gps/leg-mode")){
        var lcrs=getprop("instrumentation/gps/wp/leg-mag-course-deg");
        if(lcrs ==nil)lcrs=0;
        setprop(FD_dtk,lcrs);
        }else{
        mag_offset=getprop("/environment/magnetic-variation-deg");
        var mfg =getprop("instrumentation/gps/wp/wp[1]/desired-course-deg");
        if(mfg != nil){
            mfg-=mag_offset;
            if(mfg > 360)mfg-=360;
            if(mfg < 0)mfg+=360;
            }else{
            mfg=0;
            }
        setprop(FD_dtk,mfg);
        }
    }else{
        setprop(FD_dtk,getprop("instrumentation/nav/radials/selected-deg"));
    }
},1,0);

setlistener("instrumentation/gps/wp/wp[1]/desired-course-deg", func(crs1){
    if(Slaved ==1){
        if(!getprop("instrumentation/gps/leg-mode")){
        mag_offset=getprop("/environment/magnetic-variation-deg");
        var mfg =crs1.getValue()-mag_offset;
        if(mfg > 360)mfg-=360;
        if(mfg < 0)mfg+=360;
        setprop(FD_dtk,mfg);
        }
    }
},0,0);

setlistener("instrumentation/nav/radials/selected-deg", func(crs2){
    if(Slaved ==0){
        setprop(FD_dtk,crs2.getValue());
        }
},0,0);

setlistener("instrumentation/gps/wp/leg-mag-course-deg", func(lcrs){
    if(Slaved ==1){
        if(getprop("instrumentation/gps/leg-mode")){
        setprop(FD_dtk,lcrs.getValue());
        }
    }
},0,0);

setlistener("autopilot/locks/passive-mode", func(ap){
    if(!ap.getBoolValue()){
   if(getprop(AP_alt)=="pitch-hold")setprop("autopilot/settings/target-pitch-deg",getprop("orientation/pitch-deg"));
    if(getprop(AP_alt)=="vertical-speed-hold")setprop("autopilot/settings/vertical-speed-fpm",getprop("velocities/vertical-speed-fps") * 60);
    }
},0,0);

setlistener("gear/gear[1]/wow", func(wow){
    if(wow.getBoolValue())setprop("autopilot/locks/passive-mode",1);
},0,0);

####  Set AP lateral ####

var update_lnav=func{
    var lnav=arg[0];
    if(lnav ==nil)lnav=0;
    if(lnav ==2 and Slaved==1)lnav=3;
    setprop(FD_lnav,lnav);
    setprop(AP_hdg,LN_txt[lnav]);
}

####  Set AP vertical mode ####

# SurferTim

var update_vnav=func{
    var vnav = arg[0];
    if(vnav ==nil)vnav=0;
    if(vnav == 1)setprop("autopilot/settings/target-altitude-ft",getprop("position/altitude-ft"));
    if(vnav==3)setprop("autopilot/settings/vertical-speed-fpm",getprop("velocities/vertical-speed-fps") * 60);
    setprop(AP_alt,VN_txt[vnav]);
}

####  Set correct FD mode ####

var set_fdmode = func{
var nav = arg[0];
var mode = arg[1];
if(nav==0){
    if(getprop(FD_lnav)!=mode){
        setprop(FD_lnav,mode);
    }else{
        setprop(FD_lnav,0);
        }
    }elsif(nav==1){
        if(getprop(FD_vnav)!=mode){
        setprop(FD_vnav,mode);
    }else{
        setprop(FD_vnav,0);
        }
    }elsif(nav==2){
        if(getprop(FD_spd)!=mode){
        setprop(FD_spd,mode);
    }else{
        setprop(FD_spd,0);
        }
    }
}

####    Handle FD status    ####

handle_nav_inputs = func {
    var dev=0;
    var tofl=0;
    var fromfl=0;
    var brg=0;

    if(Slaved==1){
        if(getprop("instrumentation/gps/leg-mode")){
            if(getprop("instrumentation/gps/wp/wp[1]/ID")!=nil){
                dev=getprop("instrumentation/gps/wp/leg-course-error-nm");
                if(dev>5)dev=5;
                if(dev<-5)dev=-5;
                dev=dev*2;
                tofl=getprop("instrumentation/gps/wp/leg-to-flag");
                fromfl=0;
                brg=getprop("instrumentation/gps/wp/leg-mag-course-deg");
            }
        }else{
            if(getprop("instrumentation/gps/wp/wp[1]/ID")!=nil){
                dev=getprop("instrumentation/gps/wp/wp[1]/course-deviation-deg");
                if(dev>5)dev=5;
                if(dev<-5)dev=-5;
                dev=dev*2;
                tofl-getprop("instrumentation/gps/wp/wp[1]/to-flag");
                fromfl=0;
                brg=getprop("instrumentation/gps/wp/wp[1]/bearing-mag-deg");
            }
        }
    }else{
        if(getprop("instrumentation/nav/data-is-valid")){
            dev=getprop("instrumentation/nav/heading-needle-deflection");
            tofl=getprop("instrumentation/nav/to-flag");
            fromfl=getprop("instrumentation/nav/from-flag");
            brg=getprop("instrumentation/nav/heading-deg");
        }
    }
    setprop(FD_defl,dev);
    setprop(FD_to,tofl);
    setprop(FD_from,fromfl);
    setprop(FD_hdg,brg);

    var NAVhdg =getprop(FD_dtk);
    var myhdg = NAVhdg - getprop("orientation/heading-magnetic-deg");
    if(myhdg > 180) myhdg -=360;
    if(myhdg < -180) myhdg +=360;
    myhdg+=(getprop(FD_defl)*4.5);

    setprop(FD_nav1,myhdg);
}

####    update nav gps or nav setting    ####

# SurferTim

update = func {
    handle_nav_inputs();
    var vnav=getprop(FD_vnav);
    var lnav=getprop(FD_lnav);
    var defl=getprop(FD_defl);

    if(vnav==2){
        var asel=getprop(FD_asel);
        var alt_diff=getprop("position/altitude-ft")-asel;
        if(alt_diff > -1000 and alt_diff < 1000){
        setprop("autopilot/settings/target-altitude-ft",getprop(FD_asel));
        vnav=1;
        setprop(FD_vnav,vnav);
        }
    }

#### Vor Armed ####
    if(lnav==2){
        if(defl>-9 and defl < 9){
            lnav=3;
            setprop(FD_lnav,lnav);
        }
    }

#### Approach Armed #### 
    if(lnav==4){
        if(defl>-9 and defl < 9){
            lnav=5;
            setprop(FD_lnav,lnav);
        }
    }
#### Glideslope Capture #### 
    if(lnav==5){
        if(getprop("instrumentation/nav/has-gs")){
            var gsdefl=getprop("instrumentation/nav/gs-needle-deflection");
            if(gsdefl <0.5 and gsdefl >-1.0)setprop(AP_alt,"gs1-hold");
        }
    }


    settimer(update, 0); 
    }
