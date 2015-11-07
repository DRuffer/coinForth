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
; 430f1611vecs.asm: Interrupt Vectors - MSP430F1611
; B. Rodriguez  3 Jan 09

; Revision History
;  12 mar 2014 bjr - adapted for naken_asm from vecs430f1611.s43.

; ----------------------------------------------------------------------
; Interrupt vectors are located in the range FFE0-FFFFh.

        .org 0FFE0h

intvecs: DC16 VECAREA+00     ; FFE0 - DMA/DAC12
        DC16  VECAREA+04     ; FFE2 - IO port P2
        DC16  VECAREA+08     ; FFE4 - USART1 tx
        DC16  VECAREA+12     ; FFE6 - USART1 rx
        DC16  VECAREA+16     ; FFE8 - IO port P1
        DC16  VECAREA+20     ; FFEA - Timer A3
        DC16  VECAREA+24     ; FFEC - Timer A3
        DC16  VECAREA+28     ; FFEE - ADC12
        DC16  VECAREA+32     ; FFF0 - USART0 tx, I2C
        DC16  VECAREA+36     ; FFF2 - USART0 rx
        DC16  VECAREA+40     ; FFF4 - Watchdog
        DC16  VECAREA+44     ; FFF6 - Comparator A
        DC16  VECAREA+48     ; FFF8 - Timer B7
        DC16  VECAREA+52     ; FFFA - Timer B7
        DC16  VECAREA+56     ; FFFC - NMI, osc.fault, flash violation
        DC16  reset       ; FFFE - Reset
