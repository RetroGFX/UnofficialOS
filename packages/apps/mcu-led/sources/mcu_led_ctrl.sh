#!/bin/bash

UART_DEV=/dev/ttyS2
LED_POWER=/sys/kernel/debug/regulator/vcc-led/enable
PWR_STATUS=$(cat "$LED_POWER")
CMD=$1

if [ $CMD == "init" ]; then
    CMD=$(grep "ee_led.mode=" /storage/.config/emuelec/configs/emuelec.conf | cut -d'=' -f2)
fi

if [ "$CMD" != "LED_OFF" ] && [ "$CMD" != "deinit" ]; then
    if [ "$(cat "$LED_POWER")" == "0" ]; then
        echo 1 > "$LED_POWER"
    fi
fi

case $CMD in
    deinit|LED_OFF)
        if [ "$PWR_STATUS" == "1" ]; then
            echo 0 > "$LED_POWER"
        fi
        mcu_led "$UART_DEV" chgmode 9 1
        ;;

    LED_G)
        mcu_led "$UART_DEV" chgmode 1 1
        ;;

    LED_B)
        mcu_led "$UART_DEV" chgmode 2 1
        ;;

    LED_R)
        mcu_led "$UART_DEV" chgmode 3 1 
        ;;

    LED_G_B)
        mcu_led "$UART_DEV" chgmode 4 1
        ;;

    LED_R_G)
        mcu_led "$UART_DEV" chgmode 5 1
        ;;

    LED_B_R)
        mcu_led "$UART_DEV" chgmode 6 1 
        ;;

    LED_R_B_G)
        mcu_led "$UART_DEV" chgmode 7 1
        ;;

    LED_SCROLLING)
        mcu_led "$UART_DEV" chgmode 8 1
        ;;

    LED_BREATH_G)
        mcu_led "$UART_DEV" chgmode 17 1
        ;;

    LED_BREATH_B)
        mcu_led "$UART_DEV" chgmode 18 1
        ;;

    LED_BREATH_R)
        mcu_led "$UART_DEV" chgmode 19 1
        ;;

    LED_BREATH_G_B)
        mcu_led "$UART_DEV" chgmode 20 1
        ;;

    LED_BREATH_R_G)
        mcu_led "$UART_DEV" chgmode 21 1
        ;;

    LED_BREATH_B_R)
        mcu_led "$UART_DEV" chgmode 22 1
        ;;

    LED_BREATH_R_B_G)
        mcu_led "$UART_DEV" chgmode 23 1
        ;;

    LED_BREATH)
        mcu_led "$UART_DEV" chgmode 24 1
        ;;

    *)
        echo "Usage: $0 {init|deinit|LED_OFF|LED_R|LED_B|LED_G|LED_R_B|LED_R_G|LED_B_G|LED_R_B_G|LED_SCROLLING|LED_BREATH_R|LED_BREATH_B|LED_BREATH_G|LED_BREATH_R_B|LED_BREATH_R_G|LED_BREATH_B_G|LED_BREATH_R_B_G|LED_BREATH}"
        exit 1
        ;;
esac

exit 0
