# provides relative vectors from eye-point to aircraft lights
# in east/north/up coordinates the renderer uses

var light_manager = {

    lat_to_m: 110952.0,
    lon_to_m: 0.0,

    light1_xpos: 0.0,
    light1_ypos: 0.0,
    light1_zpos: 0.0,
    light1_r: 0.0,
    light1_g: 0.0,
    light1_b: 0.0,
    light1_size: 0.0,
    light1_stretch: 0.0,

    light2_xpos: 0.0,
    light2_ypos: 0.0,
    light2_zpos: 0.0,
    light2_r: 0.0,
    light2_g: 0.0,
    light2_b: 0.0,
    light2_size: 0.0,
    light2_stretch: 0.0,

    light3_xpos: 0.0,
    light3_ypos: 0.0,
    light3_zpos: 0.0,
    light3_r: 0.0,
    light3_g: 0.0,
    light3_b: 0.0,
    light3_size: 0.0,
    light3_hdg: 0.0,

    light4_xpos: 0.0,
    light4_ypos: 0.0,
    light4_zpos: 0.0,
    light4_r: 0.0,
    light4_g: 0.0,
    light4_b: 0.0,
    light4_size: 0.0,

    light5_xpos: 0.0,
    light5_ypos: 0.0,
    light5_zpos: 0.0,
    light5_r: 0.0,
    light5_g: 0.0,
    light5_b: 0.0,
    light5_size: 0.0,

    init: func {
        # define your lights here

        # light 1 ########
        # offsets to aircraft center
        me.light1_xpos = 50.0;
        me.light1_ypos =  6.0;
        me.light1_zpos =  2.0;

        # color values
        me.light1_r = 0.7;
        me.light1_g = 0.7;
        me.light1_b = 0.8;

        # spot size
        me.light1_size = 12.0;
        me.light1_stretch = 4.0;

        # light 2 ########
        # offsets to aircraft center
        me.light2_xpos = 50.0;
        me.light2_ypos = -6.0;
        me.light2_zpos =  2.0;

        # color values
        me.light2_r = 0.7;
        me.light2_g = 0.7;
        me.light2_b = 0.8;

        # spot size
        me.light2_size = 12.0;
        me.light2_stretch = 4.0;

        # light 3 ########
        # offsets to aircraft center
        me.light3_xpos = 20;
        me.light3_ypos = 0;
        me.light3_zpos = 1.0;

        # color values
        me.light3_r = 0.5;
        me.light3_g = 0.5;
        me.light3_b = 0.6;

        # spot size
        me.light3_size = 15.0;
        me.light3_stretch = 3.0;

        # light 4 ########
        # offsets to aircraft center
        me.light4_xpos = 1.5;
        me.light4_ypos = 6.0;
        me.light4_zpos = 2.0;

        # color values
        me.light4_r = 0.05;
        me.light4_g = 0.0;
        me.light4_b = 0.0;

        # spot size
        me.light4_size = 5.0;

        # light 5 ######## star
        # offsets to aircraft center
        me.light5_xpos = 0.7;
        me.light5_ypos = 0;
        me.light5_zpos = 2.0;

        # color values
        me.light5_r = 0.3;
        me.light5_g = 0.3;
        me.light5_b = 0.3;

        # spot size
        me.light5_size = 20.0;

        me.light_manager_timer = maketimer(0.0, func{me.update()});
        
        me.start();
    },

    start: func {
        setprop("/sim/rendering/als-secondary-lights/num-lightspots", 5);

        setprop("/sim/rendering/als-secondary-lights/lightspot/size", me.light1_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[1]", me.light2_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[2]", me.light3_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[3]", me.light4_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[4]", me.light5_size);

        setprop("/sim/rendering/als-secondary-lights/lightspot/stretch", me.light1_stretch);
        setprop("/sim/rendering/als-secondary-lights/lightspot/stretch[1]", me.light2_stretch);
        setprop("/sim/rendering/als-secondary-lights/lightspot/stretch[2]", me.light3_stretch);

        me.light_manager_timer.start();
    },

    stop: func {
        me.light_manager_timer.stop();
    },

    update: func {

        var apos = geo.aircraft_position();
        var vpos = geo.viewer_position();

        me.lon_to_m = math.cos(apos.lat()*math.pi/180.0) * me.lat_to_m;

        var heading = getprop("/orientation/heading-deg") * math.pi/180.0;
        var noseheading = heading + math.asin(getprop("controls/gear/tiller") / 2.0);
        var pitchangle = getprop("/orientation/pitch-deg");

        var lat = apos.lat();
        var lon = apos.lon();
        var alt = apos.alt();

        var sh = math.sin(heading);
        var ch = math.cos(heading);

        var nsh = math.sin(noseheading);
        var nch = math.cos(noseheading);

        var alt_agl_t = getprop("/position/altitude-agl-ft");

        var alt_agl = alt_agl_t + pitchangle * (alt_agl_t + 24.0) / 12.0;

        if(alt_agl < 0.0) {
              alt_agl = 0.0;
        }
     
        var proj_x = alt_agl;
        var proj_z = alt_agl/10.0;

# SurferTim

        var lightscale = 12.00;

        if(alt_agl < 110) {
            lightscale = alt_agl / 10.00 + 1.00;
        }

        var light_bright = (12 - lightscale) / 12.0;

        # light 1 position

    if(getprop("controls/lighting/landing-light")) {

        var new1_xpos = me.light1_xpos * lightscale;
        var new1_ypos = me.light1_ypos * lightscale;
        var new1_size = me.light1_size * lightscale;

        apos.set_lat(lat + ((new1_xpos + proj_x) * ch + new1_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + ((new1_xpos + proj_x)* sh - new1_ypos * ch) / me.lon_to_m);

        var delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        var delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        var delta_z = apos.alt()- proj_z - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m", delta_z);
        setprop("/sim/rendering/als-secondary-lights/lightspot/dir", heading);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size", new1_size);

        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r", me.light1_r * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g", me.light1_g * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b", me.light1_b * light_bright);
    }

        # light 2 position
    if(getprop("controls/lighting/landing-light[1]")) {

        var new2_xpos = me.light2_xpos * lightscale;
        var new2_ypos = me.light2_ypos * lightscale;
        var new2_size = me.light2_size * lightscale;

        apos.set_lat(lat + ((new2_xpos + proj_x) * ch + new2_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + ((new2_xpos + proj_x)* sh - new2_ypos * ch) / me.lon_to_m);

        var delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        var delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        var delta_z = apos.alt()- proj_z - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[1]", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[1]", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[1]", delta_z);
        setprop("/sim/rendering/als-secondary-lights/lightspot/dir[1]", heading);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[1]", new2_size);

        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[1]", me.light2_r * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[1]", me.light2_g * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[1]", me.light2_b * light_bright);
    }

        # light 3 position
    if(getprop("controls/lighting/taxi-lights")) {

        var new3_xpos = me.light3_xpos * lightscale;
        var new3_ypos = me.light3_ypos * lightscale;
        var new3_size = me.light3_size * lightscale;


        apos.set_lat(lat + (new3_xpos * nch + new3_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + (new3_xpos * nsh - new3_ypos * ch) / me.lon_to_m);

        delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        delta_z = apos.alt() - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[2]", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[2]", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[2]", delta_z);
        setprop("/sim/rendering/als-secondary-lights/lightspot/dir[2]", heading);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[2]", new3_size);

        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[2]", me.light3_r * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[2]", me.light3_g * light_bright);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[2]", me.light3_b * light_bright);
    }

    },   

    switch_position: func(light, lightr, lightg, lightb) {
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r["~light~"]", lightr);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g["~light~"]", lightg);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b["~light~"]", lightb);
    },

    enable_or_disable: func (enable, light_num) {
        if (enable) {
            if (light_num == 0)
                me.switch_position(light_num, me.light1_r, me.light1_g, me.light1_b);
            if (light_num == 1)
                me.switch_position(light_num, me.light2_r, me.light2_g, me.light2_b);
            if (light_num == 2)
                me.switch_position(light_num, me.light3_r, me.light3_g, me.light3_b);
            if (light_num == 3)
                me.switch_position(light_num, me.light4_r, me.light4_g, me.light4_b);
            if (light_num == 4)
                me.switch_position(light_num, me.light5_r, me.light5_g, me.light5_b);
        } else {
            me.switch_position(light_num, 0.0, 0.0, 0.0);
        }
    },

};

setlistener("/sim/signals/fdm-initialized", func {

    light_manager.init();

#    setlistener("/sim/rendering/als-secondary-lights/use-landing-light-ext", func (node) {
#        light_manager.enable_or_disable(node.getValue(), 0);
#    }, 1, 0);

#	light_manager.enable_or_disable(1,0);

#    setlistener("/sim/rendering/als-secondary-lights/use-taxi-light-ext", func (node) {
#        light_manager.enable_or_disable(node.getValue(), 1);
#    }, 1, 0);


# SurferTim added
setlistener("/controls/lighting/landing-light", func(bp){
    if(bp.getBoolValue()){
	setprop("/controls/lighting/landlight","LANDING LIGHT");
	light_manager.enable_or_disable(1,0);
    }else{
	light_manager.enable_or_disable(0,0);
	if(getprop("/controls/lighting/landing-light[1]") == 0) {
          setprop("/controls/lighting/landlight","");
	}
    }
},0,0);

# SurferTim added
setlistener("/controls/lighting/landing-light[1]", func(bp1){
    if(bp1.getBoolValue()){
	setprop("/controls/lighting/landlight","LANDING LIGHT");
	light_manager.enable_or_disable(1,1);
    }else{
	light_manager.enable_or_disable(0,1);
	if(getprop("/controls/lighting/landing-light") == 0) {
          setprop("/controls/lighting/landlight","");
        }
    }
},0,0);

# SurferTim added
setlistener("/controls/lighting/taxi-lights", func(bp2){
    if(bp2.getBoolValue()){
	light_manager.enable_or_disable(1,2);
    }else{
	light_manager.enable_or_disable(0,2);
    }
},0,0);


});



