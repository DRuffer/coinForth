/**************************************************************************************************
  Filename:       uApp.c
  Revised:        $Date: 2009-05-12 19:18:36 -0700 (Tue, 12 May 2009) $
  Revision:       $Revision: 19944 $

  Description:    ULP app.


  Copyright 2004-2007 Texas Instruments Incorporated. All rights reserved.

  IMPORTANT: Your use of this Software is limited to those specific rights
  granted under the terms of a software license agreement between the user
  who downloaded the software, his/her employer (which must be your employer)
  and Texas Instruments Incorporated (the "License").  You may not use this
  Software unless you agree to abide by the terms of the License. The License
  limits your use, and you acknowledge, that the Software may not be modified,
  copied or distributed unless embedded on a Texas Instruments microcontroller
  or used solely and exclusively in conjunction with a Texas Instruments radio
  frequency transceiver, which is integrated into your product.  Other than for
  the foregoing purpose, you may not use, reproduce, copy, prepare derivative
  works of, modify, distribute, perform, display or sell this Software and/or
  its documentation for any purpose.

  YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
  PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, 
  INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE, 
  NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
  TEXAS INSTRUMENTS OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT,
  NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER
  LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
  INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE
  OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT
  OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
  (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.

  Should you have any questions regarding your right to use this Software,
  contact Texas Instruments Incorporated at www.TI.com. 
**************************************************************************************************/

/*********************************************************************
  This application just blinks LED 1 every 1sec
*********************************************************************/

/*********************************************************************
 * INCLUDES
 */
#include "bcomdef.h"
#include "OSAL.h"
#include "hci.h"
#include "gap.h"
#include "uApp.h"

#if !defined( WIN32 )
  #include "OnBoard.h"
#endif

/* HAL */
#include "hal_lcd.h"
#include "hal_led.h"
#include "hal_key.h"
#include "hal_uart.h"

/* Include this to enable displaying debug messages on GUI - Remove when done debugging */
#include "debug.h"

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * CONSTANTS
 */

/*********************************************************************
 * TYPEDEFS
 */

/*********************************************************************
 * GLOBAL VARIABLES
 */


/*********************************************************************
 * EXTERNAL VARIABLES
 */

/*********************************************************************
 * EXTERNAL FUNCTIONS
 */

/*********************************************************************
 * LOCAL VARIABLES
 */
uint8 uApp_TaskID;   // Task ID for internal task/event processing
                          // This variable will be received when
                          // GenericApp_Init() is called.


/*********************************************************************
 * LOCAL FUNCTIONS
 */
void uApp_HandleKeys( uint8 shift, uint8 keys );
void uApp_UartProcessRxData ( uint8 port, uint8 events );


/*********************************************************************
 * NETWORK LAYER CALLBACKS
 */

/*********************************************************************
 * PUBLIC FUNCTIONS
 */

/*********************************************************************
 * @fn      GenericApp_Init
 *
 * @brief   Initialization function for the Generic App Task.
 *          This is called during initialization and should contain
 *          any application specific initialization (ie. hardware
 *          initialization/setup, table initialization, power up
 *          notificaiton ... ).
 *
 * @param   task_id - the ID assigned by OSAL.  This ID should be
 *                    used to send messages and set timers.
 *
 * @return  none
 */
void uApp_Init( uint8 task_id )
{
  halUARTCfg_t uartConfig;
  
  uApp_TaskID = task_id;

  /* Setup keys */
  HalKeyConfig(false, uApp_HandleKeys);

  /* Setup UART */
  /* UART Configuration */
  uartConfig.configured           = TRUE;
  uartConfig.baudRate             = HAL_UART_BR_38400;
  uartConfig.flowControl          = 0;
  uartConfig.flowControlThreshold = 5;
  uartConfig.rx.maxBufSize        = 128;
  uartConfig.tx.maxBufSize        = 128;
  uartConfig.idleTimeout          = 5;
  uartConfig.intEnable            = TRUE;
  uartConfig.callBackFunc         = uApp_UartProcessRxData;

  /* Start UART */
  HalUARTOpen (0, &uartConfig);

  HalLcdWriteString("uApp started!", false);

  osal_start_timerEx(uApp_TaskID, UAPP_EVENT_1, 1000);
  //osal_set_event(uApp_TaskID, UAPP_EVENT_1);

}

