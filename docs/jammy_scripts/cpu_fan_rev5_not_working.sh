#!/bin/bash

# === SETTINGS ===
PWMCHIP="pwmchip0"
PWM="$PWMCHIP/pwm0"
PERIOD=50000  # 20 kHz

# Must run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root:"
  echo "   sudo $0"
  exit 1
fi

# === SAFE EXPORT ===
if [ -d "/sys/class/pwm/$PWM" ]; then
  echo "⚙️  Disabling and unexporting PWM0..."
  echo 0 > /sys/class/pwm/$PWM/enable || true
  echo 0 > /sys/class/pwm/$PWMCHIP/unexport || true
  sleep 0.2
fi

echo "⚙️  Exporting PWM0..."
echo 0 > /sys/class/pwm/$PWMCHIP/export
echo "✅ PWM0 exported."

# Wait for sysfs
while [ ! -e "/sys/class/pwm/$PWM/period" ]; do
  sleep 0.1
done

# Base config
echo $PERIOD > /sys/class/pwm/$PWM/period
echo 1 > /sys/class/pwm/$PWM/enable

echo "🚀 Auto fan control started using $PWMCHIP ..."

while true; do
  MAX_TEMP=0
  for Z in /sys/class/thermal/thermal_zone*/temp; do
    T=$(cat $Z)
    if [ "$T" -gt "$MAX_TEMP" ]; then
      MAX_TEMP=$T
    fi
  done

  C=$((MAX_TEMP / 1000))

  if [ $C -lt 25 ]; then
    LEVEL=0
  elif [ $C -lt 30 ]; then
    LEVEL=1
  elif [ $C -lt 35 ]; then
    LEVEL=2
  elif [ $C -lt 40 ]; then
    LEVEL=3
  elif [ $C -lt 50 ]; then
    LEVEL=4
  else
    LEVEL=5
  fi

  DC=$((PERIOD * LEVEL * 20 / 100))

  echo $DC > /sys/class/pwm/$PWM/duty_cycle

  echo "🌡️  Temp: ${C}°C | Level: $LEVEL | Duty: $DC"

  sleep 5
done
