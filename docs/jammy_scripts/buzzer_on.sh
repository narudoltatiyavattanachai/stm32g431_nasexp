#!/bin/bash

# === CONFIG ===
PWMCHIP=2      # your PWM8 is pwmchip2
CHANNEL=0      # PWM8 is channel 0 on pwmchip2

# === ASK ON (1) / OFF (0) ===
read -p "Enter 1 to turn PWM ON, or 0 to turn it OFF: " STATE

# === If ON, get frequency & duty ===
if [ "$STATE" == "1" ]; then
    read -p "Enter frequency in Hz: " FREQ
    read -p "Enter duty cycle in percent (0-100): " DUTY

    PERIOD_NS=$(( 1000000000 / FREQ ))
    DUTY_NS=$(( PERIOD_NS * DUTY / 100 ))

    echo "Config: PWMCHIP=$PWMCHIP, CHANNEL=$CHANNEL"
    echo " - Frequency: ${FREQ} Hz"
    echo " - Period: ${PERIOD_NS} ns"
    echo " - Duty: ${DUTY_NS} ns"

    if [ ! -d /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL} ]; then
        echo "$CHANNEL" | sudo tee /sys/class/pwm/pwmchip${PWMCHIP}/export
        sleep 0.1
    fi

    echo "$PERIOD_NS" | sudo tee /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL}/period
    echo "$DUTY_NS" | sudo tee /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL}/duty_cycle
    echo 1 | sudo tee /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL}/enable
    echo "✅ PWM ON: ${FREQ} Hz, ${DUTY}% duty"

elif [ "$STATE" == "0" ]; then
    if [ -d /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL} ]; then
        echo 0 | sudo tee /sys/class/pwm/pwmchip${PWMCHIP}/pwm${CHANNEL}/enable
        echo "✅ PWM OFF"
    else
        echo "PWM channel not exported — nothing to disable."
    fi

else
    echo "Invalid input: please enter 1 (ON) or 0 (OFF)."
    exit 1
fi

