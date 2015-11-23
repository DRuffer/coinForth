/**************************************************************************************************
  Filename:       gapapp.c
  Revised:        $Date: 2013-08-26 15:11:57 -0700 (Mon, 26 Aug 2013) $
  Revision:       $Revision: 35113 $

  Description:    GAP Test Application.


  Copyright 2009 - 2013 Texas Instruments Incorporated. All rights reserved.

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
 * INCLUDES
 */
#include "bcomdef.h"
#include "OSAL.h"
#include "osal_cbtimer.h"
#include "osal_bufmgr.h"
#include "hci.h"
#include "l2cap.h"
#include "gap.h"
#include "gapapp.h"

/* HAL */
#include "hal_key.h"
#include "hal_lcd.h"
#include "hal_led.h"

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * CONSTANTS
 */

#define GAP_MASTER_DEVICE_TYPE      0
#define GAP_SLAVE_DEVICE_TYPE       1

#if !defined ( GAP_DEVICE_TYPE )
  #define GAP_DEVICE_TYPE             GAP_MASTER_DEVICE_TYPE
  //#define GAP_DEVICE_TYPE             GAP_SLAVE_DEVICE_TYPE
#endif


// Scan Parameter Constants
/*
#define SCAN_DURATION               10000     // 10 Seconds
#define SCAN_INTERVAL               480       // N * 0.62 ms
#define SCAN_WINDOW                 500       // N * 0.62 ms
*/
/*
#define SCAN_DURATION               10000     // 10 Seconds
#define SCAN_INTERVAL               1000      // N * 0.62 ms
#define SCAN_WINDOW                 100       // N * 0.62 ms
*/

#define SCAN_DURATION               5000      // 5 Seconds
#define SCAN_INTERVAL               480       // 300 ms (n * 0.625 s)
#define SCAN_WINDOW                 240       // 150 ms (n * 0.625 s)

#define SCAN_MODE                   DEVDISC_MODE_GENERAL
#define SCAN_NAME_MODE              TRUE
#define SCAN_ADDRTYPE               ADDRTYPE_PUBLIC
#define SCAN_WHITELIST              FALSE

// Connection Parameters
#define CONN_INTERVAL_MIN           80
#define CONN_INTERVAL_MAX           80
#define CONN_LATENCY                0
#define CONN_SUPERVISION_TIMEOUT    1000
#define CONN_MIN_CE                 1000
#define CONN_MAX_CE                 2000

// Advertisement Parameter Constants
#define ADV_MIN_INTERVAL      160       // 100 MS (n * 625 usec)
#define ADV_MAX_INTERVAL      160       // 100 MS (n * 625 usec)
#define ADV_CHANNELS          0x07      // All Channels
#define ADV_FILTER_POLICY     0x00      // No filters

#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  #define ADV_TYPE            GAP_ADTYPE_ADV_NONCONN_IND
#else
  #define ADV_TYPE            GAP_ADTYPE_ADV_IND
#endif

/*********************************************************************
 * TYPEDEFS
 */

// L2CAP Data info
typedef struct
{
  uint16 connHandle;
  uint16 CID;
  uint8 len;
} l2capData_t;

// L2CAP Command info
typedef struct
{
  uint16 connHandle;
  uint8 code;
  l2capSignalCmd_t cmd;
} l2capCmd_t;

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
uint8 GAPApp_TaskID;   // Task ID for internal task/event processing

// "02:01:03:0A:09:50:65:64:6F:6D:65:74:65:72"
const uint8 advertData[] =
{
  0x02,   // length of this data
  0x01,   // AD Type = Flags
  0x03,   // Limited and general
  0x0A,   // length of this data
  0x09,   // AD Type = Complete local name
  0x50,   // 'P'
  0x65,   // 'e'
  0x64,   // 'd'
  0x6F,   // 'o'
  0x6D,   // 'm'
  0x65,   // 'e'
  0x74,   // 't'
  0x65,   // 'e'
  0x72    // 'r'
};

