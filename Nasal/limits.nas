# Copyright (C) 2015  FlightGear Team, Jonathan Schellhase (DG-505)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################
#
# Custom limit functions and callouts for the DHC-6 Twin Otter
#
# Originally taken from Aircraft/Generic/limits.nas
# Modified by Jonathan Schellhase (DG-505), Dec 2015
#
###############################################################

# Flaps extension limits
var checkFlaps = func(n) {
  var flapsetting = n.getValue();
  if (flapsetting == 0)
    return;
  var enabled = getprop("limits/warnings-enabled");
  var airspeed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  var ltext = "";
  var limits = props.globals.getNode("limits");
  if ((limits != nil) and (limits.getChildren("max-flap-extension-speed") != nil)) {
    var children = limits.getChildren("max-flap-extension-speed");
    foreach(var c; children) {
      if ((c.getChild("flaps") != nil) and
          (c.getChild("speed") != nil)     ) {
        var flaps = c.getChild("flaps").getValue();
        var speed = c.getChild("speed").getValue();
        if ((flaps != nil)        and
            (speed != nil)        and
            (flapsetting > flaps) and
            (airspeed > speed)    and
            (enabled == 1)           ) {
          ltext = "Flaps extended above maximum flap extension speed!";
        }
      }
    }
    if (ltext != "") {
      screen.log.write(ltext);
    }
  }
}

# Gear extension limits
var checkGear = func(n) {
  if (!n.getValue())
    return;
  var enabled = getprop("limits/warnings-enabled");
  var airspeed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  var max_gear = getprop("limits/max-gear-extension-speed");

  if ((max_gear != nil) and (airspeed > max_gear) and (enabled == 1)) {
    screen.log.write("Gear extended above maximum extension speed!");
  }
}

# Set the listeners
setlistener("controls/flight/flaps", checkFlaps);
setlistener("controls/gear/gear-down", checkGear);

var checkG = func{
  if (getprop("/sim/freeze/replay-state"))
    return;
  var enabled = getprop("limits/warnings-enabled");
  var g = getprop("/accelerations/pilot-gdamped") or 1;
  var max_positive = getprop("limits/max-positive-g");
  var max_negative = getprop("limits/max-negative-g");
  var msg = "";
  if ((max_positive != nil) and (g > max_positive) and (enabled == 1)) {
    msg = "Airframe structural positive-g load limit exceeded!";
  }
  if ((max_negative != nil) and (g < max_negative) and (enabled == 1)) {
    msg = "Airframe structural negative-g load limit exceeded!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkG, 10);
  }
  else {
    settimer(checkG, 1);
  }
}
checkG();

# Airspeed limits
var checkVNE = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
  var enabled = getprop("limits/warnings-enabled");
  var msg = "";
  var airspeed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
  var altitude = getprop("position/altitude-ft");
  var vne_0    = getprop("limits/vne-0");
  var vne_1    = getprop("limits/vne-1");
  var vne_2    = getprop("limits/vne-2");
  var vne_3    = getprop("limits/vne-3");
  var vne_4    = getprop("limits/vne-4");

  if ((airspeed != nil) and (altitude != nil) and (vne_0 != nil) and (airspeed > vne_0) and (altitude < 6700) and (enabled == 1)) {
    msg = "Airspeed exceeds Maximum Operating Speed! Reduce the speed!";
  }

  if ((airspeed != nil) and (altitude != nil) and (vne_1 != nil) and (airspeed > vne_1) and (altitude >= 6700) and (altitude < 10000) and (enabled == 1)) {
    msg = "Airspeed exceeds Maximum Operating Speed! Reduce the speed!";
  }

  if ((airspeed != nil) and (altitude != nil) and (vne_2 != nil) and (airspeed > vne_2) and (altitude >= 10000) and (altitude < 15000) and (enabled == 1)) {
    msg = "Airspeed exceeds Maximum Operating Speed! Reduce the speed!";
  }

  if ((airspeed != nil) and (altitude != nil) and (vne_3 != nil) and (airspeed > vne_3) and (altitude >= 15000) and (altitude < 20000) and (enabled == 1)) {
    msg = "Airspeed exceeds Maximum Operating Speed! Reduce the speed!";
  }

  if ((airspeed != nil) and (altitude != nil) and (vne_4 != nil) and (airspeed > vne_4) and (altitude >= 20000) and (enabled == 1)) {
    msg = "Airspeed exceeds Maximum Operating Speed! Reduce the speed!";
  }

  if (msg != "") {
    screen.log.write(msg);
    settimer(checkVNE, 10);
  }
  else {
    settimer(checkVNE, 1);
  }
}
checkVNE();

