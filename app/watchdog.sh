#!/usr/bin/env bash

watchdog() {
    while(true); do
        FAIL=0

        curl http://localhost/30164/ping || FAIL=1

        if [[ $FAIL -eq 0 ]]; then
            /bin/systemd-notify WATCHDOG=1;
            sleep $(($WATCHDOG_USEC / 2000000))
        else
            sleep 1
        fi
    done
}

watchdog &
