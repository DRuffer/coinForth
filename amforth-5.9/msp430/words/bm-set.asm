;Z CSETB	c c-addr -- 	set bits in memory byte
		CODEHEADER(XT_BM_SET,6,"bm-set")
		MOV		@PSP+,W
		BIS.B	W,0(TOS)
		MOV		@PSP+,TOS
		NEXT
