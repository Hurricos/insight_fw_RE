install: g1_insight_h8_module_rewriter.ino.eightanaloginputs.hex
	avrdude -v -patmega328p -carduino -P/dev/ttyUSB0 -b57600 -D -Uflash:w:$<:i

view:
	echo "Use C-j/^J to submit."
	echo "TODO Add usage documentation of flashing f/w"
	lsof /dev/ttyUSB0 >/dev/null 2>&1 || screen /dev/ttyUSB0 115200

reset_serial:
	echo 0 | tee $$(grep -e 'Prolific' /sys/bus/usb/devices/*/manufacturer | cut -d/ -f1-6)/bConfigurationValue;
	sleep 0.1s;
	echo 1 | tee $$(grep -e 'Prolific' /sys/bus/usb/devices/*/manufacturer | cut -d/ -f1-6)/bConfigurationValue;
