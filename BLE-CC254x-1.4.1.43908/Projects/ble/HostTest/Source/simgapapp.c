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
#include "hci.h"
#include "gap.h"
#include "simgapapp.h"

/* HAL */
#include "hal_key.h"
#include "hal_lcd.h"
#include "hal_led.h"

#define HCI_SIMULATOR

#if defined ( HCI_SIMULATOR )
  /* Include this to enable displaying debug messages on GUI - Remove when done debugging */
  #include "debug.h"
#else
  #define DebugMsg( a, b )
#endif
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
#define SCAN_DURATION               10000     // 10 Seconds
#define SCAN_INTERVAL               100       // N * 0.62 ms
#define SCAN_WINDOW                 1000      // N * 0.62 ms
#define SCAN_MODE                   DEVDISC_MODE_GENERAL
#define SCAN_NAME_MODE              TRUE
#define SCAN_ADDRTYPE               ADDRTYPE_PUBLIC
#define SCAN_WHITELIST              FALSE

// Connection Parameters
#define CONN_INTERVAL_MIN           80
#define CONN_INTERVAL_MAX           80
#define CONN_LATENCY                0
#define CONN_SUPERVISION_TIMEOUT    100
#define CONN_MIN_CE                 1000
#define CONN_MAX_CE                 2000

// Advertisement Parameter Constants
#define ADV_MIN_INTERVAL      480
#define ADV_MAX_INTERVAL      480
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

#if defined ( HCI_SIMULATOR )
/*********************************************************************
 * HCISim
 */
  uint8 hciGapTaskID = 0;
  uint8 hciAdvertCounter = 0;
  uint16 connHandle = 1;

  static void generateHCICommandCompleteEvent( uint16 opCode, uint8 len, uint8 *pData );
  static void generateHCIDisconnectionCompleteEvent( uint8 status, uint16 connHandle, uint8 reason );
  static void generateHCIConnCompleteEvent( uint8 role,
                         uint8 peerAddrType, uint8 *peerAddr,
                         uint16 connInterval, uint16 connLatency,
                         uint16 connTimeout, uint8 clockAccuracy );

  static void generateAvertRptEvent( hciEvt_DevInfo_t *devInfo );
  static void gapappSendAdvPkt( void );
  static void displayScanResults( gapDevDiscEvent_t *pkt );
#endif // HCI_SIMULATOR

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
  scanParams.scanDuration = SCAN_DURATION;
  scanParams.scanInterval = SCAN_INTERVAL;
  scanParams.scanWindow = SCAN_WINDOW;
  scanParams.mode = SCAN_MODE;
  scanParams.activeScan = SCAN_NAME_MODE; // Active Scan
  scanParams.addrType = SCAN_ADDRTYPE;
  scanParams.whiteList = SCAN_WHITELIST;
#endif

  // Advertisement Parameters
  AdvParams.minInterval = ADV_MIN_INTERVAL;
  AdvParams.maxInterval = ADV_MAX_INTERVAL;
  AdvParams.eventType = ADV_TYPE;
  AdvParams.initiatorAddrType = directedAddrType;
  osal_memcpy( AdvParams.initiatorAddr, directedAddr, B_ADDR_LEN );
  AdvParams.channelMap = ADV_CHANNELS;   // All channels
  AdvParams.filterPolicy = ADV_FILTER_POLICY; // Allow any scans

  // Register as GAP Application
  HalLcdWriteString("GAP Init", false);
#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  VOID GAP_DeviceInit( GAPApp_TaskID, GAP_PROFILE_CENTRAL, 12 );
#else
  VOID GAP_DeviceInit( GAPApp_TaskID, GAP_PROFILE_PERIPHERAL, 0 );
#endif

  VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_OFF );
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

#if defined ( HCI_SIMULATOR )
  if ( events & GAPAPP_SEND_HCI_ADV_PKT_EVT )
  {
    gapappSendAdvPkt();
    return (events ^ GAPAPP_SEND_HCI_ADV_PKT_EVT);
  }
#endif // HCI_SIMULATOR

  if ( events & GAPAPP_START_ADVERTISING_EVT )
  {
    // Start Advertising
    DebugMsg( "Made Discoverable: ", 0 );
    VOID GAP_MakeDiscoverable( GAPApp_TaskID, &AdvParams );

    return (events ^ GAPAPP_START_ADVERTISING_EVT);
  }

  if ( events & GAPAPP_END_ADVERTISING_EVT )
  {
    // Turn off advertising
    VOID GAP_EndDiscoverable( GAPApp_TaskID );

    return (events ^ GAPAPP_END_ADVERTISING_EVT);
  }