# Altitude limit
var checkALT = func {
   if (getprop("/sim/freeze/replay-state"))
    return;
  var enabled = getprop("limits/warnings-enabled");
  var msg = "";
  var altitude = getprop("position/altitude-ft");
  var max_alt = getprop("limits/max-alt");

  if ((altitude != nil) and (altitude > max_alt) and (enabled == 1)) {
    msg = "Maximum Operation Altitude exceeded! Descend!";
  }

  if (msg != "") {
    screen.log.write(msg);
    settimer(checkALT, 10);
  }
  else {
    settimer(checkALT, 1);
  }
}
checkALT();

# ENGINE LIMITS
# Tourque pressure
var checkLHtorque = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
  var enabled = getprop("limits/warnings-enabled");
  var msg = "";
  var LHtorque = getprop("engines/engine[0]/torque-ftlb");
  var LHtorque_limit = getprop("limits/max-torque-ftlb");
  if ((LHtorque != nil) and (LHtorque_limit != nil) and (LHtorque > LHtorque_limit) and (enabled == 1)) {
    msg = "Left torque pressure ecxeeds maximum! Reduce throttle immediately!!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkLHtorque, 10);
  }
  else {
    settimer(checkLHtorque, 1);
  }
}
checkLHtorque();

var checkRHtorque = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
  var enabled = getprop("limits/warnings-enabled");
  var msg = "";
  var RHtorque = getprop("engines/engine[1]/torque-ftlb");
  var RHtorque_limit = getprop("limits/max-torque-ftlb");
  if ((RHtorque != nil) and (RHtorque_limit != nil) and (RHtorque > RHtorque_limit) and (enabled == 1)) {
    msg = "Right torque pressure exceeds maximum! Reduce throttle immediately!!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkRHtorque, 10);
  }
  else {
    settimer(checkRHtorque, 1);
  }
}
checkRHtorque();

# Prop RPM
var checkLHrpm = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var LHrpm = getprop("engines/engine[0]/rpm");
    var LHrpm_limit = getprop("limits/max-prop-rpm");
    if ((LHrpm != nil) and (LHrpm_limit != nil) and (LHrpm > LHrpm_limit) and (enabled == 1)) {
      msg = "Left propeller exceeds maximum RPM! Reduce propeller pitch!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkLHrpm, 10);
  }
  else {
    settimer(checkLHrpm, 1);
  }
}
checkLHrpm();

var checkRHrpm = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var RHrpm = getprop("engines/engine[1]/rpm");
    var RHrpm_limit = getprop("limits/max-prop-rpm");
    if ((RHrpm != nil) and (RHrpm_limit != nil) and (RHrpm > RHrpm_limit) and (enabled == 1)) {
      msg = "Right propeller exceeds maximum RPM! Reduce propeller pitch!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkRHrpm, 10);
  }
  else {
    settimer(checkRHrpm, 1);
  }
}
checkRHrpm();

# Exhaust temperature
var checkLHT5 = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var LHT5 = getprop("engines/engine[0]/t5");
    var LHT5_limit = getprop("limits/max-exhaust-temp");
    if ((LHT5 != nil) and (LHT5_limit != nil) and (LHT5 > LHT5_limit) and (enabled == 1)) {
      msg = "The left engine overheates! Reduce the throttle!!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkLHT5, 10);
  }
  else {
    settimer(checkLHT5, 1);
  }
}
checkLHT5();

var checkRHT5 = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var RHT5 = getprop("engines/engine[1]/t5");
    var RHT5_limit = getprop("limits/max-exhaust-temp");
    if ((RHT5 != nil) and (RHT5_limit != nil) and (RHT5 > RHT5_limit) and (enabled == 1)) {
      msg = "The right engine overheates! Reduce the throttle!!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkRHT5, 10);
  }
  else {
    settimer(checkRHT5, 1);
  }
}
checkRHT5();

# Turbine speed
var checkLHggRPM = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var LHggRPM = getprop("engines/engine[0]/n2");
    var LHTggRPM_limit = getprop("limits/max-n2");
    if ((LHggRPM != nil) and (LHTggRPM_limit != nil) and (LHggRPM > LHTggRPM_limit) and (enabled == 1)) {
      msg = "The left turbine is over-revving! Reduce power!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkLHggRPM, 10);
  }
  else {
    settimer(checkLHggRPM, 1);
  }
}
checkLHggRPM();

var checkRHggRPM = func {
  if (getprop("/sim/freeze/replay-state"))
    return;
    var enabled = getprop("limits/warnings-enabled");
    var msg = "";
    var RHggRPM = getprop("engines/engine[1]/n2");
    var RHggRPM_limit = getprop("limits/max-n2");
    if ((RHggRPM != nil) and (RHggRPM_limit != nil) and (RHggRPM > RHggRPM_limit) and (enabled == 1)) {
      msg = "The right turbine is over-revving! Reduce power!";
  }
  if (msg != "") {
    screen.log.write(msg);
    settimer(checkRHggRPM, 10);
  }
  else {
    settimer(checkRHggRPM, 1);
  }
}
checkRHggRPM();