// "03:10:5A:A5:04:10:55:55:34:04:10:44:44:01:04:10:33:33:17:04:10:22:22:00:00"
const uint8 rspData[] =
{
  0x03,   // length of this data
  0x10,   // AD Type = Attribute
  0x5A,   // Sensor Profile UUID LO
  0xA5,   // Sensor Profile UUID HI
  0x04,   // length of this data
  0x10,   // AD Type = Attribute
  0x55,   // Sensor Description UUID LO
  0x55,   // Sensor Description UUID HI
  0x34,   // Description ("Temp")
  0x04,   // length of this data
  0x10,   // AD Type = Attribute
  0x44,   // Sensor Postfix UUID LO
  0x44,   // Sensor Postfix UUID HI
  0x01,   // Postfix ("C")
  0x04,   // length of this data
  0x10,   // AD Type = Attribute
  0x33,   // Sensor value UUID LO
  0x33,   // Sensor value UUID HI
  0x17,   // Value ("23")
  0x04,   // length of this data
  0x10,   // AD Type = Attribute
  0x22,   // Sensor location UUID LO
  0x22,   // Sensor location UUID HI
  0x00,   // location ("Outside")
  0x00    // End of Data
};


// Scan Parameters
#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  static gapDevDiscReq_t scanParams;
#endif

// Advertisement parameters
static gapAdvertisingParams_t AdvParams;
static uint8 directedAddrType = ADDRTYPE_PUBLIC;
static uint8 directedAddr[B_ADDR_LEN] = {0};

static uint32 signCounter = 0;


/*********************************************************************
 * LOCAL FUNCTIONS
 */
void uApp_HandleKeys( uint8 shift, uint8 keys );
void uApp_UartProcessRxData ( uint8 port, uint8 events );

void gapapp_ProcessL2CAPSignalEvent( l2capSignalEvent_t *pCmd );
static void gapapp_SendDataTimerCB( uint8 *pData );
void gapapp_SendCmdTimerCB( uint8 *pData );

/*********************************************************************
 * NETWORK LAYER CALLBACKS
 */

/*********************************************************************
 * PUBLIC FUNCTIONS
 */

/*********************************************************************
 * LOCAL FUNCTION PROTOTYPES
 */
static void gapappProcessOSALMsg( osal_event_hdr_t *pMsg );

static void gapapp_TerminateTimerCB( uint8 *pData );

/*********************************************************************
 * @fn      GAPApp_Init
 *
 * @brief   Initialization function for the GAP Test App Task.
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
void GAPApp_Init( uint8 task_id )
{
  GAPApp_TaskID = task_id;

#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  // Scan Parameters
  scanParams.taskID = GAPApp_TaskID;
  scanParams.mode = SCAN_MODE;
  scanParams.activeScan = SCAN_NAME_MODE; // Active Scan
  scanParams.whiteList = SCAN_WHITELIST;
#endif

  // Advertisement Parameters
  AdvParams.eventType = ADV_TYPE;
  AdvParams.initiatorAddrType = directedAddrType;
  osal_memcpy( AdvParams.initiatorAddr, directedAddr, B_ADDR_LEN );
  AdvParams.channelMap = ADV_CHANNELS;   // All channels
  AdvParams.filterPolicy = ADV_FILTER_POLICY; // Allow any scans

  // Register as GAP Application
  HalLcdWriteString("GAP Init", HAL_LCD_LINE_2);
#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  VOID GAP_DeviceInit( GAPApp_TaskID, GAP_PROFILE_CENTRAL, 12, NULL, NULL, &signCounter  );
#else
  VOID GAP_DeviceInit( GAPApp_TaskID, GAP_PROFILE_PERIPHERAL, 0, NULL, NULL, &signCounter );
#endif

  VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_OFF );

  // Register with L2CAP ATT channel
  L2CAP_RegisterApp( GAPApp_TaskID, L2CAP_CID_ATT );

  // Register with L2CAP SMP channel
  L2CAP_RegisterApp( GAPApp_TaskID, L2CAP_CID_SMP );
}

/*********************************************************************
 * @fn      GAPApp_ProcessEvent
 *
 * @brief   GAP Test Application Task event processor.  This function
 *          is called to process all events for the task.  Events
 *          include timers, messages and any other user defined events.
 *
 * @param   task_id  - The OSAL assigned task ID.
 * @param   events - events to process.  This is a bit map and can
 *                   contain more than one event.
 *
 * @return  none
 */