#if (GAP_DEVICE_TYPE == GAP_MASTER_DEVICE_TYPE)
  if ( events & GAPAPP_START_DISCOVERY_EVT )
  {
    VOID GAP_DeviceDiscoveryRequest( &scanParams );
    HalLcdWriteString("Discovery Started", false);

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
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_START_DISCOVERY_EVT, 100 );
#else
        // Write the advertising data
        VOID GAP_UpdateAdvertisingData( GAPApp_TaskID, TRUE,
                         sizeof ( advertData ), (uint8 *)advertData );
        HalLcdWriteString("Advertising Data Sent", false);
#endif
      }
      break;

    case GAP_DEVICE_DISCOVERY_EVENT:
#if defined ( HCI_SIMULATOR )
      displayScanResults( (gapDevDiscEvent_t *)pMsg );
#endif
      // Let's pick the first one to connect with.
      if ( (pMsg->status == SUCCESS) && (((gapDevDiscEvent_t *)pMsg)->numDevs > 0) )
      {
        gapEstLinkReq_t params;
        gapDevRec_t *devList = ((gapDevDiscEvent_t *)pMsg)->devList;

        // Connect with
        params.taskID = GAPApp_TaskID;
        params.scanInterval = SCAN_INTERVAL;
        params.scanWindow = SCAN_WINDOW;
        params.whiteList = WL_NOTUSED;
        params.addrTypePeer = devList->addrType;
        osal_memcpy( params.peerAddr, devList->addr, B_ADDR_LEN );
        params.connIntervalMin = CONN_INTERVAL_MIN;
        params.connIntervalMax = CONN_INTERVAL_MAX;
        params.connLatency = CONN_LATENCY;
        params.supervisionTimeout = CONN_SUPERVISION_TIMEOUT;
        params.minLen = CONN_MIN_CE;
        params.maxLen = CONN_MAX_CE;

        VOID GAP_EstablishLinkReq( &params );
      }
      else
      {
        // Start another discovery period.
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_START_DISCOVERY_EVT, 2000 );
      }
      break;

    case GAP_ADV_DATA_UPDATE_EVENT:
      {
        gapAdvDataUpdateEvent_t *rsp = (gapAdvDataUpdateEvent_t *)pMsg;

        DebugMsg( "GAP_ADV_DATA_UPDATE_EVENT: ", 0 );

        if ( rsp->hdr.status == SUCCESS )
        {
          if ( rsp->adType )
          {
            // Send the SCAN_RSP data
            VOID GAP_UpdateAdvertisingData( GAPApp_TaskID, FALSE,
                             sizeof ( rspData ), (uint8 *)rspData );
            HalLcdWriteString("SCAN_RSP Data Sent", false);
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
#if defined ( HCI_SIMULATOR )
        gapMakeDiscoverableRspEvent_t *rsp = (gapMakeDiscoverableRspEvent_t *)pMsg;
        DebugMsg(   "GAP_MAKE_DISCOVERABLE_EVENT: SUCCESS", 0 );
        DebugMsg(   "---->Interval: ", rsp->interval );
#endif
        // Setup timer to end advertising
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_END_ADVERTISING_EVT, 5000 );
      }
      else
      {
        DebugMsg(   "GAP_MAKE_DISCOVERABLE_EVENT: ", pMsg->status );
      }
      break;

    case GAP_END_DISCOVERABLE_EVENT:
      if ( pMsg->status == SUCCESS )
      {
        DebugMsg(   "GAP_END_DISCOVERABLE_EVENT: SUCCESS", 0 );

        // Start another scan period.
        osal_start_timerEx( GAPApp_TaskID, GAPAPP_START_ADVERTISING_EVT, 5000 );
      }
      else
      {
        DebugMsg(   "GAP_END_DISCOVERABLE_EVENT: ", pMsg->status );
      }
      break;

    case GAP_EST_LINK_REQ_EVENT:
      if ( pMsg->status == SUCCESS )
      {
        gapEstLinkReqEvent_t *rsp = (gapEstLinkReqEvent_t *)pMsg;
        uint16 *connHandle = (uint16 *)osal_mem_alloc( sizeof ( uint16 ) );

        DebugMsg(   "GAP_EST_LINK_REQ_EVENT: SUCCESS", 0 );

        // Terminate link in 10 Seconds.
        if ( connHandle )
        {
          *connHandle = rsp->connectionHandle;
          osal_CbTimerStart( gapapp_TerminateTimerCB, (uint8 *)connHandle,
                                      5000, NULL );
        }
        VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_ON );
      }
      else
      {
        DebugMsg(   "GAP_EST_LINK_REQ_EVENT: ", pMsg->status );
      }
      break;

    case GAP_TERMINATE_LINK_EVENT:
      if ( pMsg->status == SUCCESS )
      {
#if defined ( HCI_SIMULATOR )
        gapTerminateLinkEvent_t *rsp = (gapTerminateLinkEvent_t *)pMsg;

        DebugMsg(   "GAP_TERMINATE_LINK_EVENT: SUCCESS", 0 );

        DebugMsg(   "-->connectionHandle: ", rsp->connectionHandle );
        DebugMsg(   "-->reason: ", rsp->reason );
#endif
        VOID HalLedSet( HAL_LED_2, HAL_LED_MODE_OFF );
      }
      else
      {
        DebugMsg(   "GAP_TERMINATE_LINK_EVENT: ", pMsg->status );
      }
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

    DebugMsg(   "gapapp_TerminateTimerCB: ", *connHandle );

    GAP_TerminateLinkReq( GAPApp_TaskID, *connHandle, HCI_DISCONNECT_REMOTE_USER_TERM );

    osal_mem_free( pData );
  }
}

