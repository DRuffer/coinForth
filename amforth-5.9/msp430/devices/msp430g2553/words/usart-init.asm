    CODEHEADER(XT_USART,6,"+usart")
        ; USCI_A0
        MOV.B   #06,&P1SEL              ; P1.1,2 are UART
        MOV.B   #06,&P1SEL2             ; P1.1,2 are UART

        BIS.B   #UCSWRST,&UCA0CTL1      ; SWRST while configuring!
        MOV.B   #00h,&UCA0CTL0          ; UART, 8N1, LSB first
        MOV.B   #81h,&UCA0CTL1          ; BRCLK = SMCLK, SWRST set
        MOV.B   #41h,&UCA0BR0           ; 9600 Baud at 8 MHz
        MOV.B   #03h,&UCA0BR1
        MOV.B   #04h,&UCA0MCTL          ; UCBRFx=0, UCBRSx=2 for 9600 baud
        BIC.B   #UCSWRST,&UCA0CTL1      ; done configuring

	NEXT
