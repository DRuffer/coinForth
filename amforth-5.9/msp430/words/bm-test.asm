;Z CTSTB    c c-addr -- c2	 test bits in memory byte
		CODEHEADER(XT_BM_TEST,5,"bm-test")
		MOV.B	@TOS,TOS
		AND		@PSP+,TOS
		NEXT
