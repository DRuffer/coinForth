/***************************************************************************************************
    Filename:       uMain.c
    Revised:        $Date: 2008-09-15 14:26:26 -0700 (Mon, 15 Sep 2008) $
    Revision:       $Revision: 18058 $

    Description:    Startup and shutdown code for ZStack
    Notes:          This version targets the Chipcon CC2420DB

    Copyright (c) 2006 by Texas Instruments, Inc.
    All Rights Reserved.  Permission to use, reproduce, copy, prepare
    derivative works, modify, distribute, perform, display or sell this
    software and/or its documentation for any purpose is prohibited
    without the express written consent of Texas Instruments, Inc.
***************************************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif

/***************************************************************************************************
 * INCLUDES
 ***************************************************************************************************/
#include "hal_types.h"
#include "OSAL.h"
#include "uMain.h"

/* HAL */
#include "hal_drivers.h"
/*
#include "hal_adc.h"
#include "hal_led.h"
#include "hal_lcd.h"
#include "hal_key.h"

*/
char SIM_ISR_ENABLED;

/***************************************************************************************************
 * @fn      main
 * @brief   First function called after startup.
 * @return  don't care
 ***************************************************************************************************/
int uMain( void )
{

  // Turn off interrupts
  osal_int_disable( INTS_ALL );

  // Initialze the driver
  HalDriverInit ();
  
  // Initialize the operating system
  osal_init_system();

  // Allow interrupts
  osal_int_enable( INTS_ALL );

  // No Return from here
  osal_start_system(); 

  return 0;
} // main()


#ifdef __cplusplus
}// extern  "C"
#endif

/***************************************************************************************************
***************************************************************************************************/