uint16 GAPApp_ProcessEvent( uint8 task_id, uint16 events )
{
  if ( events & SYS_EVENT_MSG )
  {
    uint8 *pMsg;

    while ( (pMsg = osal_msg_receive( GAPApp_TaskID )) != NULL )
    {
      gapappProcessOSALMsg( (osal_event_hdr_t *)pMsg );

      // Release the OSAL message
      VOID osal_msg_deallocate( pMsg );
    }

    // return unprocessed events
    return (events ^ SYS_EVENT_MSG);
  }

  if ( events & GAPAPP_START_ADVERTISING_EVT )
  {
    // Start Advertising
    VOID GAP_MakeDiscoverable( GAPApp_TaskID, &AdvParams );
    HalLcdWriteString("Start Advertising", HAL_LCD_LINE_1);

    return (events ^ GAPAPP_START_ADVERTISING_EVT);
  }

  if ( events & GAPAPP_END_ADVERTISING_EVT )
  {
    // Turn off advertising
    VOID GAP_EndDiscoverable( GAPApp_TaskID );
    HalLcdWriteString("End Advertising", HAL_LCD_LINE_1);

    return (events ^ GAPAPP_END_ADVERTISING_EVT);
  }

#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  if ( events & GAPAPP_START_DISCOVERY_EVT )
  {
    VOID GAP_DeviceDiscoveryRequest( &scanParams );
    HalLcdWriteString("Discovery Started", HAL_LCD_LINE_1);

    return (events ^ GAPAPP_START_DISCOVERY_EVT);
  }
#endif

  // Discard unknown events
  return 0;
}

/*********************************************************************
 * @fn      gapappProcessOSALMsg
 *
 * @brief   Process an incoming task message.
 *
 * @param   pMsg - message to process
 *
 * @return  none
 */
