; ----------------------------------------------------------------------
; CamelForth for the Texas Instruments MSP430 
; (c) 2009,2014 Bradford J. Rodriguez.
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
; 430g2553vecs.asm: Interrupt Vectors - MSP430G2553
; B. Rodriguez  26 oct 2012

; Revision History
;  1 mar 2014 bjr - adapted for naken_asm from vecs430g2553.s43.

; ----------------------------------------------------------------------
; Interrupt vectors are located in the range FFE0-FFFFh.

        .org 0FFE0h

intvecs: DC16 VECAREA+00     ; FFE0 - not used
        DC16  VECAREA+04     ; FFE2 - not used
        DC16  VECAREA+08     ; FFE4 - IO port P1
        DC16  VECAREA+12     ; FFE6 - IO port P2
        DC16  VECAREA+16     ; FFE8 - not used
        DC16  VECAREA+20     ; FFEA - ADC10
        DC16  VECAREA+24     ; FFEC - USCI A0/B0 tx, I2C tx/rx
        DC16  VECAREA+28     ; FFEE - USCI A0/B0 rx, I2C status
        DC16  VECAREA+32     ; FFF0 - Timer 0_A3
        DC16  VECAREA+36     ; FFF2 - Timer 0_A3
        DC16  VECAREA+40     ; FFF4 - Watchdog
        DC16  VECAREA+44     ; FFF6 - Comparator A
        DC16  VECAREA+48     ; FFF8 - Timer 1_A3
        DC16  VECAREA+52     ; FFFA - Timer 1_A3
        DC16  VECAREA+56     ; FFFC - NMI, osc.fault, flash violation
        DC16  reset       ; FFFE - Reset


; Because the MSP430G2553 is resource-limited, we use the Info Flash
; to hold user interrupt vectors and reset data.

VECS_SIZE equ 30          ; cells, 15 vectors of two cells each

        .org 1080h
        
; user interrupt vectors, 15 vectors of 2 cells each
VECAREA: 
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC

