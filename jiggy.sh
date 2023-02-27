#!/bin/bash
HEAD="#######################################################################################################################
#  PROBLEM: sometimes things go to sleep when you step away & long-running scripts can break - this is my workaround!
# ABSTRACT: quick & dirty script to periodically jiggle the mouse 
#  CREATED: 2022-DEC05JN - first try 
# REQUIRES: Linux Input Event-Device Emulation Library (apt install evemu-tools) which needs to be run as root.
#?   NOTES: Libevdev abstracts the evdev ioctls through type-safe interfaces & exposed via /dev/input
#?           From man page: evemu-event plays exactly one event with the current time. 
#?               If --sync is given, evemu-event generates an EV_SYN event after the event. 
# SEE-ALSO: https://www.kernel.org/doc/Documentation/input/event-codes.txt - for low-level details
#############################################################################################################################"
set -e
RED="$(tput setaf 1)"; GRN="$(tput setaf 2)"; BLU="$(tput setaf 4)"; NORM="$(tput sgr0)"
printf "\n$BLU\n$HEAD\n$NORM\n"
delay="${1:-60}" # override the default number of seconds with param $1
# STEP-1: find the input device by globbing the latest mouse event file
mouse=$(ls -1 /dev/input/by-id/*event-mouse | tail -1)
[ -z "${mouse}" ] && echo "$RED FATAL ERROR: mouse-event interface NOT found in /dev/input $NORM" && exit 1 ## sanity check
echo -e "$GRN INFO: found ${mouse}\n  - setting sleep timer for $delay seconds - press [ctrl]+[c] to exit $NORM\n"
# STEP-n: loop until SIGINT
while [ true ]; do # get jiggy wit dat sh!
        sleep $delay
        /usr/bin/evemu-event ${mouse} --type EV_REL --code REL_X --value 1 --sync
        /usr/bin/evemu-event ${mouse} --type EV_REL --code REL_X --value -1 --sync
        echo -n "."
done