/*********************************************************************
 * @fn      GenericApp_ProcessEvent
 *
 * @brief   Generic Application Task event processor.  This function
 *          is called to process all events for the task.  Events
 *          include timers, messages and any other user defined events.
 *
 * @param   task_id  - The OSAL assigned task ID.
 * @param   events - events to process.  This is a bit map and can
 *                   contain more than one event.
 *
 * @return  none
 */
uint16 uApp_ProcessEvent( uint8 task_id, uint16 events )
{
  if ( events & SYS_EVENT_MSG )
  {
    // return unprocessed events
    return (events ^ SYS_EVENT_MSG);
  }
  
  if ( events & UAPP_EVENT_1)
  {
	  HalLedSet(HAL_LED_4, HAL_LED_MODE_TOGGLE);
	  osal_start_timerEx(uApp_TaskID, UAPP_EVENT_1, 500);
	  //osal_set_event(uApp_TaskID, UAPP_EVENT_1);
	  return events ^ UAPP_EVENT_1;
  }

  // Discard unknown events
  return 0;
}

/*********************************************************************
 * @fn      uApp_HandleKeys
 *
 * @brief   Handles all key events for this device.
 *
 * @param   shift - true if in shift/alt.
 * @param   keys - bit field for key events. Valid entries:
 *                 HAL_KEY_SW_4
 *                 HAL_KEY_SW_3
 *                 HAL_KEY_SW_2
 *                 HAL_KEY_SW_1
 *
 * @return  none
 *********************************************************************/
void uApp_HandleKeys( uint8 shift, uint8 keys )
{ 
  // Shift is used to make each button/switch dual purpose.
  if ( shift )
  {
    if ( keys & HAL_KEY_SW_1 )
    {
    }
    if ( keys & HAL_KEY_SW_2 )
    {
    }
    if ( keys & HAL_KEY_SW_3 )
    {
    }
    if ( keys & HAL_KEY_SW_4 )
    {
    }
  }
  else
  {
    if ( keys & HAL_KEY_SW_1 )
    {
		DebugMsg("DebugMsg example - Toggle LED 1", 0);
		HalLedSet(HAL_LED_1, HAL_LED_MODE_TOGGLE);
    }
    if ( keys & HAL_KEY_SW_2 )
    {

    }
    if ( keys & HAL_KEY_SW_3 )
    {
    }
    if ( keys & HAL_KEY_SW_4 )
    {
    }
  }
}

/*********************************************************************
 * @fn      uApp_HandleKeys
 *
 * @brief   Handles all key events for this device.
 *
 * @param   port - where the Rx data
 *          event - type of event
 *                  HAL_UART_RX_FULL
 *                  HAL_UART_RX_ABOUT_FULL
 *                  HAL_UART_RX_TIMEOUT      
 *                  HAL_UART_TX_FULL         
 *                  HAL_UART_TX_EMPTY        
 *
 * @return  none
 *********************************************************************/
void uApp_UartProcessRxData ( uint8 port, uint8 events )
{
    uint8 rxData[10] = {'\n'};
    uint16 totaluint8Read = 0;

	if (events & (HAL_UART_RX_FULL | HAL_UART_RX_ABOUT_FULL | HAL_UART_RX_TIMEOUT))
	{
        DebugMsg("Received UART Event:", events);
        totaluint8Read = HalUARTRead(0, rxData, 10);
        HalUARTWrite(0, rxData, totaluint8Read);
	}


}

/*********************************************************************
*********************************************************************/
