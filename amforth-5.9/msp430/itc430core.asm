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
; itc430core.asm - Machine Language Primitives - MSP430F1611
; B. Rodriguez  3 Jan 09
; ----------------------------------------------------------------------
; Revision History
; 26 feb 14 bjr - adapted from core430.s43 for naken_asm.
; 26 oct 12 bjr - removed target-specific code and includes to
;		forth430xxx.s43.  This file is now included from that file.
;  1 mar 09 bjr - changed Flash write and erase primitives to correctly
;       write RAM outside Info Flash and Main Flash address limits.


; ----------------------------------------------------------------------
; INTERPRETER LOGIC
; ITC NEXT is defined as
;        MOV @IP+,W      ; 2 fetch word address into W
;        MOV @W+,PC      ; 2 fetch code address into PC, W=PFA

.include "words/execute.asm"
.include "words/lit.asm"
.include "words/exit.asm"
; ----------------------------------------------------------------------
; DEFINING WORDS - ROMable ITC model 

; DOCOLON enters a new high-level thread (colon definition.)
; (internal code fragment, not a Forth word)
DOCOLON: 
        PUSH IP         ; 3 save old IP on return stack
        MOV W,IP        ; 1 set new IP to PFA
        NEXT            ; 4

.include "words/variable.asm"
.include "words/constant.asm"

; DOCON, code action of CONSTANT,
; entered with W=Parameter Field Adrs
; This is also the action of VARIABLE (Harvard model)
; This is also the action of CREATE (Harvard model)
docreate: ; -- a-addr   ; ROMable CREATE fetches address from PFA
DOVAR:  ; -- a-addr     ; ROMable VARIABLE fetches address from PFA
DOCON:  ; -- x          ; CONSTANT fetches cell from PFA to TOS
PFA_DOVARIABLE:
        SUB #2,PSP      ; make room on stack
        MOV TOS,0(PSP)
        MOV @W,TOS      ; fetch from parameter field to TOS
        NEXT

; DOCREATE's action is for a table in RAM.
; DOROM is the code action for a table in ROM;
; it returns the address of the parameter field.

DOROM:  ; -- a-addr     ; Table in ROM: get PFA into TOS
PFA_DOCONSTANT:
        SUB #2,PSP 
        MOV TOS,0(PSP)
        MOV W,TOS
        NEXT

.include "words/user.asm"

; DODOES is the code action of a DOES> clause.  For ITC Forth:
; defined word:  CFA: doescode
;                PFA: parameter field
;
; doescode: MOV #DODOES,PC      ; 16-bit direct jump, in two cells
;           high-level thread
;
; Note that we use JMP DODOES instead of CALL #DODOES because we can 
; efficiently obtain the thread address.  DODOES is entered with W=PFA.
; It enters the high-level thread with the address of the parameter
; field on top of stack.

dodoes: ; -- a-addr     ; 3 for MOV #DODOES,PC
        SUB #2,PSP      ; 1 make room on stack
        MOV TOS,0(PSP)  ; 4
        MOV W,TOS       ; 1 put defined word's PFA in TOS
        PUSH IP         ; 3 save old IP on return stack
        MOV -2(W),IP    ; 3 fetch adrs of doescode from defined word
        ADD #4,IP       ; 1 skip MOV instruction to get thread adrs
        NEXT            ; 4

; OPTION 1              ; OPTION 2
;  MOV #DODOES,PC   3   ;  CALL #DODOES      5
;   ...                 ;   ...
;  PUSH IP          3   ;  POP W            2
;  MOVE -2(W),IP    3   ;  PUSH IP          3
;  ADD #4,IP        1   ;  MOV W,IP         1


; ----------------------------------------------------------------------
; STACK OPERATIONS

.include "words/dup.asm"
.include "words/qdup.asm"
.include "words/drop.asm"
.include "words/swap.asm"
.include "words/over.asm"
.include "words/rot.asm"
.include "words/nip.asm"
.include "words/tuck.asm"

.include "words/to-r.asm"
.include "words/r-from.asm"
.include "words/r-fetch.asm"
.include "words/2-to-r.asm"
.include "words/2-r-from.asm"

.include "words/sp-fetch.asm"
.include "words/sp-store.asm"
.include "words/rp-fetch.asm"
.include "words/rp-store.asm"


; ----------------------------------------------------------------------
; MEMORY OPERATIONS

.include "words/fetch.asm"
.include "words/store.asm"
.include "words/c-fetch.asm"
.include "words/c-store.asm"

; FLASH MEMORY OPERATIONS
; Note that an I! or IC! to a RAM address >FLASHSTART will work -- it 
; will enable the flash, write the RAM, and then disable the flash.
; An FLERASE to a RAM address will merely clear that one RAM cell.

.include "words/flerase.asm"

; Program Space (Flash) operators 

.include "words/i-store.asm"
.include "words/ic-store.asm"
.include "words/i-fetch.asm"
.include "words/ic-fetch.asm"
.include "words/d-to-i.asm"

; ----------------------------------------------------------------------
; ARITHMETIC OPERATIONS

.include "words/plus.asm"
.include "words/plus-store.asm"
.include "words/m-plus.asm"
.include "words/minus.asm"
.include "words/and.asm"
.include "words/or.asm"
.include "words/xor.asm"
.include "words/invert.asm"
.include "words/negate.asm"
.include "words/1-plus.asm"
.include "words/1-minus.asm"
.include "words/byte-swap.asm"
.include "words/2-star.asm"
.include "words/2-slash.asm"
.include "words/lshift.asm"
.include "words/rshift.asm"

; ----------------------------------------------------------------------
; COMPARISON OPERATIONS 

.include "words/zero-equal.asm"
.include "words/zero-less.asm"
.include "words/equal.asm"
.include "words/not-equal.asm"
.include "words/less.asm"
.include "words/greater.asm"
.include "words/u-less.asm"
.include "words/u-greater.asm"

; ----------------------------------------------------------------------
; LOOP AND BRANCH OPERATIONS 
; These use relative branch addresses: a branch is ADD @IP,IP

.include "words/branch.asm"
.include "words/q-branch.asm"
.include "words/do-do.asm"
.include "words/do-loop.asm"
.include "words/do-plusloop.asm"
.include "words/i.asm"
.include "words/j.asm"
.include "words/unloop.asm"

; ----------------------------------------------------------------------
; MULTIPLY AND DIVIDE

.include "words/um-star.asm"
.include "words/um-slash-mod.asm"

; ----------------------------------------------------------------------
; BLOCK AND STRING OPERATIONS

.include "words/fill.asm"
.include "words/cmove.asm"
.include "words/cmove-up.asm"
.include "words/cskip.asm"
.include "words/cscan.asm"
.include "words/s-equal.asm"
.include "words/i-to-d.asm"

; ----------------------------------------------------------------------
; ALIGNMENT AND PORTABILITY OPERATORS 
; Many of these are synonyms for other words,
; and so are defined as CODE words.
.include "words/align.asm"
.include "words/aligned.asm"
.include "words/cellplus.asm"
.include "words/cells.asm"
.include "words/to-body.asm"
