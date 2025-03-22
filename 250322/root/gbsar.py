#!/usr/bin/python3

# http://abyz.me.uk/rpi/pigpio/index.html
import pigpio
import time

# position=8
# 18=1, 19=2, 20=4, 21=8->26, 22=16, 23=32

pi = pigpio.pi()       # pi1 accesses the local Pi's GPIO

pi.set_mode(5, pigpio.OUTPUT)   # START as output
# 26=replacement of GPIO21 not working! 
for k in range(18,26+1):
  pi.set_mode(k, pigpio.OUTPUT) # GPIO 18..26 as output

pi.write(5, 1)     # inverted logic
for position in range(128,129):
#for position in range(1,2):
  print(position)
  pi.clear_bank_1(position<<18)
  val=~(position<<18)&0x03fc0000;
  pi.set_bank_1(val)
  if (position & 8)==0:
    pi.write(26, 1)  # inverted logic
  else:
    pi.write(26, 0)  # inverted logic
  pi.write(5, 0)     # inverted logic
  time.sleep(1)
  pi.write(5, 1)     # inverted logic
  time.sleep(0.5)
