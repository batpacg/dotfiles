#!/usr/bin/env bash

if [ ! -e /etc/udev/rules.d/51-arduino.rules ]; then
	sudo echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", MODE:="0666"' |
		sudo tee /etc/udev/rules.d/51-arduino.rules > /dev/null
fi
