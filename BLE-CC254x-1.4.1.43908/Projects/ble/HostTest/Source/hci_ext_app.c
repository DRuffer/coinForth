/**************************************************************************************************
  Filename:       hci_ext_app.c
  Revised:        $Date: 2015-05-07 08:58:41 -0700 (Thu, 07 May 2015) $
  Revision:       $Revision: 43716 $

  Description:    HCI Extensions Application


  Copyright 2009 - 2015 Texas Instruments Incorporated. All rights reserved.

  IMPORTANT: Your use of this Software is limited to those specific rights
  granted under the terms of a software license agreement between the user
  who downloaded the software, his/her employer (which must be your employer)
  and Texas Instruments Incorporated (the "License"). You may not use this
  Software unless you agree to abide by the terms of the License. The License
  limits your use, and you acknowledge, that the Software may not be modified,
  copied or distributed unless embedded on a Texas Instruments microcontroller
  or used solely and exclusively in conjunction with a Texas Instruments radio
  frequency transceiver, which is integrated into your product. Other than for
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
#include "hal_lcd.h"
#include "hci.h"
#include "hci_tl.h"
#include "l2cap.h"
#include "gap.h"
#include "gatt.h"
#include "gatt_uuid.h"
#include "osal_snv.h"
#include "osal_bufmgr.h"

#if !defined ( GATT_DB_OFF_CHIP )
  #include "gattservapp.h"
  #include "gapgattserver.h"

  #if defined ( GATT_TEST ) || defined ( GATT_QUAL )
    #include "gatttest.h"
  #endif
#endif // GATT_DB_OFF_CHIP

#if defined ( GAP_BOND_MGR )
  #include "gapbondmgr.h"
#endif

#include "OnBoard.h"
#include "hci_ext.h"
#include "hci_ext_app.h"

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * CONSTANTS
 */

#define RSP_PAYLOAD_IDX                  6
#define MAX_RSP_DATA_LEN                 50
#define MAX_RSP_BUF                      ( RSP_PAYLOAD_IDX + MAX_RSP_DATA_LEN )

#if !defined ( HCI_EXT_APP_OUT_BUF )
  #define HCI_EXT_APP_OUT_BUF            44
#endif

#define KEYDIST_SENC                     0x01
#define KEYDIST_SID                      0x02
#define KEYDIST_SSIGN                    0x04
#define KEYDIST_SLINK                    0x08
#define KEYDIST_MENC                     0x10
#define KEYDIST_MID                      0x20
#define KEYDIST_MSIGN                    0x40
#define KEYDIST_MLINK                    0x80

// Maximum number of reliable writes supported by Attribute Client
#define GATT_MAX_NUM_RELIABLE_WRITES     5

/*********************************************************************
 * TYPEDEFS
 */
typedef struct
{
  uint8  pktType;
  uint16 opCode;
  uint8  len;
  uint8  *pData;
} hciExtCmd_t;

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
uint8 hciExtApp_TaskID;   // Task ID for internal task/event processing

uint32 hciExtSignCounter = 0;

static uint8 out_msg[HCI_EXT_APP_OUT_BUF];
uint8 rspBuf[MAX_RSP_BUF];

// The device's local keys
static uint8 IRK[KEYLEN] = {0};
static uint8 SRK[KEYLEN] = {0};

#if !defined ( GATT_DB_OFF_CHIP )
  #if ( ( HOST_CONFIG & CENTRAL_CFG ) && ( HOST_CONFIG & PERIPHERAL_CFG ) )
    static uint8 deviceName[GAP_DEVICE_NAME_LEN] = "TI BLE All";
  #elif ( HOST_CONFIG & CENTRAL_CFG )
    static uint8 deviceName[GAP_DEVICE_NAME_LEN] = "TI BLE Central";
  #else
    static uint8 deviceName[GAP_DEVICE_NAME_LEN] = "TI BLE Peripheral";
  #endif
  static uint16 appearance = 17;
#endif

/*********************************************************************
 * LOCAL FUNCTIONS
 */

/*********************************************************************
 * NETWORK LAYER CALLBACKS
 */

/*********************************************************************
 * PUBLIC FUNCTIONS
 */

/*********************************************************************
 * LOCAL FUNCTION PROTOTYPES
 */

static uint8 checkNVLen(osalSnvId_t id, osalSnvLen_t len);

/*** For HCI Extension messages ***/
static uint8 processExtMsg(hciPacket_t *pMsg);
static uint8 processExtMsgUTIL(uint8 cmdID, hciExtCmd_t *pCmd,
                               uint8 *pRspDataLen);
static uint8 processExtMsgL2CAP(uint8 cmdID, hciExtCmd_t *pCmd,
                                uint8 *pRspDataLen);
static uint8 processExtMsgATT(uint8 cmdID, hciExtCmd_t *pCmd);
static uint8 processExtMsgGATT(uint8 cmdID, hciExtCmd_t *pCmd,
                               uint8 *pRspDataLen);
static uint8 processExtMsgGAP(uint8 cmdID, hciExtCmd_t *pCmd,
                              uint8 *pRspDataLen);

static uint8 processEvents(osal_event_hdr_t *pMsg );
static uint8 *processEventsGAP(gapEventHdr_t *pMsg, uint8 *pOutMsg,
                               uint8 *pMsgLen,uint8 *pAllocated,
                               uint8 *pDeallocate);
static uint8 *processEventsL2CAP(l2capSignalEvent_t *pPkt, uint8 *pOutMsg,
                                 uint8 *pMsgLen);
static uint8 *processEventsGATT(gattMsgEvent_t *pPkt, uint8 *pOutMsg,
                                uint8 *pMsgLen, uint8 *pAllocated);
static uint8 *processDataL2CAP( l2capDataEvent_t *pPkt, uint8 *pOutMsg, 
                                uint8 *pMsgLen, uint8 *pAllocated );
#ifndef GATT_DB_OFF_CHIP
static uint8 *processEventsGATTServ(gattEventHdr_t *pPkt, uint8 *pMsg,
                                    uint8 *pMsgLen);
#else
static uint8 addAttrRec(gattService_t *pServ, uint8 *pUUID, uint8 len,
                        uint8 permissions, uint16 *pTotalAttrs,
                        uint8 *pRspDataLen);
static void freeAttrRecs(gattService_t *pServ);
static const uint8 *findUUIDRec(uint8 *pUUID, uint8 len);
#endif // !GATT_DB_OFF_CHIP

#ifdef L2CAP_CO_CHANNELS
static uint8 buildCoChannelInfo( uint16 CID, l2capCoCInfo_t *pInfo, uint8 *pRspBuf );
static uint16 l2capVerifySecCB( uint16 connHandle, uint8 id, 
                                l2capConnectReq_t *pReq );
#endif // L2CAP_CO_CHANNELS

static uint8 buildHCIExtHeader(uint8 *pBuf, uint16 event, uint8 status,
                               uint16 connHandle);
static uint8 mapATT2BLEStatus(uint8 status);
static uint8 *createMsgPayload( uint8 *pBuf, uint16 len );

/*********************************************************************
 * @fn      HCI_EXT_App_Init
 *
 * @brief   Initialization function for the HCI Ext App Task.
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
void HCI_EXT_App_Init( uint8 task_id )
{
  hciExtApp_TaskID = task_id;

  HCI_ExtTaskRegister( hciExtApp_TaskID );

  // Register for unwanted HCI/Host messages
  GAP_RegisterForMsgs( hciExtApp_TaskID );

  // Initialize GATT Client
  VOID GATT_InitClient();

  // Register to receive incoming ATT Indications/Notifications
  GATT_RegisterForInd( hciExtApp_TaskID );

#if !defined ( GATT_DB_OFF_CHIP )
  // Register with GATT Server App for event messages
  GATTServApp_RegisterForMsg( hciExtApp_TaskID );

  #if defined ( GATT_QUAL )
    VOID GATTQual_AddService( GATT_ALL_SERVICES ); // Includes GAP and GATT Services
  #else
    // Add our services to GATT Server
    VOID GGS_AddService( GATT_ALL_SERVICES );
    VOID GATTServApp_AddService( GATT_ALL_SERVICES );
    #if defined ( GATT_TEST )
      VOID GATTTest_AddService( GATT_ALL_SERVICES );
    #endif
  #endif

  VOID GGS_SetParameter( GGS_DEVICE_NAME_ATT, osal_strlen((char *)deviceName) , deviceName );
  VOID GGS_SetParameter( GGS_APPEARANCE_ATT, sizeof( uint16 ), (void*)&appearance );
#else
  // Register with GATT Server for GATT messages
  GATT_RegisterForReq( hciExtApp_TaskID );
#endif // GATT_DB_OFF_CHIP

  // Enable the Host to Application flow control (if required by the App)
  //GATT_SetHostToAppFlowCtrl( MAXMEMHEAP, TRUE );

#if (defined HAL_LCD) && (HAL_LCD == TRUE)

  HalLcdWriteString( "  TI BLEv1.4", HAL_LCD_LINE_1 );
  HalLcdWriteString( "  HostTestApp", HAL_LCD_LINE_2 );
  #if ( ( HOST_CONFIG & CENTRAL_CFG ) && ( HOST_CONFIG & PERIPHERAL_CFG ) )
    HalLcdWriteString( "      All", HAL_LCD_LINE_3 );
  #elif ( ( HOST_CONFIG & CENTRAL_CFG ) && ( HOST_CONFIG & BROADCASTER_CFG ) )
    HalLcdWriteString( "  Cent+Bcast", HAL_LCD_LINE_3 );
  #elif ( ( HOST_CONFIG & PERIPHERAL_CFG ) && ( HOST_CONFIG & OBSERVER_CFG ) )
    HalLcdWriteString( "  Peri+Observ", HAL_LCD_LINE_3 );
  #elif ( HOST_CONFIG & CENTRAL_CFG )
    HalLcdWriteString( "    Central", HAL_LCD_LINE_3 );
  #else
    HalLcdWriteString( "  Peripheral", HAL_LCD_LINE_3 );
  #endif

#endif // (defined HAL_LCD) && (HAL_LCD == TRUE)

  VOID osal_snv_read( BLE_NVID_IRK, KEYLEN, IRK );
  VOID osal_snv_read( BLE_NVID_CSRK, KEYLEN, SRK );
  VOID osal_snv_read( BLE_NVID_SIGNCOUNTER, sizeof( uint32 ), &hciExtSignCounter );
}

/*********************************************************************
 * @fn      HCI_EXT_App_ProcessEvent
 *
 * @brief   HCI Extension App Task event processor.  This function
 *          is called to process all events for the task.  Events
 *          include timers, messages and any other user defined events.
 *
 * @param   task_id  - The OSAL assigned task ID.
 * @param   events - events to process.  This is a bit map and can
 *                   contain more than one event.
 *
 * @return  none
 */
uint16 HCI_EXT_App_ProcessEvent( uint8 task_id, uint16 events )
{
  if ( events & SYS_EVENT_MSG )
  {
    hciPacket_t *pMsg;

    if ( (pMsg = ( hciPacket_t *)osal_msg_receive( hciExtApp_TaskID )) != NULL )
    {
      uint8 dealloc = TRUE;

      // Process incoming messages
      switch ( pMsg->hdr.event )
      {
        // Incoming HCI extension message
        case HCI_EXT_CMD_EVENT:
          dealloc = processExtMsg( pMsg );
          break;

        case HCI_GAP_EVENT_EVENT:
          {
            if ( pMsg->hdr.status == HCI_COMMAND_COMPLETE_EVENT_CODE )
            {
              hciEvt_CmdComplete_t *pkt = (hciEvt_CmdComplete_t *)pMsg;
              osal_msg_hdr_t *msgHdr;
              uint8 len;

              msgHdr = (osal_msg_hdr_t *)pMsg;
              msgHdr--; // Backup to the msg header

              len = (uint8)(msgHdr->len - sizeof ( hciEvt_CmdComplete_t ));

              HCI_SendCommandCompleteEvent( HCI_COMMAND_COMPLETE_EVENT_CODE, pkt->cmdOpcode, len, pkt->pReturnParam );
            }
            else if ( pMsg->hdr.status == HCI_VE_EVENT_CODE )
            {
              hciEvt_VSCmdComplete_t *pkt = (hciEvt_VSCmdComplete_t *)pMsg;

              HCI_SendCommandCompleteEvent(HCI_VE_EVENT_CODE, pkt->cmdOpcode,
                                           pkt->length, pkt->pEventParam);
            }
          }
          break;
        
        default:
          dealloc = processEvents( (osal_event_hdr_t *)pMsg );
          break;
      }

      // Release the OSAL message
      if ( dealloc )
      {
        VOID osal_msg_deallocate( (uint8 *)pMsg );
      }
    }

    // return unprocessed events
    return (events ^ SYS_EVENT_MSG);
  }

  if ( events & GAP_EVENT_SIGN_COUNTER_CHANGED )
  {
    // Sign counter changed, save it to NV
    VOID osal_snv_write( BLE_NVID_SIGNCOUNTER, sizeof( uint32 ), &hciExtSignCounter );

    return ( events ^ GAP_EVENT_SIGN_COUNTER_CHANGED );
  }

  // Discard unknown events
  return 0;
}

/*********************************************************************
 * @fn      checkNVLen
 *
 * @brief   Checks the size of NV items.
 *
 * @param   id - NV ID.
 * @param   len - lengths in bytes of item.
 *
 * @return  SUCCESS, INVALIDPARAMETER or FAILURE
 */
static uint8 checkNVLen(osalSnvId_t id, osalSnvLen_t len)
{
  uint8 stat = SUCCESS;

  switch (id)
  {
    case BLE_NVID_CSRK:
    case BLE_NVID_IRK:
      if (len != KEYLEN)
      {
        stat = INVALIDPARAMETER;
      }
      break;

    case BLE_NVID_SIGNCOUNTER:
      if (len != sizeof (uint32))
      {
        stat = INVALIDPARAMETER;
      }
      break;

    default:
      stat = INVALIDPARAMETER;  // Initialize status to failure

#if defined (GAP_BOND_MGR)
      if ((id >= BLE_NVID_GAP_BOND_START) && (id <= BLE_NVID_GAP_BOND_END))
      {
        stat = GAPBondMgr_CheckNVLen(id, len);
      }
#endif
      break;
  }

  return (stat);
}

/*********************************************************************
 * @fn      processExtMsg
 *
 * @brief   Parse and process incoming HCI extension messages.
 *
 * @param   pMsg - incoming HCI extension message.
 *
 * @return  none
 */
