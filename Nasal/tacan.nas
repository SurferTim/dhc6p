var UPDATE_PERIOD = 0.05;




var TrueHdg          = props.globals.getNode("orientation/heading-deg");
var MagHdg           = props.globals.getNode("orientation/heading-magnetic-deg");
var MagDev           = props.globals.getNode("orientation/local-mag-dev", 1);
var Tc               = props.globals.getNode("instrumentation/tacan");
var TcTrueHdg        = Tc.getNode("indicated-bearing-true-deg");
var TcMagHdg         = Tc.getNode("indicated-mag-bearing-deg", 1);
var TcXY             = Tc.getNode("frequencies/selected-channel[4]");
#var TcXYSwitch       = props.globals.getNode("sim/model/E-2C/controls/instrumentation/tacan/xy-switch", 1);
var mag_dev = 0;


# Compute local magnetic deviation.
var local_mag_deviation = func {
	var true = TrueHdg.getValue();
	var mag = MagHdg.getValue();
	mag_dev = geo.normdeg( mag - true );
	if ( mag_dev > 180 ) mag_dev -= 360;
	MagDev.setValue(mag_dev); 
}

var tacan_update = func {
	# Get magnetic tacan bearing.
	var true_bearing = TcTrueHdg.getValue();
	var mag_bearing = geo.normdeg( true_bearing + mag_dev );
	if ( true_bearing != 0 ) {
		TcMagHdg.setDoubleValue( mag_bearing );
	} else {
		TcMagHdg.setDoubleValue(0);
	}
}

# Lighting ################
aircraft.data.add(
	"controls/lighting/instruments-primary-norm",
	"controls/lighting/instruments-secondary-norm",
	"controls/lighting/panel-norm"
	);





# Main loop ###############
var cnt = 0;

var main_loop = func {
	cnt += 1;
	# done each 0.05 sec.
	var a = cnt / 2;


	if ( ( a ) == int( a )) {
		# done each 0.1 sec, cnt even.
		tacan_update();
		if ( cnt == 12 ) {
			# done each 0.6 sec.
			local_mag_deviation();
			cnt = 0;
		}
	}

	settimer(main_loop, UPDATE_PERIOD);
}


# Init ####################
var init = func {
	print("Initializing TACAN System");
	local_mag_deviation();
	# launch
	settimer(main_loop, 0.5);
}

setlistener("sim/signals/fdm-initialized", init);

