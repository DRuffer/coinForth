; ( -- ) 
; Multitasking
; Fetch pause vector and execute it. may make a context/task switch
DEFER(XT_PAUSE,5,"pause")
    .dw RAM_PAUSE
    .dw XT_RDEFERFETCH
    .dw XT_RDEFERSTORE