static uint8 processExtMsg( hciPacket_t *pMsg )
{
  uint8 deallocateIncoming;
  bStatus_t stat = SUCCESS;
  uint8 rspDataLen = 0;
  hciExtCmd_t msg;
  uint8 *pBuf = pMsg->pData;

  // Parse the header
  msg.pktType = *pBuf++;
  msg.opCode = BUILD_UINT16( pBuf[0], pBuf[1] );
  pBuf += 2;

  msg.len = *pBuf++;
  msg.pData = pBuf;

  switch( msg.opCode >> 7 )
  {
    case HCI_EXT_L2CAP_SUBGRP:
      stat = processExtMsgL2CAP( (msg.opCode & 0x007F), &msg, &rspDataLen );
      break;

    case HCI_EXT_ATT_SUBGRP:
      stat = processExtMsgATT( (msg.opCode & 0x007F), &msg );
      break;

    case HCI_EXT_GATT_SUBGRP:
      stat = processExtMsgGATT( (msg.opCode & 0x007F), &msg, &rspDataLen );
      break;

    case HCI_EXT_GAP_SUBGRP:
      stat = processExtMsgGAP( (msg.opCode & 0x007F), &msg, &rspDataLen );
      break;

    case HCI_EXT_UTIL_SUBGRP:
      stat = processExtMsgUTIL( (msg.opCode & 0x007F), &msg, &rspDataLen );
      break;

    default:
      stat = FAILURE;
      break;
  }

  // Deallocate here to free up heap space for the serial message set out HCI.
  VOID osal_msg_deallocate( (uint8 *)pMsg );
  deallocateIncoming = FALSE;

  // Send back an immediate response
  rspBuf[0] = LO_UINT16( HCI_EXT_GAP_CMD_STATUS_EVENT );
  rspBuf[1] = HI_UINT16( HCI_EXT_GAP_CMD_STATUS_EVENT );
  rspBuf[2] = stat;
  rspBuf[3] = LO_UINT16( 0xFC00 | msg.opCode );
  rspBuf[4] = HI_UINT16( 0xFC00 | msg.opCode );
  rspBuf[5] = rspDataLen;

  // IMPORTANT!! Fill in Payload (if needed) in case statement

  HCI_SendControllerToHostEvent( HCI_VE_EVENT_CODE, (6 + rspDataLen), rspBuf );

  return ( deallocateIncoming );
}

/*********************************************************************
 * @fn      processExtMsgUTIL
 *
 * @brief   Parse and process incoming HCI extension UTIL messages.
 *
 * @param   cmdID - incoming HCI extension command ID.
 * @param   pCmd - incoming HCI extension message.
 * @param   pRspDataLen - response data length to be returned.
 *
 * @return  SUCCESS, INVALIDPARAMETER and FAILURE.
 */