/*********************************************************************
 * Dummy functions
 *********************************************************************/

#if defined ( HCI_SIMULATOR )

Status_t HCI_ReadBDADDRCmd( void )
{
  uint8 buf[B_ADDR_LEN+1];

  DebugMsg( "#HCI_ReadBDADDRCmd", 0 );

  buf[0] = SUCCESS;
  generateHCICommandCompleteEvent( HCI_READ_BD_ADDR, (B_ADDR_LEN+1), buf );

  return ( SUCCESS );
}

Status_t HCI_BLEReadBufSizeCmd( void )
{
  hciRetParam_LeReadBufSize_t pkt;

  DebugMsg( "#HCI_BLEReadBufSizeCmd", 0 );

  pkt.status = SUCCESS;
  pkt.dataPktLen = 100;
  pkt.numDataPkts = 2;
  generateHCICommandCompleteEvent( HCI_BLE_READ_BUFFER_SIZE,
                  sizeof (hciRetParam_LeReadBufSize_t ), (uint8*)&pkt );
  return ( SUCCESS );
}

Status_t HCI_BLESetScanParamCmd( hciParam_SetScanParam_t *param)
{
  uint8 stat = SUCCESS;

  DebugMsg( "#HCI_BLESetScanParamCmd", 0 );

  generateHCICommandCompleteEvent( HCI_SET_SCAN_PARAM, 1, &stat );
  return ( SUCCESS );
}

Status_t HCI_BLESetAdvParamCmd( hciParam_SetAdvParam_t *param)
{
  uint8 stat = SUCCESS;

  DebugMsg( "#HCI_BLESetAdvParamCmd", 0 );

  generateHCICommandCompleteEvent( HCI_BLE_SET_ADV_PARAM, 1, &stat );

  return ( SUCCESS );
}

Status_t HCI_BLEWriteScanRspDataCmd( hciParam_SetScanRsp_t *param)
{
  uint8 stat = SUCCESS;

  DebugMsg( "#HCI_BLEWriteScanRspDataCmd", 0 );

  generateHCICommandCompleteEvent( HCI_WRITE_SCAN_RSP_DATA, 1, &stat );

  return ( SUCCESS );
}

Status_t HCI_BLEWriteAdvDataCmd( hciParam_WriteAdvData_t *param )
{
  uint8 stat = SUCCESS;

  DebugMsg( "#HCI_BLEWriteAdvDataCmd", 0 );

  generateHCICommandCompleteEvent( HCI_WRITE_ADV_DATA, 1, &stat );

  return ( SUCCESS );
}

Status_t HCI_BLEWriteAdvEnableCmd( uint8 *pOnOff )
{
  uint8 buf[3];

  buf[0] = SUCCESS;
  buf[1] = 0x05;
  buf[2] = 0x00;

  if ( *pOnOff == 0 )
    DebugMsg( "#HCI_BLEWriteAdvEnableCmd - Stopped", 0 );
  else
    DebugMsg( "#HCI_BLEWriteAdvEnableCmd - Started", 0 );

  generateHCICommandCompleteEvent( HCI_BLE_WRITE_ADV_ENABLE, 3, buf );

  return ( SUCCESS );
}

