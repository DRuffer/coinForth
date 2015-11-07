

launchpad430.hex: launchpad430.asm ../../msp430/*
	naken_asm -I words \
	  -I ../../msp430/devices/msp430g2553 \
	  -I ../../msp430 \
	  -I ../../common launchpad430.asm \
	  -o launchpad430.hex -l


launchpad430: launchpad430.hex
	mspdebug rf2500 "prog launchpad430.hex "

clean:
	rm launchpad430.hex launchpad430.lst

upload: launchpad430
