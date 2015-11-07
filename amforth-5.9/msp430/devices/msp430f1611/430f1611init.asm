; ----------------------------------------------------------------------
; CamelForth for the Texas Instruments MSP430 
; (c) 2009 Bradford J. Rodriguez.
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; Commercial inquiries should be directed to the author at 
; 115 First St., #105, Collingwood, Ontario L9Y 4W3 Canada
; or via email to bj@camelforth.com
; ----------------------------------------------------------------------
; init430f1611.s43: CPU Configuration - MSP430F1611
; B. Rodriguez  3 Jan 09
;
; Revision History
; 12 mar 2014 bjr - adapted for naken_asm from init430f1611.s43.
;       Memory map and RAM allocation moved to camel430f1611.asm.
; 27 nov 2012 bjr - incorporated revisions from 'G2553.
; ----------------------------------------------------------------------
; This configuration is for the New Micros Tini430 board, which uses
; the MSP430F1611 microcontroller and the following I/O assignments:
;
; P1.4 - MAX3221 FORCEOFF\, drive high for normal operation
; P1.5 - MAX3221 EN\, active low
; P3.4 - RS232 TXD0
; P3.5 - RS232 RXD0
;
; P1.1 - Red LED
; P1.2 - Yellow LED
; P1.3 - Green LED
;
; I/O pins on J1:  Note that some pins are wired together, and
; must be configured so as to avoid conflicts!
; P2.0/P6.0
; P4.0/P6.1
; P2.1/P6.2
; P4.1/P6.3
; P2.2/P6.4
; P4.2/P6.5
; P2.3/P6.6
; P4.3/P6.7
; P2.4
; P4.4
; P2.5
; P4.5
; P2.6/P5.0
; P4.6/P5.1
; P2.7/P5.2
; P4.7/P5.3
;
; I/O pins on J2:
; P5.5
; P5.6
; P5.7
;
; I/O pins on J3:
; P3.1 = SDA
; P3.3 = SCL  - autostart bypass input 
;
; Clocks:
; XT2 = 8 MHz crystal
; XT1 = 32.768 kHz crystal
;
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION

; ----------------------------------------------------------------------
; MSP430F1611 INITIALIZATION
; The reset default is for all I/O pins configured as inputs,
; watchdog enabled, SR reset.

main:   ; Debugger requires the 'main' symbol.
reset:
        ; Watchdog Timer
        MOV    #(WDTPW+WDTHOLD),&WDTCTL    ; stop watchdog timer

        ; Basic Clock Module
        ; DCOCTL use default
        MOV.B   #04h,&BCSCTL1           ; turn on XT2 osc. (8 MHZ)
        MOV.B   #88h,&BCSCTL2           ; MCLK=XT2/1, SMCLK=XT2/1

        ; Flash Memory Controller
        ; Flash Timing Generator frequency must be 257-476 kHz.
        ; 8 MHZ/17 = 470.59 kHz.   tFTG=2.125 msec.
        ; At 470 kHz, byte/word program time is 35*tFTG = 75 usec.
        ; Cumulative program time to any 64-byte block (between erasures)
        ; must not exceed 4 msec, thus 53 writes at 250 kHz.  Therefore,
        ; do not use exclusively byte writes in a 64-byte block.
        ; Also, "a flash word (low + high byte) must not
        ; be written more than twice between erasures."
        ; Program/Erase endurance is 10,000 cycles minimum.
        MOV #FWKEY+0,&FCTL1             ; write & erase modes OFF
        MOV #FWKEY+FSSEL1+16,&FCTL2     ; SMCLK/17 = 471 kHz.
        MOV #FWKEY+LOCK,&FCTL3          ; lock flash memory against writing

        ; Supply Voltage Supervisor
        MOV.B   #0,&SVSCTL              ; SVS is off

        ; DMA Controller
        ; Not Used

        ; Digital I/O
        MOV.B   #10h,&P1OUT             ; P1.4 on, P1.5 off
        MOV.B   #3Eh,&P1DIR             ; P1.5..P1.1 are outputs
        MOV.B   #0,&P1IE                ; no port 1 interrupts
        MOV.B   #0,&P1SEL               ; no functions enabled

        ; MOV.B   # ,P2OUT
        MOV.B   #0,&P2DIR               ; P2 all inputs
        MOV.B   #0,&P2IE                ; no port 2 interrupts
        MOV.B   #0,&P2SEL               ; no functions enabled

        ; MOV.B   # ,P3OUT
        MOV.B   #10h,&P3DIR             ; P3.4 is output
        MOV.B   #30h,&P3SEL             ; P3.5,4 are UART pins

        ; MOV.B   # ,P4OUT
        MOV.B   #0,&P4DIR               ; P4 all inputs
        MOV.B   #0,&P4SEL               ; no functions enabled

        ; MOV.B   # ,P5OUT
        MOV.B   #0,&P5DIR               ; P5 all inputs
        MOV.B   #0,&P5SEL               ; no functions enabled

        ; MOV.B   # ,P6OUT
        MOV.B   #0,&P6DIR               ; P6 all inputs
        MOV.B   #0,&P6SEL               ; no functions enabled

        ; Timer A
        ; *TBD*

        ; Timer B
        ; *TBD*

        ; USART0
        BIS.B   #SWRST,&U0CTL           ; SWRST while configuring!
        MOV.B   #11h,&U0CTL             ; 8N1, UART, SWRST set
        MOV.B   #20h,&U0TCTL            ; BRCLK = SMCLK
        MOV.B   #0,&U0RCTL              ; no interrupts enabled
        ; MOV.B   #45H,&U0BR0             ; 115.2 kBaud at 8 MHz
        ; MOV.B   #0,&U0BR1
        MOV.B   #41h,&U0BR0             ; 9600 Baud at 8 MHz
        MOV.B   #03h,&U0BR1
        MOV.B   #0,&U0MCTL              ; no modulation 
        BIS.B   #0C0h,&ME1              ; module enable tx0,rx0
        BIC.B   #SWRST,&U0CTL           ; done configuring

        MOV     #0,TOS
