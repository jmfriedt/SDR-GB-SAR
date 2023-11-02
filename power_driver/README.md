KiCAD files for the 0-3.3V to 24-0V driver for the Raspberry Pi 4 using the ULN2003 Darlington
transistor array. Notice the Darlington transistor acts as an inverter so that 0V command will
provide a 24V output and 3.3V GPIO command will lead to a 0V output.

TODO: double the ULN2003 for more outputs to allow for more than 64 steps (done manually by stacking
a second chip on top of the first, only sharing ping 8 and 9 for GND and 24V respectively).
