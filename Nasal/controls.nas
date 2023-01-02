
# TACAN: panel controls
# ---------------------
var TcXY             = getprop("instrumentation/tacan/frequencies/selected-channel[4]");
#var TcXYSwitch       = getprop("sim/model/E-2C/controls/instrumentation/tacan/xy-switch", 1);

var tacan_XYtoggle = func {
	if (getprop("instrumentation/tacan/frequencies/selected-channel[4]") == 'X' ) {
		setprop("instrumentation/tacan/frequencies/selected-channel[4]",'Y');
#		TcXYSwitch.setValue( 1 );
	} else {
		setprop("instrumentation/tacan/frequencies/selected-channel[4]",'X');
#		TcXYSwitch.setValue( 0 );
	}
}

var tacan_tenth_adjust = func(n) {
	var tenths = getprop( "instrumentation/tacan/frequencies/selected-channel[2]" );
	var hundreds = getprop( "instrumentation/tacan/frequencies/selected-channel[1]" );
	var value = (10 * tenths) + (100 * hundreds);
	var new_value = value + n;
	var new_hundreds = int(new_value/100);
	var new_tenths = (new_value - (new_hundreds*100))/10;
	setprop( "instrumentation/tacan/frequencies/selected-channel[1]", new_hundreds );
	setprop( "instrumentation/tacan/frequencies/selected-channel[2]", new_tenths );
}