BRDELAY: SUB     #1,TOS     ; delay to let baud rate settle?
        JNZ     BRDELAY

        ; USART1
        ; *TBD*

        ; Comparator A
        ; *TBD*

        ; ADC12
        ; *TBD*

        ; DAC12
        ; *TBD*

        ; Interrupt Enables
        MOV.B   #0,&IE1                 ; no interrupts enabled
        MOV.B   #0,&IE2                 ; no interrupts enabled

        ; Forth registers
        MOV     #RSTACK,SP              ; set up stack
        MOV     #PSTACK,PSP
        MOV     #UAREA,&UP              ; initial user pointer
        
        ; AUTOSTART LOGIC
        ; User Area and Variables RAM are restored from Info Flash.  
	; If BASE has a valid value, and SW2 is not pressed, and
	; LATEST points to a valid colon definition, execute that.  
	; Otherwise execute COLD, which will restore the User Area 
	; from ROM defaults.
        MOV		#UAREA,W		; User Area in RAM
	MOV		#USAVE,X		; saved user data in Info Flash
	MOV		#UAREA_SIZE+VARS_SIZE,TOS
URESTORE: MOV	@X+,0(W)
        ADD     #2,W
        SUB     #1,TOS
	JNZ		URESTORE		; leaves TOS=0
	
        ; if P3.3 is jumpered to ground (zero), go to COLD
        BIT.B   #8,&P3IN
        JZ      NOAUTO

        ; If restored BASE is invalid, go to COLD.
	; If any bit except 4,3, or 1 is set, base is invalid.
	; This allows bases 0x10, 0x0a, 0x08, and 0x02 (and a few others).
BASEOFFSET equ 4		; if User Area is changed, update this constant
	MOV	&UAREA+BASEOFFSET,W
	BIT	#(0xffff-0x1a),W
	JNZ	NOAUTO
		
	; Check that Code Field of LATEST word is DOCOLON.
	; LATEST points to the name field.
	; This is for an indirect-threaded Forth.
	; See forth.h for header structure.
LATESTOFFSET equ 14	; if User Area is changed, update this constant
	MOV	&UAREA+LATESTOFFSET,W
	MOV.B	@W,X		; get name length
	ADD	#1,X		; add 1 for length byte
	ADD	X,W		; compute address of Code Field
	ADD	#1,W		; force it to be even aligned
	BIC	#1,W
	CMP	#DOCOLON,0(W)	; is it a colon definition?
	JNZ	NOAUTO		; if not, do COLD
	ADD	#2,W		; else compute address of Parameter Field
	MOV	W,IP		;  and make that the starting IP
        NEXT

	; default startup is to perform COLD
NOAUTO: MOV     #INITIP,IP
        NEXT

; ----------------------------------------------------------------------
; DEFAULT INTERRUPT HANDLER

nullirq: RETI
