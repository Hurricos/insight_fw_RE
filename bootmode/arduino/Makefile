install: g1_insight_h8_module_rewriter.ino.eightanaloginputs.hex
	avrdude -v -patmega328p -carduino -P/dev/ttyUSB0 -b57600 -D -Uflash:w:$<:i

view:
	echo "Use C-j/^J to submit."
	echo "TODO Add usage documentation of flashing f/w"
	lsof /dev/ttyUSB0 >/dev/null 2>&1 || screen /dev/ttyUSB0 115200