static void gapappProcessOSALMsg( osal_event_hdr_t *pMsg )
{
  switch ( pMsg->event )
  {
    // GAP is done with initialization
    case GAP_DEVICE_INIT_DONE_EVENT:
      if ( pMsg->status == SUCCESS )
      {
#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
        // Start a discovery period.
        osal_set_event( GAPApp_TaskID, GAPAPP_START_DISCOVERY_EVT );
#else
        // Write the advertising data
        VOID GAP_UpdateAdvertisingData( GAPApp_TaskID, TRUE,
                         sizeof ( advertData ), (uint8 *)advertData );
        HalLcdWriteString("Advertising Data Sent", HAL_LCD_LINE_2);
#endif
      }
      break;

    case GAP_DEVICE_DISCOVERY_EVENT:
      // Let's pick the first one to connect with.
      if ( (pMsg->status == SUCCESS) && (((gapDevDiscEvent_t *)pMsg)->numDevs > 0) )
      {
        gapEstLinkReq_t params;
        gapDevRec_t *devList = ((gapDevDiscEvent_t *)pMsg)->devList;

        // Connect with
        params.taskID = GAPApp_TaskID;
        params.highDutyCycle = FALSE;
        params.whiteList = WL_NOTUSED;
        params.addrTypePeer = devList->addrType;
        osal_memcpy( params.peerAddr, devList->addr, B_ADDR_LEN );

        VOID GAP_EstablishLinkReq( &params );
        HalLcdWriteString("Establish Link", HAL_LCD_LINE_1);
      }
      else
      {
        // Start another discovery period.
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_START_DISCOVERY_EVT, 100 );
        HalLcdWriteString("Restart Disc", HAL_LCD_LINE_2);
      }
      break;

    case GAP_ADV_DATA_UPDATE_EVENT:
      {
        gapAdvDataUpdateEvent_t *rsp = (gapAdvDataUpdateEvent_t *)pMsg;

        if ( rsp->hdr.status == SUCCESS )
        {
          if ( rsp->adType )
          {
            // Send the SCAN_RSP data
            VOID GAP_UpdateAdvertisingData( GAPApp_TaskID, FALSE,
                             sizeof ( rspData ), (uint8 *)rspData );
            HalLcdWriteString("SCAN_RSP Data Sent", HAL_LCD_LINE_2);
          }
          else
          {
            // Make discoverable
            osal_set_event( GAPApp_TaskID, GAPAPP_START_ADVERTISING_EVT );
          }
        }
      }
      break;

    case GAP_MAKE_DISCOVERABLE_EVENT:
      if ( pMsg->status == SUCCESS )
      {
        // Setup timer to end advertising
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_END_ADVERTISING_EVT, 5000 );
      }
      break;

    case GAP_END_DISCOVERABLE_EVENT:
      if ( pMsg->status == SUCCESS )
      {
        // Start another scan period.
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_START_ADVERTISING_EVT, 500 );
      }
      break;

    case GAP_EST_LINK_REQ_EVENT:
      if ( pMsg->status == SUCCESS )
      {
#if defined ( L2CAP_TEST )
  #if (GAP_DEVICE_TYPE == GAP_SLAVE_DEVICE_TYPE)
        l2capCmd_t *pCmd = (l2capCmd_t *)osal_mem_alloc( sizeof ( l2capCmd_t ) );

        // Send Connection Parameters Update Request in 5 Seconds
        if ( pCmd )
        {
          gapEstLinkReqEvent_t *rsp = (gapEstLinkReqEvent_t *)pMsg;

          pCmd->connHandle = rsp->connectionHandle;

          pCmd->code = L2CAP_PARAM_UPDATE_REQ;
          pCmd->cmd.updateReq.interval_min = 75;
          pCmd->cmd.updateReq.interval_max = 85;
          pCmd->cmd.updateReq.latency = 0;
          pCmd->cmd.updateReq.timeout = 1000;

          osal_CbTimerStart( gapapp_SendCmdTimerCB, (uint8 *)pCmd, 2000, NULL );
        }
  #else
        HalLcdWriteString("Wait 4 Update Evt", HAL_LCD_LINE_3);
  #endif
#elif (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
        gapEstLinkReqEvent_t *rsp = (gapEstLinkReqEvent_t *)pMsg;
        osal_CbTimerStart( gapapp_TerminateTimerCB, (uint8 *)rsp->connectionHandle,  5000, NULL );
#endif
        HalLcdWriteString("Link Established", HAL_LCD_LINE_1);
        VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_ON );
      }
      break;

    case GAP_LINK_UPDATE_EVENT:
      if ( pMsg->status == SUCCESS )
      {
#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
        l2capCmd_t *pCmd = (l2capCmd_t *)osal_mem_alloc( sizeof ( l2capCmd_t ) );

        // Send Information Request in 5 Seconds
        if ( pCmd )
        {
          gapLinkUpdateEvent_t *rsp = (gapLinkUpdateEvent_t *)pMsg;

          pCmd->connHandle = rsp->connectionHandle;

          pCmd->code = L2CAP_INFO_REQ;
          pCmd->cmd.infoReq.infoType = L2CAP_INFO_EXTENDED_FEATURES;

          osal_CbTimerStart( gapapp_SendCmdTimerCB, (uint8 *)pCmd, 2000, NULL );
        }
#endif
        HalLcdWriteString("Link Update Ok", HAL_LCD_LINE_3);
      }
      else
      {
        HalLcdWriteString("Link Update Err", HAL_LCD_LINE_3);
      }
      break;

    case GAP_TERMINATE_LINK_EVENT:
      if ( pMsg->status == SUCCESS )
      {
        HalLcdWriteString("Link Ended", HAL_LCD_LINE_1);
        VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_OFF );
      }
      break;

    case L2CAP_DATA_EVENT:
      {
        l2capDataEvent_t *pData = (l2capDataEvent_t *)pMsg;

        // Display received data
        if ( pData->pkt.CID == L2CAP_CID_ATT )
        {
          l2capData_t *pData = (l2capData_t *)osal_mem_alloc( sizeof ( l2capData_t ) );

          // Send data over SMP channel in 5 Seconds.
          if ( pData )
          {
            pData->connHandle = pData->connHandle;
            pData->CID = L2CAP_CID_SMP;
            pData->len = 23;

            osal_CbTimerStart( gapapp_SendDataTimerCB, (uint8 *)pData,  2000, NULL );
          }

          HalLcdWriteString("ATT Data Rx", HAL_LCD_LINE_3);
        }
        else
        {
          uint16 *pConnHandle = (uint16 *)osal_mem_alloc( sizeof ( uint16 ) );

          // Terminate link in 5 Seconds.
          if ( pConnHandle )
          {
            *pConnHandle = pData->connHandle;
            osal_CbTimerStart( gapapp_TerminateTimerCB, (uint8 *)pConnHandle,
                               5000, NULL );
          }

          HalLcdWriteString("SMP Data Rx", HAL_LCD_LINE_3);
        }

        // Free the payload
        osal_bm_free( pData->pkt.payload );
        pData->pkt.payload = NULL;
      }
      break;

    case L2CAP_SIGNAL_EVENT:
      gapapp_ProcessL2CAPSignalEvent( (l2capSignalEvent_t *)pMsg );
      break;
  }
}

/*********************************************************************
 * @fn      GAPApp_HandleKeys
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
void GAPApp_HandleKeys( uint8 shift, uint8 keys )
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

static void gapapp_TerminateTimerCB( uint8 *pData )
{
  if ( pData )
  {
    uint16 *connHandle = (uint16 *)pData;

    HalLcdWriteString("Terminate Conn", HAL_LCD_LINE_2);

    GAP_TerminateLinkReq( GAPApp_TaskID, *connHandle, HCI_DISCONNECT_REMOTE_USER_TERM );

    osal_mem_free( pData );
  }
}

/*********************************************************************
 * @fn      gapapp_ProcessL2CAPSignalEvent
 *
 * @brief   Process L2CAP Signaling messages.
 *
 * @param   pCmd - pointer to received command
 *
 * @return  none
 *********************************************************************/
