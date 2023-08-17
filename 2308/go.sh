echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
modprobe cfg80211
insmod  88XXau.ko 
./monitor.sh 
./packetspammer.arm wlp1s0u1u2 -n 1000000 -r 450 -s 1450
