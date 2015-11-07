;Z CCLRB	c c-addr -- 	clear bits in memory byte
		CODEHEADER(XT_BM_CLEAR,8,"bm-clear")
		MOV		@PSP+,W
		BIC.B	W,0(TOS)
		MOV		@PSP+,TOS
		NEXT
