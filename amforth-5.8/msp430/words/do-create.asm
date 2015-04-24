; create a dictionary entry

HEADER(XT_DOCREATE,8,"(create)",DOCOLON)
        DW XT_PARSENAME,XT_WLSCOPE  ; ( -- addr len wid)
	DW XT_HEADER,XT_NEWEST,XT_STORE
	DW XT_EXIT