Status_t HCI_BLEWriteScanEnableCmd( hciParam_WriteScanEnable_t *param )
{
  uint8 stat = SUCCESS;

  DebugMsg( "#HCI_BLEWriteScanEnableCmd: ", param->scanEnable );

  if ( param->scanEnable )
  {
    hciAdvertCounter = 19;
    osal_start_timerEx( GAPApp_TaskID, GAPAPP_SEND_HCI_ADV_PKT_EVT, 100 );
  }

  generateHCICommandCompleteEvent( HCI_BLE_WRITE_SCAN_ENABLE, 1, &stat );
  return ( SUCCESS );
}

Status_t HCI_BLECreateLLConnCmd( hciParam_CreateLL_t *param )
{

  DebugMsg( "#HCI_BLECreateLLConnCmd", 0 );

  generateHCIConnCompleteEvent( 0x00 /*master*/, param->addrTypePeer, param->peerAddr,
                        param->connIntervalMin, param->connLatency,
                        param->connTimeout, 0x50 );

  return ( SUCCESS );
}

Status_t HCI_DisconnectCmd( hciParam_disconnect_t *pParam )
{

  DebugMsg( "#HCI_DisconnectCmd", 0 );

  generateHCIDisconnectionCompleteEvent( SUCCESS, pParam->connHandle, pParam->reason );
  return ( SUCCESS );
}

Status_t HCI_BLECreateLLConnCancelCmd( void )
{

  DebugMsg( "#HCI_BLECreateLLConnCancelCmd", 0 );

  return ( SUCCESS );
}

static void generateHCICommandCompleteEvent( uint16 opCode, uint8 len, uint8 *pData )
{
  DebugMsg( "#generateHCICommandCompleteEvent", 0 );

  if ( hciGapTaskID )
  {
    hciEvt_CmdComplete_t *pkt = (hciEvt_CmdComplete_t *)osal_msg_allocate( sizeof ( hciEvt_CmdComplete_t ) + len );
    if ( pkt )
    {
      pkt->hdr.event = HCI_GAP_EVENT_EVENT;
      pkt->hdr.status = HCI_COMMAND_COMPLETE_EVENT_CODE;
      pkt->numHciCmdPkt = 1;
      pkt->cmdOpcode = opCode;
      pkt->pReturnParam = (uint8 *)(pkt+1);
      osal_memcpy( pkt->pReturnParam, pData, len );

      osal_msg_send( hciGapTaskID, (uint8 *)pkt );
    }
  }
}

static void generateHCIDisconnectionCompleteEvent( uint8 status, uint16 connHandle, uint8 reason )
{
  DebugMsg( "#generateHCIDisconnectionCompleteEvent", 0 );

  if ( hciGapTaskID )
  {
    hciEvt_DisconnComplete_t *pkt;

    pkt = (hciEvt_DisconnComplete_t *)osal_msg_allocate( sizeof ( hciEvt_DisconnComplete_t ) );
    if ( pkt )
    {
      pkt->hdr.event = HCI_GAP_EVENT_EVENT;
      pkt->hdr.status = HCI_DISCONNECTION_COMPLETE_EVENT_CODE;
      pkt->status = status;
      pkt->connHandle = connHandle;
      pkt->reason = reason;

      osal_msg_send( hciGapTaskID, (uint8 *)pkt );
    }
  }
}

static void generateHCIConnCompleteEvent( uint8 role,
                         uint8 peerAddrType, uint8 *peerAddr,
                         uint16 connInterval, uint16 connLatency,
                         uint16 connTimeout, uint8 clockAccuracy )
{
  DebugMsg( "#generateHCIConnCompleteEvent", 0 );

  if ( hciGapTaskID )
  {
    hciEvt_BLEConnComplete_t *pkt;

    pkt = (hciEvt_BLEConnComplete_t *)osal_msg_allocate( sizeof ( hciEvt_BLEConnComplete_t ) );
    if ( pkt )
    {
      pkt->hdr.event = HCI_GAP_EVENT_EVENT;
      pkt->hdr.status = HCI_BLE_EVENT_CODE;
      pkt->BLEEventCode = HCI_BLE_CONNECTION_COMPLETE_EVENT;

      pkt->status = SUCCESS;
      pkt->connectionHandle = connHandle++;
      pkt->role = role;
      pkt->peerAddrType = peerAddrType;
      osal_memcpy( pkt->peerAddr, peerAddr, B_ADDR_LEN );
      pkt->connInterval = connInterval;
      pkt->connLatency = connLatency;
      pkt->connTimeout = connTimeout;
      pkt->clockAccuracy = clockAccuracy;

      osal_msg_send( hciGapTaskID, (uint8 *)pkt );
    }
  }
}

