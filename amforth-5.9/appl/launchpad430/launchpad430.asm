; ----------------------------------------------------------------------
; Forth for the Texas Instruments MSP430 
; (c) 2009,2014 Bradford J. Rodriguez.
; (c) 2015 Matthias Trute
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

.msp430

.include "msp430g2553.inc"  ; MCU-specific register equates
.include "itc430.inc"       ; registers, macros, and header structure

; ----------------------------------------------------------------------
; MEMORY MAP of the MSP430G2553
; 16KB flash ROM, 0.5KB RAM
;
; 0000-01FF = peripherals
; 0200-03FF = 0.5KB RAM
; 0400-0FFF = unused
; 1000-10FF = 256B information memory
; C000-FFFF = 16KB flash ROM 
;   FFE0-FFFF = interrupt vectors
;
; Forth REVISED memory map (puts UAREA last, before dictionary):
;   UAREA-128h  HOLD area, 20 bytes, grows down from end
;   UAREA-114h  PAD buffer, 82 bytes, must follow HOLD area
;   UAREA-114h  TIB Terminal Input Buffer, 82 bytes, overlaps PAD
;   UAREA-0C2h  Parameter stack, 96 bytes, grows down from end
;   UAREA-62h   Return stack, 96 bytes, grows down from end
;   UP          User Pointer, 2 bytes
;   CFG...      Configuration Stack Area
;   UAREA       User area, 32 bytes
; The User Area and Configuration Area spaces will be restored from 
; Info ROM, so they should total 128 bytes.
;
; Note all must be word-aligned.
; See also the definitions of U0, S0, and R0 in the "system variables &
; constants" area.  A task w/o terminal input requires 200h bytes.
; Double all except TIB and PAD for 32-bit CPUs.
;
; Because the MSP430G2553 is resource-limited, we use the Info Flash
; to hold user interrupt vectors and reset data.
;   INFO+000h (INFOD):  RAM save area
;   INFO+040h (INFOC):  RAM save area
;   INFO+080h (INFOB):  user interrupt vectors
;   INFO+0C0h (INFOA):  configuration data - do not use

; FLASH MEMORY LIMITS
; for Flash memory operations - this includes information and main
; ROM, but not the main ROM used by the kernel (above E000h)
INFOSTART  equ 01000h
INFOEND    equ 010BFh     ; do not allow config flash to be erased
FLASHSTART equ 0C000h
FLASHEND   equ 0DFFFh
MAINSEG    equ 512
INFOSEG    equ 64
INFO_SIZE  equ 128    ; bytes

UAREA_SIZE  equ 34        ; bytes, see uinit.asm
RSTACK_SIZE equ 40        ; cells
PSTACK_SIZE equ 40        ; cells
; following only required for terminal tasks
HOLD_SIZE equ 20          ; bytes (must be even)
PAD_SIZE equ 0            ; bytes (must be even)
TIB_SIZE equ 82           ; bytes (must be even)

F_CPU EQU 8000000

; ----------------------------------------------------------------------
; SOURCE FILES
.include "ram.inc"
.include "430g2553vecs.asm" ; note: sets .org for vector tables
        .org 0E000h         ; start address of Forth kernel
.include "itc430core.asm"   ; code primitives
.include "itc430hilvl.asm"
.include "430g2553init.asm"
;.include "words/dump.asm"
;.include "words/code.asm"
;.include "words/end-code.asm"
;.include "words/bm-set.asm"
;.include "words/bm-clear.asm"
; ----------------------------------------------------------------------
; END OF FORTH KERNEL

.set lastword = link           ; last word in dictionary
.set lastenv  = envlink

        END
