; ----------------------------------------------------------------------
; CamelForth for the Texas Instruments MSP430 
; (c) 2013,2014 Bradford J. Rodriguez.
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
; 430g2553install.asm - 
; Interrupt handler installation for MSP430G2553
; B. Rodriguez 20 aug 2013
; ----------------------------------------------------------------------
; REVISION HISTORY
;  2 mar 2014 bjr - adapted from install430g2553.s43 for naken_asm.
; 29 aug 2013 bjr - Created.

; This installs an interrupt handler address in a jump table
; in a 64-byte region of Info ROM.  
; The ROM is copied to TIB [=PAD], the vector is installed
; as a MOV #adrs,PC instruction, and the ROM is erased and 
; reprogrammed (with interrupts disabled!)
; NOTE - if NMI is used it must have a hard-coded vector,
; or be externally disabled for this.

; Example: 3 INSTALL TIMERIRPT
; installs the body of the word TIMERIRPT as interrupt vector #3.
; Note that vector numbering varies among members of the MSP430
; family.

; Vectors should be INSTALLed at compile time.
; NOTE - on the G2553, INSTALLed interrupt vectors are NOT removed
; on the next SCRUB operation.  Be sure to disable all interrupt
; sources before doing a SCRUB.

; DECIMAL 60 CONSTANT VECSSIZE ( only 60 bytes are used )
;   ...defined as VECS_SIZE = 30 (cells) in camel430g2553.asm
; HEX 1080 CONSTANT VECAREA    ( 64 bytes for 'G2553 )
;   ...defined in camel430g2553.asm

;Z INSTALL   n -- | "word" 
; : INSTALL ( n -- | "word" )
;     '               ( CFA of interrupt handler )
;     >BODY           ( address of interrupt handler ( -- n pfa )
;     VECAREA PAD VECSSIZE CMOVE  ( copy vectors to RAM at PAD )
;     SWAP 2* CELLS PAD +    ( -- pfa vecadr )
;     4030 OVER !     ( MOV #,PC instruction )
;     CELL+ !         ( store address of interrupt handler )
;     DINT
;     VECAREA VECSSIZE FLERASE    ( erase info page )
;     PAD VECAREA VECSSIZE D->I   ( copy vecs back to Flash )
;     EINT
;     'SOURCE @ >IN !   ( skip to end of TIB)
; ;

    HEADER(INSTALL,7,"INSTALL",DOCOLON)
        DW  TICK,TOBODY
        DW  lit,VECAREA,XT_PAD,lit,VECS_SIZE*2,CMOVE
        DW  XT_SWAP,TWOSTAR,CELLS,XT_PAD,PLUS
        DW  lit,4030h,OVER,STORE
        DW  XT_CELLPLUS,STORE,D_INT
        DW  lit,VECAREA,lit,VECS_SIZE*2,FLERASE
        DW  XT_PAD,lit,VECAREA,lit,VECS_SIZE*2,DTOI
        DW  E_INT,TICKSOURCE,FETCH,XT_TO_IN,STORE
        DW  EXIT
