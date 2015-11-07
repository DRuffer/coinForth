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
; itc430.h: Register, Model, and Macro declarations - 
;   MSP430, Indirect Threaded Code
; B. Rodriguez  3 Jan 09
; ----------------------------------------------------------------------
; Revision History
; 27 feb 14 bjr - adapted from msp430/forth.h for naken_asm.
; 26 oct 12 bjr - moved memory usage defines to init430 file.
;  1 mar 09 bjr - added INFOSTART, changed FLASHSTART to be Main flash address
; 17 jan 09 bjr - changed IMMEDIATE flag from $00 to $FE to allow
;   use as a token field.

cpu_msp430 EQU 1
cpu_avr8   EQU 0


; FORTH REGISTER USAGE

; Forth virtual machine
#define RSP SP
#define PSP R4
#define IP  R5
#define W   R6
#define TOS R7

; Loop parameters in registers
#define INDEX R8
#define LIMIT R9

; Scratch registers
#define X  R10
#define Y  R11
#define Q  R12
#define T  R13

; T.I. Integer Subroutines Definitions
#define IROP1   TOS
#define IROP2L  R10
#define IROP2M  R11
#define IRACL   R12
#define IRACM   R13
#define IRBT    W  

; INDIRECT-THREADED NEXT

.macro NEXT
        MOV @IP+,W      ; fetch word address into W
        MOV @W+,PC      ; fetch code address into PC, W=PFA
.endm

; BRANCH DESTINATION (RELATIVE BRANCH)
; For relative branch addresses, i.e., a branch is ADD @IP,IP

.macro DEST(label)
        DW      label-$
.endm

; HEADER CONSTRUCTION MACROS

.set link = 0
.set envlink = 0

.macro HEADER(asmname,length,litname,action)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      length
        DB      litname
        .align 16
asmname: DW      action
.endm

.macro CODEHEADER(asmname,length,litname)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      length
        DB      litname
        .align 16
asmname: DW     $+2
.endm

.macro HEADLESS(asmname,action)
asmname: DW      action
.endm

.macro IMMED(asmname,length,litname,action)
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      length
        DB      litname
        .align 16
asmname: DW      action
.endm

.macro ENVIRONMENT(asmname,length,litname)
        DW      envlink
        DB      0FFh       ; not immediate
.set envlink = $
        DB      length
        DB      litname
        .align 16
asmname: DW     DOCOLON
.endm

.macro DEFER(asmname,length,litname)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      length
        DB      litname
        .align 16
asmname: DW      DODEFER
.endm

.include "compat.inc"
.include "user.inc"
