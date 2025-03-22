clear all
more off

pkg load instrument-control   % switch control

if (exist("serial") != 3)
    disp("No Serial Support");
endif   

s1 = serial("/dev/ttyACM0");  % Open the port
pause(.1);                    % Optional wait for device to wake up 
set(s1, 'baudrate', 115200);  % communication speed
set(s1, 'bytesize', 8);       % 5, 6, 7 or 8
set(s1, 'parity', 'n');       % 'n' or 'y'
set(s1, 'stopbits', 1);       % 1 or 2
set(s1, 'timeout', 123);      % 12.3 Seconds as an example here

for m=1:7
	m
srl_write(s1,"+"); pause(32);
end
