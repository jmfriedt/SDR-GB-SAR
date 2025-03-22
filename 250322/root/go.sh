sh /root/perf.sh 
modprobe cfg80211
insmod /root/88XXau.ko 
/root/monitor.sh 
/root/packetspammer.arm wlp1s0u1u2 -n 9000000 -r 490 -s 1450
