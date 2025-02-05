#!/bin/bash

set -e  # Exit on error
set -u  # Treat unset variables as an error
set -o pipefail  # Catch errors in pipes

# Check superuser privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with superuser privileges!"
   exit 1
fi

# Disable CPU idle states
echo "Disabling CPU idle states for all cores..."
for cpu in /sys/devices/system/cpu/cpu{0..7}; do
    [[ -d "$cpu" ]] && echo 1 > "$cpu/cpuidle/state1/disable"
done

# Overclock CPU
echo "CPU available frequencies:"
cat /sys/devices/system/cpu/cpufreq/policy{0,4,6}/scaling_available_frequencies
echo "Setting CPU max frequencies to:"
declare -A CPU_FREQS=(
    [0]=1800000
    [4]=2352000
    [6]=2352000
)
for policy in "${!CPU_FREQS[@]}"; do
    echo userspace > /sys/devices/system/cpu/cpufreq/policy$policy/scaling_governor
    echo "${CPU_FREQS[$policy]}" > /sys/devices/system/cpu/cpufreq/policy$policy/scaling_setspeed
    cat /sys/devices/system/cpu/cpufreq/policy$policy/scaling_cur_freq
done

# Overclock DDR
echo "DDR available frequencies:"
cat /sys/class/devfreq/dmc/available_frequencies
if [[ -f "/sys/class/devfreq/dmc/governor" ]]; then
    echo "Setting DDR max frequency to:"
    echo userspace > /sys/class/devfreq/dmc/governor
    echo 2112000000 > /sys/class/devfreq/dmc/userspace/set_freq
    cat /sys/class/devfreq/dmc/cur_freq
else
    echo "Warning: DDR frequency control files not found!"
fi

# Overclock GPU
echo "GPU available frequencies:"
cat /sys/class/devfreq/fb000000.gpu/available_frequencies
echo "Setting GPU max frequency to:"
echo userspace > /sys/class/devfreq/fb000000.gpu/governor
echo 1000000000 > /sys/class/devfreq/fb000000.gpu/userspace/set_freq
cat /sys/class/devfreq/fb000000.gpu/cur_freq

# Overclock NPU
echo "NPU available frequencies:"
cat /sys/class/devfreq/fdab0000.npu/available_frequencies
echo "Setting NPU max frequency to:"
echo userspace > /sys/class/devfreq/fdab0000.npu/governor
echo 1000000000 > /sys/class/devfreq/fdab0000.npu/userspace/set_freq
cat /sys/class/devfreq/fdab0000.npu/cur_freq