static void generateAvertRptEvent( hciEvt_DevInfo_t *devInfo )
{

  DebugMsg( "#generateAvertRptEvent", 0 );

  if ( hciGapTaskID )
  {
    hciEvt_BLEAdvPktReport_t *pkt;

    pkt = (hciEvt_BLEAdvPktReport_t *)osal_msg_allocate(
      sizeof ( hciEvt_BLEAdvPktReport_t ) + sizeof ( hciEvt_DevInfo_t ) );

    if ( pkt )
    {
      pkt->hdr.event = HCI_GAP_EVENT_EVENT;
      pkt->hdr.status = HCI_BLE_EVENT_CODE;
      pkt->BLEEventCode = HCI_BLE_ADV_REPORT_EVENT;
      pkt->numDevices = 1;
      pkt->devInfo = (hciEvt_DevInfo_t *)(pkt+1);
      osal_memcpy( pkt->devInfo, devInfo, sizeof ( hciEvt_DevInfo_t ) );

      osal_msg_send( hciGapTaskID, (uint8 *)pkt );
    }
  }
}

static void gapappSendAdvPkt( void )
{
  if ( hciAdvertCounter-- )
  {
    uint8  x;
    hciEvt_DevInfo_t devInfo;
    devInfo.eventType = 1;
    devInfo.addrType = 0; // Public
    for ( x = 0;  x < B_ADDR_LEN; x++ )
    {
      devInfo.addr[x] = (uint8)(osal_rand());
    }
    devInfo.dataLen = sizeof ( advertData );
    osal_memcpy( devInfo.rspData, advertData, sizeof ( advertData ) );

    if ( hciAdvertCounter % 2 )
    {
      devInfo.rspData[2] = GAP_ADTYPE_FLAGS_LIMITED;
    }
    else
    {
      devInfo.rspData[2] = GAP_ADTYPE_FLAGS_GENERAL;
    }

    devInfo.rssi = (uint8)(osal_rand());
    generateAvertRptEvent( &devInfo );

    // Also generate the SCAN_RSP
    if ( hciAdvertCounter == 13 || hciAdvertCounter == 11 || hciAdvertCounter == 1 )
    {
      devInfo.eventType = 0x05; // Scan Response
      devInfo.dataLen = sizeof ( rspData );
      osal_memcpy( devInfo.rspData, rspData, sizeof ( rspData ) );
      generateAvertRptEvent( &devInfo );
    }

    osal_start_timerEx( GAPApp_TaskID, GAPAPP_SEND_HCI_ADV_PKT_EVT, 100 );
  }
}

static void displayScanResults( gapDevDiscEvent_t *pkt )
{
  gapDevRec_t *devList = pkt->devList;
  uint8 x;

  DebugMsg("GAP_DEVICE_DISCOVERY_EVENT received", 0);

  if ( pkt->hdr.status == SUCCESS )
  {
    DebugMsg( "->status: SUCCESS", 0 );
  }
  else
  {
    DebugMsg( "->status: ", pkt->hdr.status );
  }
  DebugMsg( "->numDevs: ", pkt->numDevs );
  for ( x = 0; x < pkt->numDevs; x++, devList++ )
  {
    DebugMsg(   "****->devList: ", x );
    DebugMsg(   "   -->eventType: ", devList->eventType );
    DebugMsg(   "   -->addrType: ", devList->addrType );
    DebugMsgHex("   -->addr: ", devList->addr, B_ADDR_LEN);
    DebugMsg(   "   -->dataLen: ", devList->dataLen );
    DebugMsgHex("   -->dataField: ", devList->dataField, devList->dataLen);
  }
}

void HCI_GAPTaskRegister( uint8 taskID )
{
  DebugMsg( "#HCI_GAPTaskRegister", 0 );

  hciGapTaskID = taskID;
}

#endif // HCI_SIMULATOR
/*********************************************************************
*********************************************************************/
