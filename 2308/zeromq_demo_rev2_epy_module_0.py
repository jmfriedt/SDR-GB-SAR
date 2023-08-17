# this module will be imported in the into your flowgraph    
import socket
import string
import sys
import os
# http://abyz.me.uk/rpi/pigpio/index.html
import pigpio
import time

# 18=1, 19=2, 20=4, 21=8->26, 22=16, 23=32
def set_position(pi,position):
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

def jmf_server(self):                                                                           
    position=128       # 0..128
    channel=96        # 96=5480 MHz -> 140=5700
    leave=False
    pi = pigpio.pi()       # pi1 accesses the local Pi's GPIO
    pi.set_mode(5, pigpio.OUTPUT)   # START as output
  # GPIO26 replacement of GPIO21 not working! 
    for k in range(18,26+1):
        pi.set_mode(k, pigpio.OUTPUT) # GPIO 17 as output
    pi.write(5, 1)     # inverted logic
    sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)                                      
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)                                  
    sock.bind(("192.168.77.168", 5556))                                                              
    print("Server running")                                                                     
    while leave!=True:                                                                             
        sock.listen(1)                                                                              
        conn, addr = sock.accept()                                                                  
        with conn:                                                                                  
            finished=False
            print('connected from ',addr)                                                           
            while finished!=True:
                data=conn.recv(1)                                                                  
                print(data)                                                                        
                if '+' in str(data):                                                               
                    self.f=self.f+self.samp_rate
                    conn.send(b'o')
                if 'u' in str(data):                                                               
                    channel=channel+2
                    self.f=(channel*5+5000)*1e6-self.samp_rate/2
                    os.system('/sbin/iwconfig wlp1s0u1u2 channel '+str(channel))
                    conn.send(b'o')
                if '-' in str(data):
                    self.f=self.f-self.samp_rate                                                         
                    conn.send(b'o')
                if 'd' in str(data):                                                               
                    channel=channel-2
                    os.system('/sbin/iwconfig wlp1s0u1u2 channel '+str(channel))
                    self.f=int(((channel*5+5000)*1e6))-self.samp_rate/2
                    conn.send(b'o')
                if 'z' in str(data):                                                               
                    print("init all")
                    channel=96
                    os.system('/sbin/iwconfig wlp1s0u1u2 channel '+str(channel))
                    self.f=int(((channel*5+5000)*1e6))-self.samp_rate/2
                    position=128
                    set_position(pi,position)
                    conn.send(b'o')
                if '0' in str(data):                                                               
                    print("init freq")
                    channel=96
                    os.system('/sbin/iwconfig wlp1s0u1u2 channel '+str(channel))
                    self.f=int(((channel*5+5000)*1e6))-self.samp_rate/2
                    conn.send(b'o')
                if 'l' in str(data):                                                               
                    print("moving left")
                    position=position+1
                    set_position(pi,position)
                    conn.send(b'o')
                if 'r' in str(data):                                                               
                    print("moving right")
                    position=position-1
                    set_position(pi,position)
                    conn.send(b'o')
                if 'x' in str(data):                                                               
                    print('Bye')                                                                    
                    sock.shutdown(socket.SHUT_RDWR)                                                 
                    sock.close()                                                                    
                    leave=True
                    conn.send(b'o')
                if 'q' in str(data):                                                               
                    print('Bye')                                                                    
                    conn.send(b'o')
                    conn.close()                                                 
                    finished=True
#                print(f"{self.f} {channel} {position}")
                self.set_f(self.f)







