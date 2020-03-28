####VS display convertion

var vsconvert = func{
	var vs_set = getprop("autopilot/settings/vertical-speed-fpm");	
	var vs_displ = abs(vs_set);
	setprop("autopilot/settings/vs-display",vs_displ);
	}
	setlistener("autopilot/settings/vertical-speed-fpm",vsconvert,0,0);