void gapapp_ProcessL2CAPSignalEvent( l2capSignalEvent_t *pCmd )
{
  // Process the signaling command
  switch ( pCmd->code )
  {
    case L2CAP_CMD_REJECT:
      HalLcdWriteString("Cmd Reject Rx", HAL_LCD_LINE_3);

#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
      {
        l2capData_t *pData = (l2capData_t *)osal_mem_alloc( sizeof ( l2capData_t ) );

        // Send data over ATT channel in 5 Seconds.
        if ( pData )
        {
          pData->connHandle = pCmd->connHandle;
          pData->CID = L2CAP_CID_ATT;
          pData->len = 20;

          osal_CbTimerStart( gapapp_SendDataTimerCB, (uint8 *)pData, 2000, NULL );
        }
      }
#endif
      break;

    case L2CAP_PARAM_UPDATE_RSP:
      if ( pCmd->hdr.status == SUCCESS )
      {
        HalLcdWriteString("Update Rsp Rx", HAL_LCD_LINE_3);
      }
      else  if ( pCmd->hdr.status == bleTimeout )
      {
        HalLcdWriteString("Update Rsp Timeout", HAL_LCD_LINE_3);
      }
      else
      {
        HalLcdWriteString("Update Rsp Err", HAL_LCD_LINE_3);
      }
      break;

    default:
      // Unknown command
      break;
  }
}

/*********************************************************************
 * @fn      gapapp_SendDataTimerCB
 *
 * @brief   Send data over an L2CAP channel.
 *
 * @param   pData - pointer to data
 *
 * @return  none
 *********************************************************************/
void gapapp_SendDataTimerCB( uint8 *pData )
{
  if ( pData )
  {
    l2capPacket_t pkt;
    l2capData_t *data = (l2capData_t *)pData;

    // Allocate space for L2CAP packet
    pkt.payload = (uint8 *)L2CAP_bm_alloc( data->len );
    if ( pkt.payload != NULL )
    {
      uint8 i;

      pkt.CID = data->CID;
      pkt.len = data->len;

      // Set data values to be sent out
      for ( i = 0; i < pkt.len; i++ )
      {
        pkt.payload[i] = i;
      }

      if ( L2CAP_SendData( data->connHandle, &pkt ) == SUCCESS )
      {
        if ( pkt.CID == L2CAP_CID_ATT )
        {
          HalLcdWriteString("ATT Data Tx", HAL_LCD_LINE_3);
        }
        else
        {
          HalLcdWriteString("SMP Data Tx", HAL_LCD_LINE_3);
        }
      }
      else
      {
        HalLcdWriteString("Data Tx Err", HAL_LCD_LINE_3);
        osal_bm_free( pkt.payload );
      }
    }

    osal_mem_free( pData );
  }
}


/*********************************************************************
 * @fn      gapapp_SendCmdTimerCB
 *
 * @brief   Send L2CAP command.
 *
 * @param   pData - pointer to data
 *
 * @return  none
 *********************************************************************/
void gapapp_SendCmdTimerCB( uint8 *pData )
{
  if ( pData )
  {
    l2capCmd_t *pCmd = (l2capCmd_t *)pData;

    if ( pCmd->code == L2CAP_PARAM_UPDATE_REQ )
    {
      if ( L2CAP_ConnParamUpdateReq( GAPApp_TaskID, pCmd->connHandle, &pCmd->cmd.updateReq ) == SUCCESS )
      {
        HalLcdWriteString("Update Req Tx", HAL_LCD_LINE_3);
      }
      else
      {
        HalLcdWriteString("Update Req Tx Err", HAL_LCD_LINE_3);
      }
    }
    else
    {
      if ( L2CAP_InfoReq( GAPApp_TaskID, pCmd->connHandle, &pCmd->cmd.infoReq ) == SUCCESS )
      {
        HalLcdWriteString("Info Req Tx", HAL_LCD_LINE_3);
      }
      else
      {
        HalLcdWriteString("Info Req Tx Err", HAL_LCD_LINE_3);
      }
    }

    osal_mem_free( pData );
  }
}

/*********************************************************************
*********************************************************************/