static uint8 processExtMsgUTIL( uint8 cmdID, hciExtCmd_t *pCmd, uint8 *pRspDataLen )
{
  uint8 *pBuf = pCmd->pData;
  bStatus_t stat = SUCCESS;

  *pRspDataLen = 0;

  switch( cmdID )
  {
    case HCI_EXT_UTIL_NV_READ:
      {
        osalSnvId_t id  = pBuf[0];
        osalSnvLen_t len = pBuf[1];

        // This has a limitation of only allowing a max data length because of the fixed buffer.
        if ( (len < MAX_RSP_DATA_LEN) && (checkNVLen( id, len ) == SUCCESS) )
        {
          stat = osal_snv_read( id, len, &rspBuf[RSP_PAYLOAD_IDX] );
          if ( stat == SUCCESS )
          {
            *pRspDataLen = pBuf[1];
          }
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case HCI_EXT_UTIL_NV_WRITE:
      {
        osalSnvId_t id  = pBuf[0];
        osalSnvLen_t len = pBuf[1];
        if ( checkNVLen( id, len ) == SUCCESS )
        {
          stat = osal_snv_write( id, len, &pBuf[2] );

          if ( id == BLE_NVID_SIGNCOUNTER )
          {
            hciExtSignCounter = BUILD_UINT32(pBuf[2], pBuf[3], pBuf[4], pBuf[5]);
          }
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case HCI_EXT_UTIL_FORCE_BOOT:
      {
        extern void appForceBoot(void);
        appForceBoot();

        // Should never get here if SBL is present
        stat = INVALIDPARAMETER;
      }
      break;

    default:
      stat = FAILURE;
      break;
  }

  return ( stat );
}

/*********************************************************************
 * @fn      processExtMsgL2CAP
 *
 * @brief   Parse and process incoming HCI extension L2CAP messages.
 *
 * @param   pCmd - incoming HCI extension message.
 *
 * @return  SUCCESS or FAILURE
 */
static uint8 processExtMsgL2CAP( uint8 cmdID, hciExtCmd_t *pCmd, uint8 *pRspDataLen )
{
  uint8 *pBuf = pCmd->pData;
  uint16 connHandle = BUILD_UINT16( pBuf[0], pBuf[1] ); // connHandle, CID or PSM
  l2capSignalCmd_t cmd;
  bStatus_t stat;

  switch( cmdID )
  {
#ifdef L2CAP_CO_CHANNELS
    case HCI_EXT_L2CAP_DATA:
      if ( pCmd->len > 2 )
      {
        uint8 *pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
        if ( pPayload != NULL )
        {
          l2capPacket_t pkt;
          
          pkt.CID = connHandle; // connHandle is CID here
          pkt.pPayload = pPayload;
          pkt.len = pCmd->len-2;
          
          // Send SDU over dynamic channel
          stat = L2CAP_SendSDU( &pkt );
          if ( stat != SUCCESS )
          {
            VOID osal_mem_free( pPayload );
          }
        }
        else
        {
          stat = bleMemAllocError;
        }
      }
      else
      {
        stat = FAILURE;
      }
      break;
      
    case HCI_EXT_L2CAP_REGISTER_PSM:
      if ( pCmd->len == 10 )
      {
        l2capPsm_t psm;
        
        psm.psm = connHandle; // connHandle is PSM here
        psm.mtu = BUILD_UINT16( pBuf[2], pBuf[3] );
        psm.initPeerCredits = BUILD_UINT16( pBuf[4], pBuf[5] );
        psm.peerCreditThreshold = BUILD_UINT16( pBuf[6], pBuf[7] );
        psm.maxNumChannels = pBuf[8];
        psm.pfnVerifySecCB = pBuf[9] ? l2capVerifySecCB : NULL;
        psm.taskId = hciExtApp_TaskID;
                
        stat = L2CAP_RegisterPsm( &psm );
      }
      else
      {
        stat = FAILURE;
      }
      break;

    case HCI_EXT_L2CAP_DEREGISTER_PSM:
      if ( pCmd->len == 2 )
      {        
        stat = L2CAP_DeregisterPsm( hciExtApp_TaskID, connHandle ); // connHandle is PSM here
      }
      else
      {
        stat = FAILURE;
      }
      break;

    case HCI_EXT_L2CAP_PSM_INFO:
      if ( pCmd->len == 2 )
      {
        l2capPsmInfo_t info;
        
        stat = L2CAP_PsmInfo( connHandle, &info ); // connHandle is PSM here
        if ( stat == SUCCESS )
        {
          *pRspDataLen = 10;
          rspBuf[RSP_PAYLOAD_IDX]   = LO_UINT16( info.mtu );
          rspBuf[RSP_PAYLOAD_IDX+1] = HI_UINT16( info.mtu );
          
          rspBuf[RSP_PAYLOAD_IDX+2] = LO_UINT16( info.mps );
          rspBuf[RSP_PAYLOAD_IDX+3] = HI_UINT16( info.mps );
                    
          rspBuf[RSP_PAYLOAD_IDX+4] = LO_UINT16( info.initPeerCredits );
          rspBuf[RSP_PAYLOAD_IDX+5] = HI_UINT16( info.initPeerCredits );
 
          rspBuf[RSP_PAYLOAD_IDX+6] = LO_UINT16( info.peerCreditThreshold );
          rspBuf[RSP_PAYLOAD_IDX+7] = HI_UINT16( info.peerCreditThreshold );
          
          rspBuf[RSP_PAYLOAD_IDX+8] = info.maxNumChannels;
          rspBuf[RSP_PAYLOAD_IDX+9] = info.numActiveChannels;
        }
      }
      else
      {
        stat = FAILURE;
      }
      break;
      
    case HCI_EXT_L2CAP_PSM_CHANNELS:
      if ( pCmd->len == 2 )
      {
        l2capPsmInfo_t info;

        stat = L2CAP_PsmInfo( connHandle, &info ); // connHandle is PSM here
        if ( ( stat == SUCCESS ) && ( info.numActiveChannels > 0 ) )
        {
          uint8 numCIDs = info.numActiveChannels;
          
          uint16 *pCIDs = (uint16 *)osal_mem_alloc( sizeof( uint16 ) * numCIDs );
          if ( pCIDs != NULL )
          {
            stat = L2CAP_PsmChannels( connHandle, numCIDs, pCIDs );
            if ( stat == SUCCESS )
            {
              uint8 *pRspBuf = &rspBuf[RSP_PAYLOAD_IDX];
              
              for ( uint8 i = 0; i < numCIDs; i++ )
              {
                *pRspBuf++ = LO_UINT16( pCIDs[i] );
                *pRspBuf++ = HI_UINT16( pCIDs[i] );
              }
              
              *pRspDataLen = numCIDs * 2;
            }
            
            VOID osal_mem_free( pCIDs );
          }
          else
          {
            stat = bleMemAllocError;
          }
        }
      }
      else
      {
        stat = FAILURE;
      }
      break;
    
    case HCI_EXT_L2CAP_CHANNEL_INFO:
      if ( pCmd->len == 2 )
      {
        l2capChannelInfo_t channelInfo;
        
        stat = L2CAP_ChannelInfo( connHandle, &channelInfo ); // connHandle is CID here
        if ( stat == SUCCESS )
        {        
          rspBuf[RSP_PAYLOAD_IDX] = channelInfo.state;
          
          *pRspDataLen = 1 + buildCoChannelInfo( connHandle, &channelInfo.info,
                                                 &rspBuf[RSP_PAYLOAD_IDX+1] );
        }
      }
      else
      {
        stat = FAILURE;
      }
      break;
      
    case L2CAP_CONNECT_REQ:
      if ( pCmd->len == 6 )
      {
        uint16 psm = BUILD_UINT16( pBuf[2], pBuf[3] );
        uint16 peerPsm = BUILD_UINT16( pBuf[4], pBuf[5] );
        
        stat = L2CAP_ConnectReq( connHandle, psm, peerPsm );
      }
      else
      {
        stat = FAILURE;
      }
      break;
   
    case L2CAP_CONNECT_RSP:
      if ( pCmd->len == 5 )
      {
        uint16 result = BUILD_UINT16( pBuf[3], pBuf[4] );

        stat = L2CAP_ConnectRsp( connHandle, pBuf[2], result );
      }
      else
      {
        stat = FAILURE;
      }
      break;
      
    case L2CAP_DISCONNECT_REQ:
      if ( pCmd->len == 2 )
      {       
        stat = L2CAP_DisconnectReq( connHandle ); // connHandle is CID here
      }
      else
      {
        stat = FAILURE;
      }
      break;
    
    case L2CAP_FLOW_CTRL_CREDIT:
      stat = L2CAP_ParseFlowCtrlCredit( &cmd, pBuf, pCmd->len );
      if ( stat == SUCCESS )
      {
        stat = L2CAP_FlowCtrlCredit( cmd.credit.CID, cmd.credit.credits );
      }
      break;
#endif // L2CAP_CO_CHANNELS

    case L2CAP_PARAM_UPDATE_REQ:
      stat = L2CAP_ParseParamUpdateReq( &cmd, &pBuf[2], pCmd->len-2 );
      if ( stat == SUCCESS )
      {
        stat =  L2CAP_ConnParamUpdateReq( connHandle, &cmd.updateReq, hciExtApp_TaskID );
      }
      break;

    case L2CAP_INFO_REQ:
      stat = L2CAP_ParseInfoReq( &cmd, &pBuf[2], pCmd->len-2 );
      if ( stat == SUCCESS )
      {
        stat = L2CAP_InfoReq( connHandle, &cmd.infoReq, hciExtApp_TaskID );
      }
      break;

    default:
      stat = FAILURE;
      break;
  }

  return ( stat );
}

/*********************************************************************
 * @fn      processExtMsgATT
 *
 * @brief   Parse and process incoming HCI extension ATT messages.
 *
 * @param   pCmd - incoming HCI extension message.
 *
 * @return  SUCCESS, INVALIDPARAMETER, FAILURE,
 *          bleInvalidPDU, bleInsufficientAuthen,
 *          bleInsufficientKeySize, bleInsufficientEncrypt or bleMemAllocError
 */
static uint8 processExtMsgATT( uint8 cmdID, hciExtCmd_t *pCmd )
{
  static uint8 numPrepareWrites = 0;
  static attPrepareWriteReq_t *pPrepareWrites = NULL;
  uint8 *pBuf, *pPayload = NULL, safeToDealloc = TRUE;
  uint16 connHandle;
  attMsg_t msg;
  bStatus_t stat = bleInvalidPDU;
  
  // Make sure received buffer contains at lease connection handle (2 otects)
  if ( pCmd->len < 2 )
  {
    return ( stat );
  }
  
  pBuf = pCmd->pData;
  connHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
  
  switch( cmdID )
  {
    case ATT_ERROR_RSP:
      if ( ATT_ParseErrorRsp( &pBuf[2], pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = ATT_ErrorRsp( connHandle, &msg.errorRsp );
      }
      break;

    case ATT_EXCHANGE_MTU_REQ:
      if ( ATT_ParseExchangeMTUReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                    pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ExchangeMTU( connHandle, &msg.exchangeMTUReq, hciExtApp_TaskID );
      }
      break;

    case ATT_EXCHANGE_MTU_RSP:
      if ( ATT_ParseExchangeMTURsp( &pBuf[2], pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = ATT_ExchangeMTURsp( connHandle, &msg.exchangeMTURsp );
      }
      break;

    case ATT_FIND_INFO_REQ:
      if ( ATT_ParseFindInfoReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                 pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_DiscAllCharDescs( connHandle, msg.findInfoReq.startHandle,
                                      msg.findInfoReq.endHandle, hciExtApp_TaskID );
      }
      break;

    case ATT_FIND_INFO_RSP:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseFindInfoRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_FindInfoRsp( connHandle, &msg.findInfoRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_FIND_BY_TYPE_VALUE_REQ:
      if ( ATT_ParseFindByTypeValueReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                        pCmd->len-2, &msg ) == SUCCESS )
      {
        attFindByTypeValueReq_t *pReq = &msg.findByTypeValueReq;

        // Find out what's been requested
        if ( gattPrimaryServiceType( pReq->type )     &&
             ( pReq->startHandle == GATT_MIN_HANDLE ) &&
             ( pReq->endHandle   == GATT_MAX_HANDLE ) )
        {
          // Discover primary service by service UUID
          stat = GATT_DiscPrimaryServiceByUUID( connHandle, pReq->pValue,
                                                pReq->len, hciExtApp_TaskID );
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case ATT_FIND_BY_TYPE_VALUE_RSP:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseFindByTypeValueRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_FindByTypeValueRsp( connHandle, &msg.findByTypeValueRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_BY_TYPE_REQ:
      if ( ATT_ParseReadByTypeReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                   pCmd->len-2, &msg ) == SUCCESS )
      {
        attReadByTypeReq_t *pReq = &msg.readByTypeReq;

        // Find out what's been requested
        if ( gattIncludeType( pReq->type ) )
        {
          // Find included services
          stat = GATT_FindIncludedServices( connHandle, pReq->startHandle,
                                            pReq->endHandle, hciExtApp_TaskID );
        }
        else if ( gattCharacterType( pReq->type ) )
        {
          // Discover all characteristics of a service
          stat = GATT_DiscAllChars( connHandle, pReq->startHandle,
                                    pReq->endHandle, hciExtApp_TaskID );
        }
        else
        {
          // Read using characteristic UUID
          stat = GATT_ReadUsingCharUUID( connHandle, pReq, hciExtApp_TaskID );
        }
      }
      break;

    case ATT_READ_BY_TYPE_RSP:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseReadByTypeRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_ReadByTypeRsp( connHandle, &msg.readByTypeRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_REQ:
      if ( ATT_ParseReadReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2], 
                             pCmd->len-2, &msg ) == SUCCESS )
      {
        // Read Characteristic Value or Read Characteristic Descriptor
        stat = GATT_ReadCharValue( connHandle, &msg.readReq, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_RSP:
      // Create payload if attribute value is present
      if ( pCmd->len > 2 )
      {
        pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      }
      
      if ( ( pCmd->len == 2 ) || ( pPayload != NULL ) )
      {
        if ( ATT_ParseReadRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_ReadRsp( connHandle, &msg.readRsp );
          if  ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_BLOB_REQ:
      if ( ATT_ParseReadBlobReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                 pCmd->len-2, &msg ) == SUCCESS )
      {
        // Read long characteristic value
        stat = GATT_ReadLongCharValue( connHandle, &msg.readBlobReq, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_BLOB_RSP:
      // Create payload if attribute value is present
      if ( pCmd->len > 2 )
      {
        pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      }
      
      if ( ( pCmd->len == 2 ) || ( pPayload != NULL ) )
      {
        if ( ATT_ParseReadBlobRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_ReadBlobRsp( connHandle, &msg.readBlobRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_MULTI_REQ:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseReadMultiReq( ATT_SIG_NOT_INCLUDED, FALSE, pPayload, 
                                    pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = GATT_ReadMultiCharValues( connHandle, &msg.readMultiReq, hciExtApp_TaskID );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_MULTI_RSP:
      // Create payload if attribute value is present
      if ( pCmd->len > 2 )
      {
        pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      }
      
      if ( ( pCmd->len == 2 ) || ( pPayload != NULL ) )
      {
        if ( ATT_ParseReadMultiRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_ReadMultiRsp( connHandle, &msg.readMultiRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_READ_BY_GRP_TYPE_REQ:
      if ( ATT_ParseReadByTypeReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                   pCmd->len-2, &msg ) == SUCCESS )
      {
        attReadByGrpTypeReq_t *pReq = &msg.readByGrpTypeReq;

        // Find out what's been requested
        if ( gattPrimaryServiceType( pReq->type )     &&
             ( pReq->startHandle == GATT_MIN_HANDLE ) &&
             ( pReq->endHandle   == GATT_MAX_HANDLE ) )
        {
          // Discover all primary services
          stat = GATT_DiscAllPrimaryServices( connHandle, hciExtApp_TaskID );
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case ATT_READ_BY_GRP_TYPE_RSP:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseReadByGrpTypeRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = ATT_ReadByGrpTypeRsp( connHandle, &msg.readByGrpTypeRsp );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_WRITE_REQ:
      pPayload = createMsgPayload( &pBuf[4], pCmd->len-4 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseWriteReq( pBuf[2], pBuf[3], pPayload, 
                                pCmd->len-4, &msg ) == SUCCESS )
        {
          attWriteReq_t *pReq = &msg.writeReq;

          if ( pReq->cmd == FALSE )
          {
            // Write Characteristic Value or Write Characteristic Descriptor
            stat = GATT_WriteCharValue( connHandle, pReq, hciExtApp_TaskID );
          }
          else
          {
            if ( pReq->sig == FALSE )
            {
              // Write Without Response
              stat = GATT_WriteNoRsp( connHandle, pReq );
            }
            else
            {
              // Signed Write Without Response
              stat = GATT_SignedWriteNoRsp( connHandle, pReq );
            }
          }
          
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_WRITE_RSP:
      if ( ATT_ParseWriteRsp( &pBuf[2], pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = ATT_WriteRsp( connHandle );
      }
      break;

    case ATT_PREPARE_WRITE_REQ:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParsePrepareWriteReq( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                       pCmd->len-2, &msg ) == SUCCESS )
        {
          attPrepareWriteReq_t *pReq = &msg.prepareWriteReq;
          
#if !defined ( GATT_DB_OFF_CHIP ) && defined ( TESTMODES )
          if ( GATTServApp_GetParamValue() == GATT_TESTMODE_PREPARE_WRITE )
          {
            // Send the Prepare Write Request right away - needed for GATT testing
            stat = GATT_PrepareWriteReq( connHandle, pReq, hciExtApp_TaskID );
            if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
            {
              safeToDealloc = FALSE; // payload passed to GATT
            }
          }
          else
#endif // !GATT_DB_OFF_CHIP && TESTMODE
          {
            // GATT Reliable Writes
            if ( pPrepareWrites == NULL )
            {
              // First allocated buffer for the Prepare Write Requests
              pPrepareWrites = osal_mem_alloc( GATT_MAX_NUM_RELIABLE_WRITES * sizeof( attPrepareWriteReq_t ) );
            }

            if ( pPrepareWrites != NULL )
            {
              if ( numPrepareWrites < GATT_MAX_NUM_RELIABLE_WRITES )
              {
                // Save the Prepare Write Request for now
                VOID osal_memcpy( &(pPrepareWrites[numPrepareWrites++]), 
                                  pReq, sizeof( attPrepareWriteReq_t ) );
                
                // Request was parsed and saved successfully
                stat = SUCCESS;
                safeToDealloc = FALSE; // payload saved for later
              }
              else
              {
                stat = INVALIDPARAMETER;
              }
            }
            else
            {
              stat = bleMemAllocError;
            }
          }
        }
      }
      break;

    case ATT_PREPARE_WRITE_RSP:
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParsePrepareWriteRsp( pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          attPrepareWriteRsp_t *pRsp = &msg.prepareWriteRsp;
          
          stat = ATT_PrepareWriteRsp( connHandle, pRsp );
          if ( ( stat == SUCCESS ) && ( pRsp->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_EXECUTE_WRITE_REQ:
      if ( ATT_ParseExecuteWriteReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                     pCmd->len-2, &msg ) == SUCCESS )
      {
#if !defined ( GATT_DB_OFF_CHIP ) && defined ( TESTMODES )
        if ( GATTServApp_GetParamValue() == GATT_TESTMODE_PREPARE_WRITE )
        {
          // Send the Execute Write Request right away - needed for GATT testing
          stat = GATT_ExecuteWriteReq( connHandle, &msg.executeWriteReq, hciExtApp_TaskID );
        }
        else
#endif // !GATT_DB_OFF_CHIP && TESTMODE
        if ( pPrepareWrites != NULL )
        {
          // GATT Reliable Writes - send all saved Prepare Write Requests
          stat = GATT_ReliableWrites( connHandle, pPrepareWrites, numPrepareWrites,
                                      msg.executeWriteReq.flags, hciExtApp_TaskID );
          if ( stat != SUCCESS )
          {
            // Free saved payload buffers
            for ( uint8 i = 0; i < numPrepareWrites; i++ )
            {
              if ( pPrepareWrites[i].pValue != NULL )
              {
                osal_bm_free( pPrepareWrites[i].pValue );
              }
            }

            osal_mem_free( pPrepareWrites );
          }
          // else pPrepareWrites will be freed by GATT Client

          // Reset GATT Reliable Writes variables
          pPrepareWrites = NULL;
          numPrepareWrites = 0;
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case ATT_EXECUTE_WRITE_RSP:
      if ( ATT_ParseExecuteWriteRsp( &pBuf[2], pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = ATT_ExecuteWriteRsp( connHandle );
      }
      break;

    case ATT_HANDLE_VALUE_NOTI:
      pPayload = createMsgPayload( &pBuf[3], pCmd->len-3 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseHandleValueInd( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                      pCmd->len-3, &msg ) == SUCCESS )
        {
          attHandleValueNoti_t *pNoti = &msg.handleValueNoti;
          
          stat = GATT_Notification( connHandle, pNoti, pBuf[2] );
          if ( ( stat == SUCCESS ) && ( pNoti->pValue!= NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_HANDLE_VALUE_IND:
      pPayload = createMsgPayload( &pBuf[3], pCmd->len-3 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseHandleValueInd( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                      pCmd->len-3, &msg ) == SUCCESS )
        {
          attHandleValueInd_t *pInd = &msg.handleValueInd;
          
          stat = GATT_Indication( connHandle, pInd, pBuf[2], hciExtApp_TaskID );
          if ( ( stat == SUCCESS ) && ( pInd->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_HANDLE_VALUE_CFM:
      if ( ATT_ParseHandleValueCfm( &pBuf[2], pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = ATT_HandleValueCfm( connHandle );
      }
      break;

    default:
      stat = FAILURE;
      break;
  }
  
  if ( ( pPayload != NULL ) && safeToDealloc )
  {
    // Free payload
    osal_bm_free( pPayload );
  }

  return ( mapATT2BLEStatus( stat ) );
}

/*********************************************************************
 * @fn      processExtMsgGATT
 *
 * @brief   Parse and process incoming HCI extension GATT messages.
 *
 * @param   cmdID - incoming HCI extension command ID.
 * @param   pCmd - incoming HCI extension message.
 * @param   pRspDataLen - response data length to be returned.
 *
 * @return  SUCCESS, INVALIDPARAMETER, FAILURE,
 *          bleInvalidPDU or bleMemAllocError
 */
static uint8 processExtMsgGATT( uint8 cmdID, hciExtCmd_t *pCmd, uint8 *pRspDataLen )
{
#ifdef GATT_DB_OFF_CHIP
  static uint16 totalAttrs = 0;
  static gattService_t service = { 0, NULL };
#endif
  uint8 *pBuf, *pPayload = NULL, safeToDealloc = TRUE;
  uint16 connHandle;
  attMsg_t msg;
  bStatus_t stat = bleInvalidPDU;
  
  // Make sure received buffer is at lease 2-otect long
  if ( pCmd->len < 2 )
  {
    return ( stat );
  }
  
  pBuf = pCmd->pData;
  connHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
  
  switch( cmdID )
  {
    case ATT_EXCHANGE_MTU_REQ: // GATT Exchange MTU
      if ( ATT_ParseExchangeMTUReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                    pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ExchangeMTU( connHandle, &msg.exchangeMTUReq, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_BY_GRP_TYPE_REQ: // GATT Discover All Primary Services
      stat = GATT_DiscAllPrimaryServices( connHandle, hciExtApp_TaskID );
      break;

    case ATT_FIND_BY_TYPE_VALUE_REQ: // GATT Discover Primary Service By UUID
      stat = GATT_DiscPrimaryServiceByUUID( connHandle, &pBuf[2],
                                            pCmd->len-2, hciExtApp_TaskID );
      break;

    case GATT_FIND_INCLUDED_SERVICES: // GATT Find Included Services
    case GATT_DISC_ALL_CHARS: // GATT Discover All Characteristics
      if ( ( pCmd->len-2 ) == ATT_READ_BY_TYPE_REQ_FIXED_SIZE )
      {
        // First requested handle number
        uint16 startHandle = BUILD_UINT16( pBuf[2], pBuf[3] );

        // Last requested handle number
        uint16 endHandle = BUILD_UINT16( pBuf[4], pBuf[5] );

        if ( cmdID == GATT_FIND_INCLUDED_SERVICES )
        {
          stat = GATT_FindIncludedServices( connHandle, startHandle,
                                            endHandle, hciExtApp_TaskID );
        }
        else
        {
          stat = GATT_DiscAllChars( connHandle, startHandle,
                                    endHandle, hciExtApp_TaskID );
        }
      }
      break;

    case ATT_READ_BY_TYPE_REQ: // GATT Discover Characteristics by UUID
      if ( ATT_ParseReadByTypeReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                   pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_DiscCharsByUUID( connHandle, &msg.readByTypeReq, hciExtApp_TaskID );
      }
      break;

    case ATT_FIND_INFO_REQ: // GATT Discover All Characteristic Descriptors
      if ( ATT_ParseFindInfoReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                 pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_DiscAllCharDescs( connHandle, msg.findInfoReq.startHandle,
                                      msg.findInfoReq.endHandle, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_REQ: // GATT Read Characteristic Value
      if ( ATT_ParseReadReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                             pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ReadCharValue( connHandle, &msg.readReq, hciExtApp_TaskID );
      }
      break;

    case GATT_READ_USING_CHAR_UUID: // GATT Read Using Characteristic UUID
      if ( ATT_ParseReadByTypeReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                   pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ReadUsingCharUUID( connHandle, &msg.readByTypeReq, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_BLOB_REQ: // GATT Read Long Characteristic Value
      if ( ATT_ParseReadBlobReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                 pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ReadLongCharValue( connHandle, &msg.readBlobReq, hciExtApp_TaskID );
      }
      break;

    case ATT_READ_MULTI_REQ: // GATT Read Multiple Characteristic Values
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseReadMultiReq( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                    pCmd->len-2, &msg ) == SUCCESS )
        {
          stat = GATT_ReadMultiCharValues( connHandle, &msg.readMultiReq, hciExtApp_TaskID );
          if ( stat == SUCCESS )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case GATT_WRITE_NO_RSP: // GATT Write Without Response
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseWriteReq( FALSE, TRUE, pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          attWriteReq_t *pReq = &msg.writeReq;
          
          stat = GATT_WriteNoRsp( connHandle, pReq );
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case GATT_SIGNED_WRITE_NO_RSP: // GATT Signed Write Without Response
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseWriteReq( TRUE, TRUE, pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          attWriteReq_t *pReq = &msg.writeReq;
          
          stat = GATT_SignedWriteNoRsp( connHandle, pReq );
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_WRITE_REQ: // GATT Write Characteristic Value
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseWriteReq( FALSE, FALSE, pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          attWriteReq_t *pReq = &msg.writeReq;
          
          stat = GATT_WriteCharValue( connHandle, pReq, hciExtApp_TaskID );
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_PREPARE_WRITE_REQ: // GATT Write Long Characteristic Value
    case GATT_WRITE_LONG_CHAR_DESC: // GATT Write Long Characteristic Descriptor
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParsePrepareWriteReq( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                       pCmd->len-2, &msg ) == SUCCESS )
        {
          attPrepareWriteReq_t *pReq = &msg.prepareWriteReq;
          if ( cmdID == ATT_PREPARE_WRITE_REQ )
          {
            stat = GATT_WriteLongCharValue( connHandle, pReq, hciExtApp_TaskID );
          }
          else
          {
            stat = GATT_WriteLongCharDesc( connHandle, pReq, hciExtApp_TaskID );
          }
          
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case GATT_RELIABLE_WRITES: // GATT Reliable Writes
      if ( pCmd->len-2 > 0 )
      {
        uint8 numReqs = pBuf[2];

        if ( ( numReqs > 0 ) && ( numReqs <= GATT_MAX_NUM_RELIABLE_WRITES ) )
        {
          // First allocated buffer for the Prepare Write Requests
          attPrepareWriteReq_t *pReqs = osal_mem_alloc( numReqs * sizeof( attPrepareWriteReq_t ) );
          if ( pReqs != NULL )
          {
            uint8 i;
            
            VOID osal_memset( pReqs, 0, numReqs * sizeof( attPrepareWriteReq_t ) );
            
            pBuf += 3; // pass connHandle and numReqs

            // Create payload buffer for each Prepare Write Request
            for ( i = 0; i < numReqs; i++ )
            {
              // length of request is length of attribute value plus fixed fields.
              // request format: length (1) + handle (2) + offset (2) + attribute value
              uint8 reqLen = ATT_PREPARE_WRITE_REQ_FIXED_SIZE;

              if ( *pBuf > 0 )
              {
                reqLen += *pBuf++;
                pPayload = createMsgPayload( pBuf, reqLen );
                if ( pPayload == NULL )
                {
                  stat = bleMemAllocError;
                  break;
                }
                
                VOID ATT_ParsePrepareWriteReq( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                               reqLen, (attMsg_t *)&(pReqs[i]) );
              }
              else // no attribute value
              {
                pBuf++;
                VOID ATT_ParsePrepareWriteReq( ATT_SIG_NOT_INCLUDED, FALSE, pBuf,
                                               reqLen, (attMsg_t *)&(pReqs[i]) );
              }

              // Next request
              pBuf += reqLen;
            }

            // See if all requests were parsed successfully
            if ( i == numReqs )
            {
              // Send all saved Prepare Write Requests
              stat = GATT_ReliableWrites( connHandle, pReqs, numReqs,
                                          ATT_WRITE_PREPARED_VALUES, hciExtApp_TaskID );
            }
            
            if ( stat != SUCCESS )
            {
              // Free payload buffers first
              for ( i = 0; i < numReqs; i++ )
              {
                if ( pReqs[i].pValue != NULL )
                {
                  osal_bm_free( pReqs[i].pValue );
                }
              }
              
              osal_mem_free( pReqs );
            }
            // else pReqs will be freed by GATT Client
          }
          else
          {
            stat = bleMemAllocError;
          }
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case GATT_READ_CHAR_DESC: // GATT Read Characteristic Descriptor
      if ( ATT_ParseReadReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2], 
                             pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ReadCharDesc( connHandle, &msg.readReq, hciExtApp_TaskID );
      }
      break;

    case GATT_READ_LONG_CHAR_DESC: // GATT Read Long Characteristic Descriptor
      if ( ATT_ParseReadBlobReq( ATT_SIG_NOT_INCLUDED, FALSE, &pBuf[2],
                                 pCmd->len-2, &msg ) == SUCCESS )
      {
        stat = GATT_ReadLongCharDesc( connHandle, &msg.readBlobReq, hciExtApp_TaskID );
      }
      break;

    case GATT_WRITE_CHAR_DESC: // GATT Write Characteristic Descriptor
      pPayload = createMsgPayload( &pBuf[2], pCmd->len-2 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseWriteReq( FALSE, FALSE, pPayload, pCmd->len-2, &msg ) == SUCCESS )
        {
          attWriteReq_t *pReq = &msg.writeReq;
          
          stat = GATT_WriteCharDesc( connHandle, pReq, hciExtApp_TaskID );
          if ( ( stat == SUCCESS ) && ( pReq->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_HANDLE_VALUE_NOTI:
      pPayload = createMsgPayload( &pBuf[3], pCmd->len-3 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseHandleValueInd( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                      pCmd->len-3, &msg ) == SUCCESS )
        {
          attHandleValueNoti_t *pNoti = &msg.handleValueNoti;
          
          stat = GATT_Notification( connHandle, pNoti, pBuf[2] );
          if ( ( stat == SUCCESS ) && ( pNoti->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

    case ATT_HANDLE_VALUE_IND:
      pPayload = createMsgPayload( &pBuf[3], pCmd->len-3 );
      if ( pPayload != NULL )
      {
        if ( ATT_ParseHandleValueInd( ATT_SIG_NOT_INCLUDED, FALSE, pPayload,
                                      pCmd->len-3, &msg ) == SUCCESS )
        {
          attHandleValueInd_t *pInd = &msg.handleValueInd;
          
          stat = GATT_Indication( connHandle, pInd, pBuf[2], hciExtApp_TaskID );
          if ( ( stat == SUCCESS ) && ( pInd->pValue != NULL ) )
          {
            safeToDealloc = FALSE; // payload passed to GATT
          }
        }
      }
      break;

#ifdef GATT_DB_OFF_CHIP // These GATT commands don't include connHandle field
    case HCI_EXT_GATT_ADD_SERVICE:
      if ( service.attrs == NULL )
      {
        // Service type must be 2 octets (Primary or Secondary)
        if ( pCmd->len-3 == ATT_BT_UUID_SIZE )
        {
          uint16 uuid = BUILD_UINT16( pBuf[0], pBuf[1] );
          uint16 numAttrs = BUILD_UINT16( pBuf[2], pBuf[3] );

          if ( ( ( uuid == GATT_PRIMARY_SERVICE_UUID )     ||
                 ( uuid == GATT_SECONDARY_SERVICE_UUID ) ) &&
               ( numAttrs > 0 ) )
          {
            uint8 encKeySize = pBuf[4];
            
            if ( ( encKeySize >= GATT_MIN_ENCRYPT_KEY_SIZE ) &&
                 ( encKeySize <= GATT_MAX_ENCRYPT_KEY_SIZE ) )
            {
              // Allocate buffer for the attribute table
              service.attrs = osal_mem_alloc( numAttrs * sizeof( gattAttribute_t ) );
              if ( service.attrs != NULL )
              {
                // Zero out all attribute fields
                VOID osal_memset( service.attrs, 0, numAttrs * sizeof( gattAttribute_t ) );

                totalAttrs = numAttrs;
                service.encKeySize = encKeySize;

                // Set up service record
                stat = addAttrRec( &service, pBuf, ATT_BT_UUID_SIZE,
                                   GATT_PERMIT_READ, &totalAttrs, pRspDataLen );
              }
              else
              {
                stat = bleMemAllocError;
              }
            }
            else
            {
              stat = bleInvalidRange;
            }
          }
          else
          {
            stat = INVALIDPARAMETER;
          }
        }
      }
      else
      {
        stat = blePending;
      }
      break;

    case HCI_EXT_GATT_DEL_SERVICE:
      {
        uint16 handle = BUILD_UINT16( pBuf[0], pBuf[1] );

        if ( handle == 0x0000 )
        {
          // Service is not registered with GATT yet
          freeAttrRecs( &service );

          totalAttrs = 0;
        }
        else
        {
          gattService_t serv;

          // Service is already registered with the GATT Server
          stat = GATT_DeregisterService( handle, &serv );
          if ( stat == SUCCESS )
          {
            freeAttrRecs( &serv );
          }
        }
        
        stat = SUCCESS;
      }
      break;

    case HCI_EXT_GATT_ADD_ATTRIBUTE:
      if ( service.attrs != NULL )
      {
        if ( ( pCmd->len-1 == ATT_UUID_SIZE ) ||
             ( pCmd->len-1 == ATT_BT_UUID_SIZE ) )
        {
          // Add attribute record to the service being added
          stat = addAttrRec( &service, pBuf, pCmd->len-1,
                             pBuf[pCmd->len-1], &totalAttrs, pRspDataLen );
        }
      }
      else // no corresponding service
      {
        stat = INVALIDPARAMETER;
      }
      break;
#endif // GATT_DB_OFF_CHIP

    default:
      stat = FAILURE;
      break;
  }

  if ( ( pPayload != NULL ) && safeToDealloc )
  {
    // Free payload
    osal_bm_free( pPayload );
  }
  
  return ( mapATT2BLEStatus( stat ) );
}

/*********************************************************************
 * @fn      processExtMsgGAP
 *
 * @brief   Parse and process incoming HCI extension GAP messages.
 *
 * @param   cmdID - incoming HCI extension command ID.
 * @param   pCmd - incoming HCI extension message.
 * @param   pRspDataLen - response data length to be returned.
 *
 * @return  SUCCESS, INVALIDPARAMETER, FAILURE,
 *          or bleMemAllocError
 */
static uint8 processExtMsgGAP( uint8 cmdID, hciExtCmd_t *pCmd, uint8 *pRspDataLen )
{
  uint8 *pBuf = pCmd->pData;
  bStatus_t stat = SUCCESS;

  switch( cmdID )
  {
    case HCI_EXT_GAP_DEVICE_INIT:
      {
        uint32 signCounter;
        uint8 profileRole = pBuf[0];

        // Copy the IRK, SRK and sign counter from the command if they aren't all "0",
        // otherwise use what's in NV
        if ( osal_isbufset( &pBuf[2], 0, KEYLEN ) == FALSE )
        {
          VOID osal_memcpy( IRK, &pBuf[2], KEYLEN );
        }

        if ( osal_isbufset( &pBuf[2+KEYLEN], 0, KEYLEN ) == FALSE )
        {
          VOID osal_memcpy( SRK, &pBuf[2+KEYLEN], KEYLEN );
        }

        signCounter = BUILD_UINT32( pBuf[2+KEYLEN+KEYLEN+0], pBuf[2+KEYLEN+KEYLEN+1],
                                        pBuf[2+KEYLEN+KEYLEN+2], pBuf[2+KEYLEN+KEYLEN+3] );
        if ( signCounter > 0 )
        {
          hciExtSignCounter = signCounter;
        }

        stat = GAP_DeviceInit( hciExtApp_TaskID, profileRole, pBuf[1], IRK, SRK, &hciExtSignCounter );

        // Take over the processing of Authentication messages
        VOID GAP_SetParamValue( TGAP_AUTH_TASK_ID, hciExtApp_TaskID );
      }
      break;

    case HCI_EXT_GAP_CONFIG_DEVICE_ADDR:
      {
        uint8 *pStaticAddr = NULL;
        uint8 nullAddr[B_ADDR_LEN] = {0};

        if ( osal_memcmp( &pBuf[1], nullAddr, B_ADDR_LEN ) != TRUE )
        {
          pStaticAddr = &pBuf[1];
        }

        stat = GAP_ConfigDeviceAddr( pBuf[0], pStaticAddr );
      }
      break;

#if ( HOST_CONFIG & ( CENTRAL_CFG | OBSERVER_CFG ) )
    case HCI_EXT_GAP_DEVICE_DISC_REQ:
      {
        gapDevDiscReq_t discReq;

        discReq.taskID = hciExtApp_TaskID;
        discReq.mode = *pBuf++;
        discReq.activeScan = *pBuf++;
        discReq.whiteList = *pBuf;

        stat = GAP_DeviceDiscoveryRequest( &discReq );
      }
      break;

    case HCI_EXT_GAP_DEVICE_DISC_CANCEL:
      stat = GAP_DeviceDiscoveryCancel( hciExtApp_TaskID );
      break;
#endif // OBSERVER_CFG | CENTRAL_CFG

#if ( HOST_CONFIG & CENTRAL_CFG )
    case HCI_EXT_GAP_EST_LINK_REQ:
      {
        gapEstLinkReq_t linkReq;

        linkReq.taskID = hciExtApp_TaskID;
        linkReq.highDutyCycle = *pBuf++;
        linkReq.whiteList = *pBuf++;
        linkReq.addrTypePeer = *pBuf++;
        VOID osal_memcpy( linkReq.peerAddr, pBuf, B_ADDR_LEN );

        stat =  GAP_EstablishLinkReq( &linkReq );
      }
      break;
#endif // CENTRAL_CFG

#if ( HOST_CONFIG & ( PERIPHERAL_CFG | BROADCASTER_CFG ) )
    case HCI_EXT_GAP_MAKE_DISCOVERABLE:
      {
        gapAdvertisingParams_t adParams;

        adParams.eventType = *pBuf++;
        adParams.initiatorAddrType = *pBuf++;
        VOID osal_memcpy( adParams.initiatorAddr, pBuf, B_ADDR_LEN );
        pBuf += B_ADDR_LEN;
        adParams.channelMap = *pBuf++;
        adParams.filterPolicy = *pBuf;
        stat = GAP_MakeDiscoverable( hciExtApp_TaskID, &adParams );
      }
      break;

    case HCI_EXT_GAP_UPDATE_ADV_DATA:
      stat = GAP_UpdateAdvertisingData( hciExtApp_TaskID, pBuf[0], pBuf[1], &pBuf[2] );
      break;

    case HCI_EXT_GAP_END_DISC:
      stat = GAP_EndDiscoverable( hciExtApp_TaskID );
      break;
#endif // PERIPHERAL_CFG | BROADCASTER_CFG

#if ( HOST_CONFIG & ( CENTRAL_CFG | PERIPHERAL_CFG ) )
    case HCI_EXT_GAP_TERMINATE_LINK:
      stat = GAP_TerminateLinkReq( hciExtApp_TaskID, BUILD_UINT16( pBuf[0], pBuf[1] ), pBuf[2] );
      break;

    case HCI_EXT_GAP_UPDATE_LINK_PARAM_REQ:
      {
        gapUpdateLinkParamReq_t updateLinkReq;

        updateLinkReq.connectionHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        updateLinkReq.intervalMin = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        updateLinkReq.intervalMax = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        updateLinkReq.connLatency = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        updateLinkReq.connTimeout = BUILD_UINT16( pBuf[0], pBuf[1] );

        stat = GAP_UpdateLinkParamReq( &updateLinkReq );
      }
      break;
      
    case HCI_EXT_GAP_AUTHENTICATE:
      {
        uint8 tmp;
        gapAuthParams_t params;
        gapPairingReq_t pairReq;
        gapPairingReq_t *pPairReq = NULL;

#if ( OSALMEM_METRICS )
        uint16 memUsed = osal_heap_mem_used();
#endif

        VOID osal_memset( &params, 0, sizeof ( gapAuthParams_t ) );

        params.connectionHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;

        params.secReqs.ioCaps = *pBuf++;
        params.secReqs.oobAvailable = *pBuf++;
        VOID osal_memcpy( params.secReqs.oob, pBuf, KEYLEN );
        pBuf += KEYLEN;
        params.secReqs.authReq = *pBuf++;
        params.secReqs.maxEncKeySize = *pBuf++;

        tmp = *pBuf++;
        params.secReqs.keyDist.sEncKey = ( tmp & KEYDIST_SENC ) ? TRUE : FALSE;
        params.secReqs.keyDist.sIdKey = ( tmp & KEYDIST_SID ) ? TRUE : FALSE;
        params.secReqs.keyDist.sSign = ( tmp & KEYDIST_SSIGN ) ? TRUE : FALSE;
        params.secReqs.keyDist.sLinkKey = ( tmp & KEYDIST_SLINK ) ? TRUE : FALSE;
        params.secReqs.keyDist.sReserved = 0;
        params.secReqs.keyDist.mEncKey = ( tmp & KEYDIST_MENC ) ? TRUE : FALSE;
        params.secReqs.keyDist.mIdKey = ( tmp & KEYDIST_MID ) ? TRUE : FALSE;
        params.secReqs.keyDist.mSign = ( tmp & KEYDIST_MSIGN ) ? TRUE : FALSE;
        params.secReqs.keyDist.mLinkKey = ( tmp & KEYDIST_MLINK ) ? TRUE : FALSE;
        params.secReqs.keyDist.mReserved = 0;

        tmp = *pBuf++;
        if ( tmp )
        {
          pairReq.ioCap = *pBuf++;
          pairReq.oobDataFlag = *pBuf++;
          pairReq.authReq = *pBuf++;
          pairReq.maxEncKeySize = *pBuf++;
          tmp = *pBuf++;
          pairReq.keyDist.sEncKey = ( tmp & KEYDIST_SENC ) ? TRUE : FALSE;
          pairReq.keyDist.sIdKey = ( tmp & KEYDIST_SID ) ? TRUE : FALSE;
          pairReq.keyDist.sSign = ( tmp & KEYDIST_SSIGN ) ? TRUE : FALSE;
          pairReq.keyDist.sLinkKey = ( tmp & KEYDIST_SLINK ) ? TRUE : FALSE;
          pairReq.keyDist.sReserved = 0;
          pairReq.keyDist.mEncKey = ( tmp & KEYDIST_MENC ) ? TRUE : FALSE;
          pairReq.keyDist.mIdKey = ( tmp & KEYDIST_MID ) ? TRUE : FALSE;
          pairReq.keyDist.mSign = ( tmp & KEYDIST_MSIGN ) ? TRUE : FALSE;
          pairReq.keyDist.mLinkKey = ( tmp & KEYDIST_MLINK ) ? TRUE : FALSE;
          pairReq.keyDist.mReserved = 0;
          pPairReq = &pairReq;
        }

        stat = GAP_Authenticate( &params, pPairReq );

#if ( OSALMEM_METRICS )
        *pRspDataLen = 2;
        rspBuf[RSP_PAYLOAD_IDX] = LO_UINT16( memUsed );
        rspBuf[RSP_PAYLOAD_IDX+1] = HI_UINT16( memUsed );
#endif
      }
      break;

    case HCI_EXT_GAP_TERMINATE_AUTH:
      stat = GAP_TerminateAuth( BUILD_UINT16( pBuf[0], pBuf[1] ), pBuf[2] );
      break;

    case HCI_EXT_GAP_BOND:
      {
        uint16 connectionHandle;
        smSecurityInfo_t securityInfo;
        uint8 authenticated;

        // Do Security Information part
        connectionHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        authenticated = *pBuf++;
        VOID osal_memcpy( securityInfo.ltk, pBuf, KEYLEN );
        pBuf += KEYLEN;
        securityInfo.div = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;
        VOID osal_memcpy( securityInfo.rand, pBuf, B_RANDOM_NUM_SIZE );
        pBuf += B_RANDOM_NUM_SIZE;
        securityInfo.keySize = *pBuf++;

        stat = GAP_Bond( connectionHandle, authenticated, &securityInfo, TRUE );
      }
      break;

    case HCI_EXT_GAP_SIGNABLE:
      {
        uint16 connectionHandle;
        uint8 authenticated;
        smSigningInfo_t signing;

        connectionHandle = BUILD_UINT16( pBuf[0], pBuf[1] );
        pBuf += 2;

        authenticated = *pBuf++;

        VOID osal_memcpy( signing.srk, pBuf, KEYLEN );
        pBuf += KEYLEN;

        signing.signCounter = BUILD_UINT32( pBuf[0], pBuf[1], pBuf[2], pBuf[3] );

        stat = GAP_Signable( connectionHandle, authenticated, &signing );
      }
      break;

    case HCI_EXT_GAP_PASSKEY_UPDATE:
      stat = GAP_PasskeyUpdate( &pBuf[2], BUILD_UINT16( pBuf[0], pBuf[1] ) );
      break;
      
    case HCI_EXT_GAP_RESOLVE_PRIVATE_ADDR:
      {
        stat = GAP_ResolvePrivateAddr( &pBuf[0], &pBuf[KEYLEN] );
      }
      break;
#endif // CENTRAL_CFG | PERIPHERAL_CFG
      
    case HCI_EXT_GAP_SET_PARAM:
      {
        uint16 id = (uint16)pBuf[0];
        uint16 value = BUILD_UINT16( pBuf[1], pBuf[2] );

        if ( ( id != TGAP_AUTH_TASK_ID ) && ( id < TGAP_PARAMID_MAX ) )
        {
          stat = GAP_SetParamValue( id, value );
        }
#if !defined ( GATT_DB_OFF_CHIP ) && defined ( TESTMODES )
        else if ( id == TGAP_GATT_TESTCODE )
        {
          GATTServApp_SetParamValue( value );
        }
        else if ( id == TGAP_ATT_TESTCODE )
        {
          ATT_SetParamValue( value );
        }
        else if ( id == TGAP_GGS_TESTCODE )
        {
          GGS_SetParamValue( value );
        }
        else if ( id == TGAP_L2CAP_TESTCODE )
        {
          L2CAP_SetParamValue( value );
        }
#endif // !GATT_DB_OFF_CHIP && TESTMODES
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case HCI_EXT_GAP_GET_PARAM:
      {
        uint16 paramValue = 0xFFFF;
        uint16 param = (uint16)pBuf[0];

        if ( param < 0x00FF )
        {
          if ( ( param != TGAP_AUTH_TASK_ID ) && ( param < TGAP_PARAMID_MAX ) )
          {
            paramValue = GAP_GetParamValue( param );
          }
#if !defined ( GATT_DB_OFF_CHIP ) && defined ( TESTMODES )
          else if ( param == TGAP_GATT_TESTCODE )
          {
            paramValue = GATTServApp_GetParamValue();
          }
          else if ( param == TGAP_ATT_TESTCODE )
          {
            paramValue = ATT_GetParamValue();
          }
          else if ( param == TGAP_GGS_TESTCODE )
          {
            paramValue = GGS_GetParamValue();
          }
          else if ( param == TGAP_L2CAP_TESTCODE )
          {
            paramValue = L2CAP_GetParamValue();
          }
#endif // !GATT_DB_OFF_CHIP && TESTMODES
        }
#if ( OSALMEM_METRICS )
        else
        {
          paramValue = osal_heap_mem_used();
        }
#endif
        if ( paramValue != 0xFFFF )
        {
          stat = SUCCESS;
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
        *pRspDataLen = 2;
        rspBuf[RSP_PAYLOAD_IDX] = LO_UINT16( paramValue );
        rspBuf[RSP_PAYLOAD_IDX+1] = HI_UINT16( paramValue );
      }
      break;

#if ( HOST_CONFIG & PERIPHERAL_CFG )
    case HCI_EXT_GAP_SLAVE_SECURITY_REQ_UPDATE:
      stat = GAP_SendSlaveSecurityRequest( BUILD_UINT16( pBuf[0], pBuf[1] ), pBuf[2] );
      break;
#endif // PERIPHERAL_CFG

#if ( HOST_CONFIG & ( PERIPHERAL_CFG | BROADCASTER_CFG ) )
    case HCI_EXT_GAP_SET_ADV_TOKEN:
      {
        gapAdvDataToken_t *pToken;
        uint8 attrLen = pBuf[1];

        pToken = (gapAdvDataToken_t *)osal_mem_alloc( sizeof ( gapAdvDataToken_t ) + attrLen );
        if ( pToken )
        {
          pToken->adType = pBuf[0];
          pToken->attrLen =attrLen;
          pToken->pAttrData = (uint8 *)(pToken+1);

          VOID osal_memcpy( pToken->pAttrData, &pBuf[2], attrLen );
          stat = GAP_SetAdvToken( pToken );
          if ( stat != SUCCESS )
          {
            osal_mem_free( pToken );
          }
        }
        else
        {
          stat = bleMemAllocError;
        }
      }
      break;

    case HCI_EXT_GAP_REMOVE_ADV_TOKEN:
      {
        gapAdvDataToken_t *pToken = GAP_RemoveAdvToken( pBuf[0] );
        if ( pToken )
        {
          osal_mem_free( pToken );
          stat = SUCCESS;
        }
        else
        {
          stat = INVALIDPARAMETER;
        }
      }
      break;

    case HCI_EXT_GAP_UPDATE_ADV_TOKENS:
      {
        stat = GAP_UpdateAdvTokens();
      }
      break;
#endif // PERIPHERAL_CFG | BROADCASTER_CFG

    case HCI_EXT_GAP_BOND_SET_PARAM:
      {
#if defined ( GAP_BOND_MGR )
        uint16 id = BUILD_UINT16( pBuf[0], pBuf[1] );
        uint8 *pValue;
        uint32 passcode;

        switch ( id )
        {
          case GAPBOND_DEFAULT_PASSCODE:
            // First build passcode
            passcode = osal_build_uint32( &pBuf[3], pBuf[2] );
            pValue = (uint8 *)&passcode;
            break;

          default:
            pValue = &pBuf[3];
            break;
        }

        if ( stat == SUCCESS )
        {
          stat = GAPBondMgr_SetParameter( id, pBuf[2],  pValue );
        }
#else
        stat = INVALIDPARAMETER;
#endif
      }
      break;

    case HCI_EXT_GAP_BOND_GET_PARAM:
      {
        uint8 len = 0;
#if defined ( GAP_BOND_MGR )
        uint16 id = BUILD_UINT16( pBuf[0], pBuf[1] );

        stat = GAPBondMgr_GetParameter( id, &rspBuf[RSP_PAYLOAD_IDX] );

        switch ( id )
        {
          case GAPBOND_INITIATE_WAIT:
            len = 2;
            break;

          case GAPBOND_OOB_DATA:
            len = KEYLEN;
            break;

          case GAPBOND_DEFAULT_PASSCODE:
            len = 4;
            break;

          default:
            len = 1;
            break;
        }
#else
        stat = INVALIDPARAMETER;
#endif
        *pRspDataLen = len;
      }
      break;

#ifndef GATT_NO_SERIVCE_CHANGED
    case HCI_EXT_GAP_BOND_SERVICE_CHANGE:
      {
#if defined ( GAP_BOND_MGR )
        stat = GAPBondMgr_ServiceChangeInd( BUILD_UINT16( pBuf[0], pBuf[1] ), pBuf[2] );
#else
        stat = INVALIDPARAMETER;
#endif
      }
      break;
#endif // GATT_NO_SERIVCE_CHANGED
      
    default:
      stat = FAILURE;
      break;
  }

  return ( stat );
}

/*********************************************************************
 * @fn      processEvents
 *
 * @brief   Process an incoming Event messages.
 *
 * @param   pMsg - message to process
 *
 * @return  none
 */
static uint8 processEvents( osal_event_hdr_t *pMsg )
{
  uint8 msgLen = 0;
  uint8 *pBuf = NULL;
  uint8 allocated = FALSE;
  uint8 deallocateIncoming = TRUE;

  VOID osal_memset( out_msg, 0, sizeof ( out_msg ) );

  switch ( pMsg->event )
  {
    case GAP_MSG_EVENT:
      pBuf = processEventsGAP( (gapEventHdr_t *)pMsg, out_msg, &msgLen, &allocated, &deallocateIncoming );
      break;

    case L2CAP_SIGNAL_EVENT:
      pBuf = processEventsL2CAP( (l2capSignalEvent_t *)pMsg, out_msg, &msgLen );
      break;

    case L2CAP_DATA_EVENT:
      pBuf = processDataL2CAP( (l2capDataEvent_t *)pMsg, out_msg, &msgLen, &allocated );
      break;
      
    case GATT_MSG_EVENT:
      pBuf = processEventsGATT( (gattMsgEvent_t *)pMsg, out_msg, &msgLen, &allocated );
      break;
#ifndef GATT_DB_OFF_CHIP
    case GATT_SERV_MSG_EVENT:
      pBuf = processEventsGATTServ( (gattEventHdr_t *)pMsg, out_msg, &msgLen );
      break;
#endif
    default:
      break; // ignore
  }

  // Deallocate here to free up heap space for the serial message set out HCI.
  if ( deallocateIncoming )
  {
    VOID osal_msg_deallocate( (uint8 *)pMsg );
  }

  if ( msgLen )
  {
    HCI_SendControllerToHostEvent( HCI_VE_EVENT_CODE,  msgLen, pBuf );
  }

  if ( (pBuf != NULL) && (allocated == TRUE) )
  {
    osal_mem_free( pBuf );
  }

  return ( FALSE );
}

/*********************************************************************
 * @fn      processEventsGAP
 *
 * @brief   Process an incoming GAP Event messages.
 *
 * @param   pMsg - message to process
 * @param   pOutMsg - outgoing message to be built
 * @param   pMsgLen - length of outgoing message
 * @param   pAllocated - whether outgoing message is locally allocated
 * @param   pDeallocate - whether it's safe to deallocate incoming message
 *
 * @return  outgoing message
 */
static uint8 *processEventsGAP( gapEventHdr_t *pMsg, uint8 *pOutMsg, uint8 *pMsgLen,
                                uint8 *pAllocated, uint8 *pDeallocate )
{
  uint8 msgLen = 0;
  uint8 *pBuf = NULL;

  *pDeallocate = TRUE;

  switch ( pMsg->opcode )
  {
    case GAP_DEVICE_INIT_DONE_EVENT:
      {
        gapDeviceInitDoneEvent_t *pPkt = (gapDeviceInitDoneEvent_t *)pMsg;

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_DEVICE_INIT_DONE_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_DEVICE_INIT_DONE_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        VOID osal_memcpy( &pOutMsg[3], pPkt->devAddr, B_ADDR_LEN );
        pOutMsg[9]  = LO_UINT16( pPkt->dataPktLen );
        pOutMsg[10] = HI_UINT16( pPkt->dataPktLen );
        pOutMsg[11] = pPkt->numDataPkts;

        // Copy the Device's local keys
        VOID osal_memcpy( &pOutMsg[12], IRK, KEYLEN );
        VOID osal_memcpy( &pOutMsg[12+KEYLEN], SRK, KEYLEN );

        if ( pPkt->hdr.status == SUCCESS )
        {
          VOID osal_snv_write( BLE_NVID_IRK, KEYLEN, IRK );
          VOID osal_snv_write( BLE_NVID_CSRK, KEYLEN, SRK );
          VOID osal_snv_write( BLE_NVID_SIGNCOUNTER, sizeof( uint32 ), &hciExtSignCounter );
        }

        pBuf = pOutMsg;
        msgLen = 44;
      }
      break;

    case GAP_DEVICE_DISCOVERY_EVENT:
      {
        gapDevDiscEvent_t *pPkt = (gapDevDiscEvent_t *)pMsg;

        if ( (pPkt->hdr.status == SUCCESS) && (pPkt->numDevs > 0) )
        {
          uint8 x;
          gapDevRec_t *devList = pPkt->pDevList;

          // Calculate buffer needed
          msgLen = 4; // Size of opCode, status and numDevs field
          msgLen += (pPkt->numDevs * 8); // Num devices * (eventType, addrType, addr)

          pBuf = osal_mem_alloc( msgLen );
          if ( pBuf )
          {
            uint8 *buf = pBuf;

            // Fill in header
            *buf++ = LO_UINT16( HCI_EXT_GAP_DEVICE_DISCOVERY_EVENT );
            *buf++ = HI_UINT16( HCI_EXT_GAP_DEVICE_DISCOVERY_EVENT );
            *buf++ = pPkt->hdr.status;
            *buf++ = pPkt->numDevs;

            devList = pPkt->pDevList;
            for ( x = 0; x < pPkt->numDevs; x++, devList++ )
            {
              *buf++ = devList->eventType;
              *buf++ = devList->addrType;
              VOID osal_memcpy( buf, devList->addr, B_ADDR_LEN );
              buf += B_ADDR_LEN;
            }

            *pAllocated = TRUE;
          }
          else
          {
            pPkt->hdr.status = bleMemAllocError;
          }
        }

        if ( (pPkt->hdr.status != SUCCESS) || (pPkt->numDevs == 0) )
        {
          pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_DEVICE_DISCOVERY_EVENT );
          pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_DEVICE_DISCOVERY_EVENT );
          pOutMsg[2] = pPkt->hdr.status;
          pOutMsg[3] = 0;
          pBuf = pOutMsg;
          msgLen = 4; // Size of opCode, status and numDevs field
        }
      }
      break;

    case GAP_ADV_DATA_UPDATE_DONE_EVENT:
      {
        gapAdvDataUpdateEvent_t *pPkt = (gapAdvDataUpdateEvent_t *)pMsg;

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_ADV_DATA_UPDATE_DONE_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_ADV_DATA_UPDATE_DONE_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pOutMsg[3] = pPkt->adType;
        pBuf = pOutMsg;
        msgLen = 4;
      }
      break;

    case GAP_MAKE_DISCOVERABLE_DONE_EVENT:
      {
        gapMakeDiscoverableRspEvent_t *pPkt = (gapMakeDiscoverableRspEvent_t *)pMsg;

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_MAKE_DISCOVERABLE_DONE_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_MAKE_DISCOVERABLE_DONE_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pBuf = pOutMsg;
        msgLen = 3;
      }
      break;

    case GAP_END_DISCOVERABLE_DONE_EVENT:
      pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_END_DISCOVERABLE_DONE_EVENT );
      pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_END_DISCOVERABLE_DONE_EVENT );
      pOutMsg[2] = pMsg->hdr.status;
      pBuf = pOutMsg;
      msgLen = 3;
      break;

    case GAP_LINK_ESTABLISHED_EVENT:
      {
        gapEstLinkReqEvent_t *pPkt = (gapEstLinkReqEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
       if ( pPkt->hdr.status == SUCCESS )
       {
          // Notify the Bond Manager to the connection
          GAPBondMgr_LinkEst( pPkt->devAddrType, pPkt->devAddr, pPkt->connectionHandle, pPkt->connRole );
       }
#endif

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_LINK_ESTABLISHED_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_LINK_ESTABLISHED_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pOutMsg[3] = pPkt->devAddrType;
        VOID osal_memcpy( &(pOutMsg[4]), pPkt->devAddr, B_ADDR_LEN );
        pOutMsg[10] = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[11] = HI_UINT16( pPkt->connectionHandle );
        pOutMsg[12] = pPkt->connRole;
        pOutMsg[13] = LO_UINT16( pPkt->connInterval );
        pOutMsg[14] = HI_UINT16( pPkt->connInterval );
        pOutMsg[15] = LO_UINT16( pPkt->connLatency );
        pOutMsg[16] = HI_UINT16( pPkt->connLatency );
        pOutMsg[17] = LO_UINT16( pPkt->connTimeout );
        pOutMsg[18] = HI_UINT16( pPkt->connTimeout );
        pOutMsg[19] = pPkt->clockAccuracy;
        pBuf = pOutMsg;
        msgLen = 20;
      }
      break;

    case GAP_LINK_TERMINATED_EVENT:
      {
        gapTerminateLinkEvent_t *pPkt = (gapTerminateLinkEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_LINK_TERMINATED_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_LINK_TERMINATED_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pOutMsg[3] = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[4] = HI_UINT16( pPkt->connectionHandle );
        pOutMsg[5] = pPkt->reason;
        pBuf = pOutMsg;
        msgLen = 6;
      }
      break;

    case GAP_LINK_PARAM_UPDATE_EVENT:
      {
        gapLinkUpdateEvent_t *pPkt = (gapLinkUpdateEvent_t *)pMsg;

        pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_LINK_PARAM_UPDATE_EVENT );
        pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_LINK_PARAM_UPDATE_EVENT );
        pOutMsg[2]  = pPkt->hdr.status;
        pOutMsg[3]  = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[4]  = HI_UINT16( pPkt->connectionHandle );
        pOutMsg[5]  = LO_UINT16( pPkt->connInterval );
        pOutMsg[6]  = HI_UINT16( pPkt->connInterval );
        pOutMsg[7]  = LO_UINT16( pPkt->connLatency );
        pOutMsg[8]  = HI_UINT16( pPkt->connLatency );
        pOutMsg[9]  = LO_UINT16( pPkt->connTimeout );
        pOutMsg[10] = HI_UINT16( pPkt->connTimeout );
        pBuf = pOutMsg;
        msgLen = 11;
      }
      break;

    case GAP_RANDOM_ADDR_CHANGED_EVENT:
      {
        gapRandomAddrEvent_t *pPkt = (gapRandomAddrEvent_t *)pMsg;

        pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_RANDOM_ADDR_CHANGED_EVENT );
        pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_RANDOM_ADDR_CHANGED_EVENT );
        pOutMsg[2]  = pPkt->hdr.status;
        pOutMsg[3]  = pPkt->addrType;
        VOID osal_memcpy( &(pOutMsg[4]), pPkt->newRandomAddr, B_ADDR_LEN );
        pBuf = pOutMsg;
        msgLen = 10;
      }
      break;

    case GAP_SIGNATURE_UPDATED_EVENT:
      {
        gapSignUpdateEvent_t *pPkt = (gapSignUpdateEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_SIGNATURE_UPDATED_EVENT );
        pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_SIGNATURE_UPDATED_EVENT );
        pOutMsg[2]  = pPkt->hdr.status;
        pOutMsg[3]  = pPkt->addrType;
        VOID osal_memcpy( &(pOutMsg[4]), pPkt->devAddr, B_ADDR_LEN );
        pOutMsg[10] = BREAK_UINT32( pPkt->signCounter, 0 );
        pOutMsg[11] = BREAK_UINT32( pPkt->signCounter, 1 );
        pOutMsg[12] = BREAK_UINT32( pPkt->signCounter, 2 );
        pOutMsg[13] = BREAK_UINT32( pPkt->signCounter, 3 );
        pBuf = pOutMsg;
        msgLen = 14;
      }
      break;

    case GAP_PASSKEY_NEEDED_EVENT:
      {
        gapPasskeyNeededEvent_t *pPkt = (gapPasskeyNeededEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif
        pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_PASSKEY_NEEDED_EVENT );
        pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_PASSKEY_NEEDED_EVENT );
        pOutMsg[2]  = pPkt->hdr.status;
        VOID osal_memcpy( &(pOutMsg[3]), pPkt->deviceAddr, B_ADDR_LEN );
        pOutMsg[9] = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[10] = HI_UINT16( pPkt->connectionHandle );
        pOutMsg[11] = pPkt->uiInputs;
        pOutMsg[12] = pPkt->uiOutputs;
        pBuf = pOutMsg;
        msgLen = 13;
      }
      break;

    case GAP_AUTHENTICATION_COMPLETE_EVENT:
      {
        gapAuthCompleteEvent_t *pPkt = (gapAuthCompleteEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        *pDeallocate = GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        msgLen = 106;

        pBuf = osal_mem_alloc( msgLen );
        if ( pBuf )
        {
          uint8 *buf = pBuf;

          *pAllocated = TRUE;

          VOID osal_memset( buf, 0, msgLen );

          *buf++  = LO_UINT16( HCI_EXT_GAP_AUTH_COMPLETE_EVENT );
          *buf++  = HI_UINT16( HCI_EXT_GAP_AUTH_COMPLETE_EVENT );
          *buf++  = pPkt->hdr.status;
          *buf++  = LO_UINT16( pPkt->connectionHandle );
          *buf++  = HI_UINT16( pPkt->connectionHandle );
          *buf++  = pPkt->authState;

          if ( pPkt->pSecurityInfo )
          {
            *buf++ = TRUE;
            *buf++ = pPkt->pSecurityInfo->keySize;
            VOID osal_memcpy( buf, pPkt->pSecurityInfo->ltk, KEYLEN );
            buf += KEYLEN;
            *buf++ = LO_UINT16( pPkt->pSecurityInfo->div );
            *buf++ = HI_UINT16( pPkt->pSecurityInfo->div );
            VOID osal_memcpy( buf, pPkt->pSecurityInfo->rand, B_RANDOM_NUM_SIZE );
            buf += B_RANDOM_NUM_SIZE;
          }
          else
          {
            // Skip securityInfo
            buf += 1 + KEYLEN + B_RANDOM_NUM_SIZE + 2 + 1;
          }

          if ( pPkt->pDevSecInfo )
          {
            *buf++ = TRUE;
            *buf++ = pPkt->pDevSecInfo->keySize;
            VOID osal_memcpy( buf, pPkt->pDevSecInfo->ltk, KEYLEN );
            buf += KEYLEN;
            *buf++ = LO_UINT16( pPkt->pDevSecInfo->div );
            *buf++ = HI_UINT16( pPkt->pDevSecInfo->div );
            VOID osal_memcpy( buf, pPkt->pDevSecInfo->rand, B_RANDOM_NUM_SIZE );
            buf += B_RANDOM_NUM_SIZE;
          }
          else
          {
            // Skip securityInfo
            buf += 1 + KEYLEN + B_RANDOM_NUM_SIZE + 2 + 1;
          }

          if ( pPkt->pIdentityInfo )
          {
            *buf++ = TRUE;
            VOID osal_memcpy( buf, pPkt->pIdentityInfo->irk, KEYLEN );
            buf += KEYLEN;
            VOID osal_memcpy( buf, pPkt->pIdentityInfo->bd_addr, B_ADDR_LEN );
            buf += B_ADDR_LEN;
          }
          else
          {
            // Skip identityInfo
            buf += KEYLEN + B_ADDR_LEN + 1;
          }

          if ( pPkt->pSigningInfo )
          {
            *buf++ = TRUE;
            VOID osal_memcpy( buf, pPkt->pSigningInfo->srk, KEYLEN );
            buf += KEYLEN;

            *buf++ = BREAK_UINT32( pPkt->pSigningInfo->signCounter, 0 );
            *buf++ = BREAK_UINT32( pPkt->pSigningInfo->signCounter, 1 );
            *buf++ = BREAK_UINT32( pPkt->pSigningInfo->signCounter, 2 );
            *buf = BREAK_UINT32( pPkt->pSigningInfo->signCounter, 3 );
          }
        }
        else
        {
          pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_AUTH_COMPLETE_EVENT );
          pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_AUTH_COMPLETE_EVENT );
          pOutMsg[2]  = bleMemAllocError;
          pOutMsg[3]  = LO_UINT16( pPkt->connectionHandle );
          pOutMsg[4]  = HI_UINT16( pPkt->connectionHandle );
          pBuf = pOutMsg;
          msgLen = 5;
        }
      }
      break;

    case GAP_BOND_COMPLETE_EVENT:
      {
        gapBondCompleteEvent_t *pPkt = (gapBondCompleteEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_BOND_COMPLETE_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_BOND_COMPLETE_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pOutMsg[3] = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[4] = HI_UINT16( pPkt->connectionHandle );
        pBuf = pOutMsg;
        msgLen = 5;
      }
      break;

    case GAP_PAIRING_REQ_EVENT:
      {
        gapPairingReqEvent_t *pPkt = (gapPairingReqEvent_t *)pMsg;
        uint8 tmp = 0;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        pOutMsg[0] = LO_UINT16( HCI_EXT_GAP_PAIRING_REQ_EVENT );
        pOutMsg[1] = HI_UINT16( HCI_EXT_GAP_PAIRING_REQ_EVENT );
        pOutMsg[2] = pPkt->hdr.status;
        pOutMsg[3] = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[4] = HI_UINT16( pPkt->connectionHandle );
        pOutMsg[5] = pPkt->pairReq.ioCap;
        pOutMsg[6] = pPkt->pairReq.oobDataFlag;
        pOutMsg[7] = pPkt->pairReq.authReq;
        pOutMsg[8] = pPkt->pairReq.maxEncKeySize;

        tmp |= ( pPkt->pairReq.keyDist.sEncKey ) ? KEYDIST_SENC : 0;
        tmp |= ( pPkt->pairReq.keyDist.sIdKey ) ? KEYDIST_SID : 0;
        tmp |= ( pPkt->pairReq.keyDist.sSign ) ? KEYDIST_SSIGN : 0;
        tmp |= ( pPkt->pairReq.keyDist.sLinkKey ) ? KEYDIST_SLINK : 0;
        tmp |= ( pPkt->pairReq.keyDist.mEncKey ) ? KEYDIST_MENC : 0;
        tmp |= ( pPkt->pairReq.keyDist.mIdKey ) ? KEYDIST_MID : 0;
        tmp |= ( pPkt->pairReq.keyDist.mSign ) ? KEYDIST_MSIGN : 0;
        tmp |= ( pPkt->pairReq.keyDist.mLinkKey ) ? KEYDIST_MLINK : 0;
        pOutMsg[9] = tmp;

        pBuf = pOutMsg;
        msgLen = 10;
      }
      break;

    case GAP_SLAVE_REQUESTED_SECURITY_EVENT:
      {
        gapSlaveSecurityReqEvent_t *pPkt = (gapSlaveSecurityReqEvent_t *)pMsg;

#if defined ( GAP_BOND_MGR )
        VOID GAPBondMgr_ProcessGAPMsg( (gapEventHdr_t *)pMsg );
#endif

        pOutMsg[0]  = LO_UINT16( HCI_EXT_GAP_SLAVE_REQUESTED_SECURITY_EVENT );
        pOutMsg[1]  = HI_UINT16( HCI_EXT_GAP_SLAVE_REQUESTED_SECURITY_EVENT );
        pOutMsg[2]  = pPkt->hdr.status;
        pOutMsg[3]  = LO_UINT16( pPkt->connectionHandle );
        pOutMsg[4]  = HI_UINT16( pPkt->connectionHandle );
        VOID osal_memcpy( &(pOutMsg[5]), pPkt->deviceAddr, B_ADDR_LEN );
        pOutMsg[11] = pPkt->authReq;
        pBuf = pOutMsg;
        msgLen = 12;
      }
      break;

    case GAP_DEVICE_INFO_EVENT:
      {
        gapDeviceInfoEvent_t *pPkt = (gapDeviceInfoEvent_t *)pMsg;

        msgLen = 13 + pPkt->dataLen;

        pBuf = osal_mem_alloc( msgLen );
        if ( pBuf )
        {
          uint8 *buf = pBuf;

          // Fill in header
          *buf++ = LO_UINT16( HCI_EXT_GAP_DEVICE_INFO_EVENT );
          *buf++ = HI_UINT16( HCI_EXT_GAP_DEVICE_INFO_EVENT );
          *buf++ = pPkt->hdr.status;
          *buf++ = pPkt->eventType;
          *buf++ = pPkt->addrType;

          VOID osal_memcpy( buf, pPkt->addr, B_ADDR_LEN );
          buf += B_ADDR_LEN;

          *buf++ = (uint8)pPkt->rssi;
          *buf++ = pPkt->dataLen;
          VOID osal_memcpy( buf, pPkt->pEvtData, pPkt->dataLen );

          *pAllocated = TRUE;
        }
        else
        {
          pPkt->hdr.status = bleMemAllocError;
        }
      }
      break;

    default:
      // Unknown command
      break;
  }

  *pMsgLen = msgLen;

  return ( pBuf );
}

/*********************************************************************
 * @fn      processEventsL2CAP
 *
 * @brief   Process an incoming L2CAP Event messages.
 *
 * @param   pPkt - packet to process
 * @param   pOutMsg - outgoing message to be built
 * @param   pMsgLen - length of outgoing message
 *
 * @return  outgoing message
 */
static uint8 *processEventsL2CAP( l2capSignalEvent_t *pPkt, uint8 *pOutMsg, uint8 *pMsgLen )
{
  uint8 msgLen;

  // Build the message header first
  msgLen = buildHCIExtHeader( pOutMsg, (HCI_EXT_L2CAP_EVENT | pPkt->opcode),
                              pPkt->hdr.status, pPkt->connHandle );
#ifdef L2CAP_CO_CHANNELS 
  // Build Send SDU Done event regardless of status
  if ( pPkt->opcode == L2CAP_SEND_SDU_DONE_EVT )
  {
    l2capSendSduDoneEvt_t *pSduEvt = &(pPkt->cmd.sendSduDoneEvt);
    
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->CID );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->CID );
      
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->credits );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->credits );
    
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->peerCID );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->peerCID );
              
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->peerCredits );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->peerCredits );
    
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->totalLen );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->totalLen );
    
    pOutMsg[msgLen++] = LO_UINT16( pSduEvt->txLen );
    pOutMsg[msgLen++] = HI_UINT16( pSduEvt->txLen );
  }
  else
#endif // L2CAP_CO_CHANNELS
  if ( pPkt->hdr.status == SUCCESS ) // Build all other messages if status is success
  {
    switch ( pPkt->opcode )
    {
      case L2CAP_CMD_REJECT:
        msgLen += L2CAP_BuildCmdReject( &pOutMsg[msgLen], (uint8 *)&(pPkt->cmd.cmdReject) );
        break;
        
      case L2CAP_PARAM_UPDATE_RSP:
        msgLen += L2CAP_BuildParamUpdateRsp( &pOutMsg[msgLen], (uint8 *)&(pPkt->cmd.updateRsp) );
        break;
        
      case L2CAP_INFO_RSP:
        msgLen += L2CAP_BuildInfoRsp( &pOutMsg[msgLen], (uint8 *)&(pPkt->cmd.infoRsp) );
        break;

#ifdef L2CAP_CO_CHANNELS      
      case L2CAP_CONNECT_REQ:
        pOutMsg[msgLen++] = pPkt->id;
        msgLen += L2CAP_BuildConnectReq( &pOutMsg[msgLen], (uint8 *)&(pPkt->cmd.connectReq) );
        break;
        
      case L2CAP_CHANNEL_ESTABLISHED_EVT:
        {
          l2capChannelEstEvt_t *pEstEvt = &(pPkt->cmd.channelEstEvt);

          pOutMsg[msgLen++] = LO_UINT16( pEstEvt->result );
          pOutMsg[msgLen++] = HI_UINT16( pEstEvt->result );
          
          if ( pEstEvt->result == L2CAP_CONN_SUCCESS )
          {
            msgLen += buildCoChannelInfo( pEstEvt->CID, &pEstEvt->info, &pOutMsg[msgLen] );
          }
        }
        break;
        
       case L2CAP_CHANNEL_TERMINATED_EVT:
        {
          l2capChannelTermEvt_t *pTermEvt = &(pPkt->cmd.channelTermEvt);

          pOutMsg[msgLen++] = LO_UINT16( pTermEvt->CID );
          pOutMsg[msgLen++] = HI_UINT16( pTermEvt->CID );

          pOutMsg[msgLen++] = LO_UINT16( pTermEvt->peerCID );
          pOutMsg[msgLen++] = HI_UINT16( pTermEvt->peerCID );
       
          pOutMsg[msgLen++] = LO_UINT16( pTermEvt->reason );
          pOutMsg[msgLen++] = HI_UINT16( pTermEvt->reason );   
        }
        break;

      case L2CAP_OUT_OF_CREDIT_EVT:
      case L2CAP_PEER_CREDIT_THRESHOLD_EVT:
        {
          l2capCreditEvt_t *pCreditEvt = &(pPkt->cmd.creditEvt);
          
          pOutMsg[msgLen++] = LO_UINT16( pCreditEvt->CID );
          pOutMsg[msgLen++] = HI_UINT16( pCreditEvt->CID );
            
          pOutMsg[msgLen++] = LO_UINT16( pCreditEvt->peerCID );
          pOutMsg[msgLen++] = HI_UINT16( pCreditEvt->peerCID );
                    
          pOutMsg[msgLen++] = LO_UINT16( pCreditEvt->credits );
          pOutMsg[msgLen++] = HI_UINT16( pCreditEvt->credits );
        }
        break;
#endif // L2CAP_CO_CHANNELS
        
      default:
        // Unknown command
        break;
    }
  }

  *pMsgLen = msgLen;

  return ( pOutMsg );
}

/*********************************************************************
 * @fn      processDataL2CAP
 *
 * @brief   Process an incoming L2CAP Data message.
 *
 * @param   pPkt - packet to process
 * @param   pOutMsg - outgoing message to be built
 * @param   pMsgLen - length of outgoing message
 *
 * @return  outgoing message
 */
static uint8 *processDataL2CAP( l2capDataEvent_t *pPkt, uint8 *pOutMsg,
                                uint8 *pMsgLen, uint8 *pAllocated )
{
  uint8 *pBuf;
  uint16 msgLen = HCI_EXT_HDR_LEN + 2 + 2; // hdr + CID + packet length;
  uint8 status = pPkt->hdr.status;
  
  *pAllocated = FALSE;
  
  msgLen += pPkt->pkt.len;
  if ( msgLen > HCI_EXT_APP_OUT_BUF )
  {
    pBuf = osal_mem_alloc( msgLen );
    if ( pBuf )
    {
      *pAllocated = TRUE;
    }
    else
    {
      pBuf = pOutMsg;
      msgLen -= pPkt->pkt.len;
      
      status = bleMemAllocError;
    }
  }
  else
  {
    pBuf = pOutMsg;
  }
   
  // Build the message header first
  VOID buildHCIExtHeader( pBuf, (HCI_EXT_L2CAP_EVENT | HCI_EXT_L2CAP_DATA),
                          status, pPkt->connHandle );
  // Add CID
  pBuf[HCI_EXT_HDR_LEN] = LO_UINT16( pPkt->pkt.CID );
  pBuf[HCI_EXT_HDR_LEN+1] = HI_UINT16( pPkt->pkt.CID );
    
  // Add data length
  pBuf[HCI_EXT_HDR_LEN+2] = LO_UINT16( pPkt->pkt.len );
  pBuf[HCI_EXT_HDR_LEN+3] = HI_UINT16( pPkt->pkt.len );
    
  // Add payload
  if ( pPkt->pkt.pPayload != NULL )
  {
    if ( status == SUCCESS )
    {
      VOID osal_memcpy( &pBuf[HCI_EXT_HDR_LEN+4], pPkt->pkt.pPayload, pPkt->pkt.len );
    }
    
    // Received buffer is processed so it's safe to free it
    osal_bm_free( pPkt->pkt.pPayload );
  }
  
  *pMsgLen = msgLen;

  return ( pBuf );
}

/*********************************************************************
 * @fn      processEventsGATT
 *
 * @brief   Process an incoming GATT Event messages.
 *
 * @param   pPkt - packet to process
 * @param   pOutMsg - outgoing message to be built
 * @param   pMsgLen - length of outgoing message
 * @param   pAllocated - whether outgoing message is locally allocated
 *
 * @return  outgoing message
 */
static uint8 *processEventsGATT( gattMsgEvent_t *pPkt, uint8 *pOutMsg, 
                                 uint8 *pMsgLen, uint8 *pAllocated )
{
  uint8 msgLen = 0, attHdrLen = 0, hdrLen = HCI_EXT_HDR_LEN + 1; // hdr + event length
  uint8 *pBuf, *pPayload = NULL;
  uint8 status = pPkt->hdr.status;

  *pAllocated = FALSE;
  
  if ( status == SUCCESS )
  {   
    // Build the ATT header first
    switch ( pPkt->method )
    {
      case ATT_ERROR_RSP:
        attHdrLen = ATT_BuildErrorRsp( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.errorRsp) );
        break;

      case ATT_EXCHANGE_MTU_REQ:
      case ATT_MTU_UPDATED_EVENT:
        attHdrLen = ATT_BuildExchangeMTUReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.exchangeMTUReq) );
        break;

      case ATT_EXCHANGE_MTU_RSP:
        attHdrLen = ATT_BuildExchangeMTURsp( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.exchangeMTURsp) );
        break;

      case ATT_FIND_INFO_REQ:
        attHdrLen = ATT_BuildFindInfoReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.findInfoReq) );
        break;

      case ATT_FIND_INFO_RSP:
        {
          attFindInfoRsp_t *pRsp = &pPkt->msg.findInfoRsp;
          
          attHdrLen = ATT_FIND_INFO_RSP_FIXED_SIZE;
                    
          // Copy response header over
          msgLen = ATT_BuildFindInfoRsp( &pOutMsg[hdrLen], (uint8 *)pRsp ) - attHdrLen;
          pPayload = pRsp->pInfo;
        }
        break;

      case ATT_FIND_BY_TYPE_VALUE_REQ:
        {
          attFindByTypeValueReq_t *pReq = &pPkt->msg.findByTypeValueReq;
          
          attHdrLen = ATT_FIND_BY_TYPE_VALUE_REQ_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildFindByTypeValueReq( &pOutMsg[hdrLen], (uint8 *)pReq ) - attHdrLen;
          pPayload = pReq->pValue;
        }
        break;

      case ATT_FIND_BY_TYPE_VALUE_RSP:
        {
          attFindByTypeValueRsp_t *pRsp = &pPkt->msg.findByTypeValueRsp;
          
          msgLen = ATT_BuildFindByTypeValueRsp( &pOutMsg[hdrLen], (uint8 *)pRsp );
          pPayload = pRsp->pHandlesInfo;
        }
        break;

      case ATT_READ_BY_TYPE_REQ:
        attHdrLen = ATT_BuildReadByTypeReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.readByTypeReq) );
        break;

      case ATT_READ_BY_TYPE_RSP:
        {
          attReadByTypeRsp_t *pRsp = &pPkt->msg.readByTypeRsp;
          
          attHdrLen = ATT_READ_BY_TYPE_RSP_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildReadByTypeRsp( &pOutMsg[hdrLen], (uint8 *)pRsp ) - attHdrLen;
          pPayload = pRsp->pDataList;
        }
        break;

      case ATT_READ_REQ:
        attHdrLen = ATT_BuildReadReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.readReq) );
        break;

      case ATT_READ_RSP:
        {
          attReadRsp_t *pRsp = &pPkt->msg.readRsp;
          
          msgLen = ATT_BuildReadRsp( &pOutMsg[hdrLen], (uint8 *)pRsp );
          pPayload = pRsp->pValue;
        }
        break;

      case ATT_READ_BLOB_REQ:
        attHdrLen = ATT_BuildReadBlobReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.readBlobReq) );
        break;

      case ATT_READ_BLOB_RSP:
        {
          attReadBlobRsp_t *pRsp = &pPkt->msg.readBlobRsp;
          
          msgLen = ATT_BuildReadBlobRsp( &pOutMsg[hdrLen], (uint8 *)pRsp );
          pPayload = pRsp->pValue;
        }
        break;

      case ATT_READ_MULTI_REQ:
        {
          attReadMultiReq_t *pReq = &pPkt->msg.readMultiReq;
          
          msgLen = ATT_BuildReadMultiReq( &pOutMsg[hdrLen], (uint8 *)pReq );
          pPayload = pReq->pHandles;
        }
        break;

      case ATT_READ_MULTI_RSP:
        {
          attReadMultiRsp_t *pRsp = &pPkt->msg.readMultiRsp;
          
          msgLen = ATT_BuildReadMultiRsp( &pOutMsg[hdrLen], (uint8 *)pRsp );
          pPayload = pRsp->pValues;
        }
        break;

      case ATT_READ_BY_GRP_TYPE_REQ:
        attHdrLen = ATT_BuildReadByTypeReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.readByGrpTypeReq) );
        break;

      case ATT_READ_BY_GRP_TYPE_RSP:
        {
          attReadByGrpTypeRsp_t *pRsp = &pPkt->msg.readByGrpTypeRsp;
          
          attHdrLen = ATT_READ_BY_GRP_TYPE_RSP_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildReadByGrpTypeRsp( &pOutMsg[hdrLen], (uint8 *)pRsp ) - attHdrLen;
          pPayload = pRsp->pDataList;
        }
        break;

      case ATT_WRITE_REQ:
        {
          attWriteReq_t *pReq = &pPkt->msg.writeReq;
          
          pOutMsg[hdrLen] = pReq->sig;
          pOutMsg[hdrLen+1] = pReq->cmd;
        
          attHdrLen = ATT_WRITE_REQ_FIXED_SIZE;

          // Copy request header over
          msgLen = ATT_BuildWriteReq( &pOutMsg[hdrLen+2], (uint8 *)pReq ) - attHdrLen;
          pPayload = pReq->pValue;
          
          attHdrLen += 2; // sig + cmd
        }
        break;

      case ATT_PREPARE_WRITE_REQ:
        {
          attPrepareWriteReq_t *pReq = &pPkt->msg.prepareWriteReq;
          
          attHdrLen = ATT_PREPARE_WRITE_REQ_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildPrepareWriteReq( &pOutMsg[hdrLen], (uint8 *)pReq ) - attHdrLen;
          pPayload = pReq->pValue;
        }
        break;

      case ATT_PREPARE_WRITE_RSP:
        {
          attPrepareWriteRsp_t *pRsp = &pPkt->msg.prepareWriteRsp;
          
          attHdrLen = ATT_PREPARE_WRITE_RSP_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildPrepareWriteRsp( &pOutMsg[hdrLen], (uint8 *)pRsp ) - attHdrLen;
          pPayload = pRsp->pValue;
        }
        break;

      case ATT_EXECUTE_WRITE_REQ:
        attHdrLen = ATT_BuildExecuteWriteReq( &pOutMsg[hdrLen], (uint8 *)&(pPkt->msg.executeWriteReq) );
        break;

      case ATT_HANDLE_VALUE_IND:
      case ATT_HANDLE_VALUE_NOTI:
        {
          attHandleValueInd_t *pInd = &pPkt->msg.handleValueInd;
          
          attHdrLen = ATT_HANDLE_VALUE_IND_FIXED_SIZE;
          
          // Copy request header over
          msgLen = ATT_BuildHandleValueInd( &pOutMsg[hdrLen], (uint8 *)pInd ) - attHdrLen;
          pPayload = pInd->pValue;
        }
        break;
      
      case ATT_FLOW_CTRL_VIOLATED_EVENT:
        {
          attFlowCtrlViolatedEvt_t *pEvt = &pPkt->msg.flowCtrlEvt;
          
          pOutMsg[hdrLen]   = pEvt->opcode;
          pOutMsg[hdrLen+1] = pEvt->pendingOpcode;
          
          attHdrLen = 2;
        }
        break;
        
      default:
        // Unknown command
        break;
    }
  }
  
  // Event format: HCI Ext hdr + event len + ATT hdr + ATT PDU
  if ( ( hdrLen + attHdrLen + msgLen ) > HCI_EXT_APP_OUT_BUF )
  {
    pBuf = osal_mem_alloc( hdrLen + attHdrLen + msgLen );
    if ( pBuf )
    {
      *pAllocated = TRUE;
      
      // Copy the ATT header over
      if ( attHdrLen > 0 )
      {
        VOID osal_memcpy( &pBuf[hdrLen], &pOutMsg[hdrLen], attHdrLen );
      }
    }
    else
    {
      pBuf = pOutMsg;
      msgLen = 0;
      
      status = bleMemAllocError;
    }
  }
  else
  {
    pBuf = pOutMsg;
  }

  // Build the message PDU
  if ( pPayload != NULL )
  {
    if ( msgLen > 0 )
    {
      // Copy the message payload over
      VOID osal_memcpy( &pBuf[hdrLen+attHdrLen], pPayload, msgLen );
    }
    
    // Free the payload buffer
    osal_bm_free( pPayload );
  }
    
  // Build the message header
  VOID buildHCIExtHeader( pBuf, (HCI_EXT_ATT_EVENT | pPkt->method), status, pPkt->connHandle );

  // Add the event (PDU) length for GATT events for now!
  pBuf[HCI_EXT_HDR_LEN] = attHdrLen + msgLen;

  *pMsgLen = hdrLen + attHdrLen + msgLen;

  return ( pBuf );
}

#ifndef GATT_DB_OFF_CHIP
/*********************************************************************
 * @fn      processEventsGATTServ
 *
 * @brief   Process an incoming GATT Server Event messages.
 *
 * @param   pPkt - packet to process
 * @param   pMsg - outgoing message to be built
 * @param   pMsgLen - length of outgoing message
 *
 * @return  outgoing message
 */
static uint8 *processEventsGATTServ( gattEventHdr_t *pPkt, uint8 *pMsg, uint8 *pMsgLen )
{
  uint8 hdrLen = HCI_EXT_HDR_LEN + 1; // hdr + event length
  uint8 msgLen = 0;
  uint8 *pBuf = pMsg;

  if ( pPkt->hdr.status == SUCCESS )
  {
    // Build the message first
    switch ( pPkt->method )
    {
      case GATT_CLIENT_CHAR_CFG_UPDATED_EVENT:
        {
          gattClientCharCfgUpdatedEvent_t *pEvent = (gattClientCharCfgUpdatedEvent_t *)pPkt;

#if defined ( GAP_BOND_MGR )
          VOID GAPBondMgr_UpdateCharCfg( pEvent->connHandle, pEvent->attrHandle, pEvent->value );
#endif
          // Attribute handle
          pMsg[hdrLen]   = LO_UINT16( pEvent->attrHandle );
          pMsg[hdrLen+1] = HI_UINT16( pEvent->attrHandle );

          // Attribute value
          pMsg[hdrLen+2] = LO_UINT16( pEvent->value );
          pMsg[hdrLen+3] = HI_UINT16( pEvent->value );

          msgLen = 4;
        }
        break;

      default:
        // Unknown command
        break;
    }
  }

  // Build the message header
  VOID buildHCIExtHeader( pBuf, (HCI_EXT_GATT_EVENT | pPkt->method), pPkt->hdr.status, pPkt->connHandle );

  // Add the event (PDU) length for GATT events for now!
  pBuf[HCI_EXT_HDR_LEN] = msgLen;

  *pMsgLen = hdrLen + msgLen;

  return ( pBuf );
}
#endif // !GATT_DB_OFF_CHIP

#ifdef L2CAP_CO_CHANNELS
/*********************************************************************
 * @fn      buildCoChannelInfo
 *
 * @brief   Build Connection Oriented Channel info.
 *
 * @param   CID - local CID
 * @param   pInfo - pointer to CoC info
 * @param   pRspBuf - buffer to copy CoC info into
 *
 * @return  length of data copied
 */
static uint8 buildCoChannelInfo( uint16 CID, l2capCoCInfo_t *pInfo, uint8 *pRspBuf )
{
  uint8 msgLen = 0;
  
  pRspBuf[msgLen++] = LO_UINT16( pInfo->psm );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->psm );

  pRspBuf[msgLen++] = LO_UINT16( CID );
  pRspBuf[msgLen++] = HI_UINT16( CID );
          
  pRspBuf[msgLen++] = LO_UINT16( pInfo->mtu );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->mtu );
  
  pRspBuf[msgLen++] = LO_UINT16( pInfo->mps );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->mps );

  pRspBuf[msgLen++] = LO_UINT16( pInfo->credits );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->credits );
  
  pRspBuf[msgLen++] = LO_UINT16( pInfo->peerCID );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->peerCID );

  pRspBuf[msgLen++] = LO_UINT16( pInfo->peerMtu );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->peerMtu );
  
  pRspBuf[msgLen++] = LO_UINT16( pInfo->peerMps );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->peerMps );

  pRspBuf[msgLen++] = LO_UINT16( pInfo->peerCredits );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->peerCredits );
 
  pRspBuf[msgLen++] = LO_UINT16( pInfo->peerCreditThreshold );
  pRspBuf[msgLen++] = HI_UINT16( pInfo->peerCreditThreshold );
          
  return ( msgLen );
}

/*********************************************************************
  * @fn      l2capVerifySecCB
 *
 * @brief   Callback function to verify security when a Connection
 *          Request is received.
 *
 * @param   connHandle - connection handle request was received on
 * @param   id - identifier matches responses with requests
 * @param   pReq - received connection request
 *
 * @return  See L2CAP Connection Response: Result values
 */
static uint16 l2capVerifySecCB( uint16 connHandle, uint8 id, l2capConnectReq_t *pReq )
{
  uint8 msgLen = 0;

  // Build the message header first
  msgLen = buildHCIExtHeader( out_msg, (HCI_EXT_L2CAP_EVENT | L2CAP_CONNECT_REQ),
                              SUCCESS, connHandle );
  
  out_msg[msgLen++] = id;
  msgLen += L2CAP_BuildConnectReq( &out_msg[msgLen], (uint8 *)pReq );
  
  // Send out the Connection Request
  HCI_SendControllerToHostEvent( HCI_VE_EVENT_CODE,  msgLen, out_msg );
  
  return ( L2CAP_CONN_PENDING_SEC_VERIFY );
}
#endif // L2CAP_CO_CHANNELS

/*********************************************************************
 * @fn      buildHCIExtHeader
 *
 * @brief   Build an HCI Exension header.
 *
 * @param   pBuf - header to be built
 * @param   event - event id
 * @param   status - event status
 * @param   connHandle - connection handle
 *
 * @return  header length
 */
static uint8 buildHCIExtHeader( uint8 *pBuf, uint16 event, uint8 status, uint16 connHandle )
{
  pBuf[0] = LO_UINT16( event );
  pBuf[1] = HI_UINT16( event );
  pBuf[2] = status;
  pBuf[3] = LO_UINT16( connHandle );
  pBuf[4] = HI_UINT16( connHandle );

  return ( HCI_EXT_HDR_LEN );
}

/*********************************************************************
 * @fn      mapATT2BLEStatus
 *
 * @brief   Map ATT error code to BLE Generic status code.
 *
 * @param   status - ATT status
 *
 * @return  BLE Generic status
 */
static uint8  mapATT2BLEStatus( uint8 status )
{
  uint8 stat;

  switch ( status )
  {
    case ATT_ERR_INSUFFICIENT_AUTHEN:
      // Returned from Send routines
      stat = bleInsufficientAuthen;
      break;

    case ATT_ERR_INSUFFICIENT_ENCRYPT:
      // Returned from Send routines
      stat = bleInsufficientEncrypt;
      break;

    case ATT_ERR_INSUFFICIENT_KEY_SIZE:
      // Returned from Send routines
      stat = bleInsufficientKeySize;
      break;

    default:
      stat = status;
  }

  return ( stat );
}

/*********************************************************************
 * @fn      createMsgPayload
 *
 * @brief   Create payload buffer for OTA message to be sent.
 *
 * @param   pBuf - pointer to message data
 * @param   len - length of message data
 *
 * @return  pointer to payload. NULL if alloc fails.
 */
static uint8 *createMsgPayload( uint8 *pBuf, uint16 len )
{ 
  // Create payload buffer for OTA message to be sent
  uint8 *pPayload = L2CAP_bm_alloc( len + ATT_OPCODE_SIZE );
  if ( pPayload != NULL )
  {
    pPayload = osal_bm_adjust_header( pPayload, -ATT_OPCODE_SIZE );
    
    // Copy received data over
    VOID osal_memcpy( pPayload, pBuf, len );
    
    return ( pPayload );
  }
  
  return ( NULL );
}

#ifdef GATT_DB_OFF_CHIP
/*********************************************************************
 * @fn      addAttrRec
 *
 * @brief   Add attribute record to its service.
 *
 * @param   pServ - GATT service
 * @param   pUUID - attribute UUID
 * @param   len - length of UUID
 * @param   permissions - attribute permissions
 * @param   pTotalAttrs - total number of attributes
 * @param   pRspDataLen - response data length to be returned
 *
 * @return  status
 */
static uint8 addAttrRec( gattService_t *pServ, uint8 *pUUID, uint8 len,
                         uint8 permissions, uint16 *pTotalAttrs, uint8 *pRspDataLen )
{
  gattAttribute_t *pAttr = &(pServ->attrs[pServ->numAttrs]);
  uint8 stat = SUCCESS;

  // Set up attribute record
  pAttr->type.uuid = findUUIDRec( pUUID, len );
  if ( pAttr->type.uuid != NULL )
  {
    pAttr->type.len = len;
    pAttr->permissions = permissions;

    // Are all attributes added to the service yet?
    if ( ++pServ->numAttrs == *pTotalAttrs )
    {
      // Register the service with the GATT Server
      stat = GATT_RegisterService( pServ );
      if ( stat == SUCCESS )
      {
        *pRspDataLen = 4;

        // Service startHandle
        uint16 handle = pServ->attrs[0].handle;
        rspBuf[RSP_PAYLOAD_IDX] = LO_UINT16( handle );
        rspBuf[RSP_PAYLOAD_IDX+1] = HI_UINT16( handle );

        // Service endHandle
        handle = pServ->attrs[pServ->numAttrs-1].handle;
        rspBuf[RSP_PAYLOAD_IDX+2] = LO_UINT16( handle );
        rspBuf[RSP_PAYLOAD_IDX+3] = HI_UINT16( handle );

        // Service is registered with GATT; clear its info
        pServ->attrs = NULL;
        pServ->numAttrs = 0;
      }
      else
      {
        freeAttrRecs( pServ );
      }

      // We're done with this service
      *pTotalAttrs = 0;
    }
  }
  else
  {
    stat = INVALIDPARAMETER;
  }

  return ( stat );
}

/*********************************************************************
 * @fn      freeAttrRecs
 *
 * @brief   Free attribute records. Also, free UUIDs that were
 *          allocated dynamically.
 *
 * @param   pServ - GATT service
 *
 * @return  none
 */
static void freeAttrRecs( gattService_t *pServ )
{
  if ( pServ->attrs != NULL )
  {
    for ( uint8 i = 0; i < pServ->numAttrs; i++ )
    {
      gattAttrType_t *pType = &pServ->attrs[i].type;
      if ( pType->uuid != NULL )
      {
        if ( GATT_FindUUIDRec( (uint8 *)pType->uuid, pType->len ) == NULL )
        {
          // UUID was dynamically allocated; free it
          osal_mem_free( (uint8 *)pType->uuid );
        }
      }
    }

    osal_mem_free( pServ->attrs );

    pServ->attrs = NULL;
    pServ->numAttrs = 0;
  }
}

/*********************************************************************
 * @fn      findUUIDRec
 *
 * @brief   Find UUID record. If the record is not found, create one
 *          dynamically.
 *
 * @param   pUUID - UUID to look for
 * @param   len - length of UUID
 *
 * @return  UUID record
 */
static const uint8 *findUUIDRec( uint8 *pUUID, uint8 len )
{
  const uint8 *pUuid = GATT_FindUUIDRec( pUUID, len );
  if ( pUuid == NULL )
  {
    // UUID not found; allocate space for it
    pUuid = osal_mem_alloc( len );
    if ( pUuid != NULL )
    {
      VOID osal_memcpy( (uint8 *)pUuid, pUUID, len );
    }
  }

  return ( pUuid );
}
#endif // GATT_DB_OFF_CHIP

/*********************************************************************
*********************************************************************/
