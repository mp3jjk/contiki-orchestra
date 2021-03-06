#ifndef __PROJECT_CONF_H__
#define __PROJECT_CONF_H__

#define TSCH_ENABLED 1	

/* Set to run orchestra */
#define WITH_ORCHESTRA 1
#define ORCHESTRA_TRAFFIC_ADAPTIVE_MODE	0 // Traffic adaptive mode is enabled
#define OUR_STATIC_ROUTING 0 // Make routing static from stage 2

#if WITH_ORCHESTRA
	#define ORCHESTRA_CONF_UNICAST_PERIOD 13 //If this is inside #if WITH_ORACHESTRA, error occurres 
	#define TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL 0 // For 6TiSCH minimal configuration without orchestra
	#define ORCHESTRA_CONF_COMMON_SHARED_PERIOD 1 * ORCHESTRA_CONF_UNICAST_PERIOD
	#define ORCHESTRA_CONF_EBSF_PERIOD 20 * ORCHESTRA_CONF_UNICAST_PERIOD
#else
	#define TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL 1
	#define TSCH_SCHEDULE_CONF_DEFAULT_LENGTH 13
#endif

/* Orchestra Options */
#define TSCH_CONF_JOIN_HOPPING_SEQUENCE TSCH_HOPPING_SEQUENCE_1_1 // Do not hopping in the joining process
#define TSCH_CONF_DEFAULT_HOPPING_SEQUENCE TSCH_HOPPING_SEQUENCE_4_4
//#define TSCH_CONF_DEFAULT_HOPPING_SEQUENCE TSCH_HOPPING_SEQUENCE_1_1
#define RPL_MRHOF_CONF_SQUARED_ETX	1 // For reliable link choice, use squared ETX

#define TSCH_CONF_MAC_MAX_FRAME_RETRIES 3 // Maximum number of retransmission in TSCH

#define TRAFFIC_PATTERN 1	// 0: Periodic, 1: poisson
#if TRAFFIC_PATTERN == 0 // If periodic
#define PERIOD 20
#else	// If event driven (assume poisson)
#define INTENSITY 20 // lambda
#endif

#define HETEROGENEOUS_TRAFFIC 0

#define ORCHESTRA_CONF_UNICAST_SENDER_BASED	1

#if ZOUL_MOTE == 1 || IOTLAB_MOTE == 1
#define EXPERIMENT		1
#else
#define EXPERIMENT		0
#endif

#if EXPERIMENT == 1
#define NUM_NODES	4
uint8_t topology_parent[NUM_NODES];
#define TSCH_CONF_DEFAULT_TIMESLOT_LENGTH 15000
#define CC1200_CONF_USE_GPIO2 0
#define NETSTACK_CONF_RADIO cc2538_rf_driver
#define CC2538_RF_CONF_TX_POWER	0xFF // 0xFF 7dBm ~
//#define TSCH_LOG_CONF_LEVEL	2
#else
#define TSCH_CONF_DEFAULT_TIMESLOT_LENGTH 10000
#endif

#define RPL_CONF_WITH_PROBING 0
#define RPL_CONF_WITH_MC RPL_DAG_MC_ETX


/* First parameterization */
#define HARD_CODED_n_PBS	0 // If you want to use hard coded n-PBS value, define it except 0

uint8_t n_PBS; // n denotes the number of TX assigned to a slot, e.g., 1-PBS = PBS, 2-PBS = 2TX per slot, Inf(-1 in the code)-PBS = RBS

uint8_t received_n_PBS; // For practical scenario, received_n_PBS from EB Not implemented yet

uint8_t myaddr;

/* Second parameterization */
#define OUR_ADAPTIVE_AVOID_SLOT0 1
#define HARD_CODED_n_SF		0 // Hard coded nSF
uint8_t n_SF; // among n TXs in a slot, the number of Slotframes divided into
uint8_t my_SF; // The Slotframe that a node belongs to
uint8_t flag_dao_output;
uint8_t state_traffic_adaptive_TX; // Traffic adaptive mode as a TX is started when receive num_sibling
uint8_t state_traffic_adaptive_RX; // Traffic adaptive mode as a RX is started when transmit my_child_numbersss

#define TRAFFIC_INTENSITY_WINDOW_SIZE	512
uint32_t accumulated_traffic_intensity;
//uint32_t traffic_intensity[TRAFFIC_INTENSITY_WINDOW_SIZE];
double averaged_traffic_intensity;

#define NUM_TRAFFIC_INTENSITY	5
double traffic_intensity_list[NUM_TRAFFIC_INTENSITY];
double measured_traffic_intensity;

#define RELIABILITY_CONSTRAINT 95 // delta in the paper, percent

#define TSCH_LENGTH_PHASE 500
#define TSCH_LENGTH_STAGE 30
uint32_t slotframe_number;
uint8_t current_stage_number;
uint16_t current_phase_number;
uint8_t is_update_phase;

uint32_t tx_ASN;
uint32_t recv_ASN;

#define MAX_NUMBER_CHILD	30
int	TX_slot_assignment;	// Using 32bits, represent slot assignment from LSB (slot 0) to MSB (slot 31)
int recv_TX_slot_assignment; // Received TX slot assignment from the parent
uint8_t TX_slot_changed; // Store slot assignment to check change of assignment
uint8_t recv_TX_slot_changed; // To check change of received assignment
uint8_t list_ordered_child[MAX_NUMBER_CHILD]; // List for store child ID's with ordering
uint8_t recv_list_ordered_child[MAX_NUMBER_CHILD]; // Received list of child nodes
uint8_t recv_n_SF; // Received n_SF
uint8_t child_changed; // Notifying the change of child list
uint8_t current_TX_slot; // To store current TX slot
uint8_t prev_TX_slot; // To store previous TX slot


/* Used for ORCHESTRA_TRAFFIC_ADAPTIVE_MODE */
#define RPL_CALLBACK_REMOVE_LINK tsch_rpl_remove_link_by_slot
#define RPL_CALLBACK_ADD_LINK tsch_rpl_add_link_by_slot

/* To enable transmit DIO for some cases */
#define RPL_CONF_DIO_REDUNDANCY		20

/* Set to enable TSCH security */
#ifndef WITH_SECURITY
#define WITH_SECURITY 0
#endif /* WITH_SECURITY */

/*******************************************************/
/********* Enable RPL non-storing mode *****************/
/*******************************************************/

/* Modified for Orchestra Traffic Adaptive */
#undef UIP_CONF_MAX_ROUTES
#define UIP_CONF_MAX_ROUTES 30 /* No need for routes */
#undef RPL_CONF_MOP
#define RPL_CONF_MOP RPL_MOP_STORING_NO_MULTICAST /* Mode of operation*/
#undef ORCHESTRA_CONF_RULES
#if ORCHESTRA_TRAFFIC_ADAPTIVE_MODE	
#if ORCHESTRA_CONF_EBSF_PERIOD > 0
#define ORCHESTRA_CONF_RULES { &eb_per_time_source, &unicast_per_neighbor_rpl_storing_traffic_adaptive, &default_common } /* Orchestra in non-storing */
#else
#define ORCHESTRA_CONF_RULES { &default_common, &unicast_per_neighbor_rpl_storing_traffic_adaptive } /* Orchestra in non-storing */
#endif
#else
#if ORCHESTRA_CONF_EBSF_PERIOD > 0
#define ORCHESTRA_CONF_RULES { &eb_per_time_source, &unicast_per_neighbor_rpl_storing, &default_common } /* Orchestra in non-storing */
#else
#define ORCHESTRA_CONF_RULES { &default_common, &unicast_per_neighbor_rpl_storing} /* Orchestra in non-storing */
#endif
#endif

#define	RPL_CONF_OF_OCP RPL_OCP_OF0
#define RPL_CONF_SUPPORTED_OFS {&rpl_of0, &rpl_mrhof}

/*******************************************************/
/********************* Enable TSCH *********************/
/*******************************************************/

#if TSCH_ENABLED
/* Netstack layers */
#undef NETSTACK_CONF_MAC
#define NETSTACK_CONF_MAC     tschmac_driver
#undef NETSTACK_CONF_RDC
#define NETSTACK_CONF_RDC     nordc_driver
#undef NETSTACK_CONF_FRAMER
#define NETSTACK_CONF_FRAMER  framer_802154
#elif CONTIKIMAC_ENABLED
#undef NETSTACK_CONF_MAC
#define NETSTACK_CONF_MAC     csma_driver
#undef NETSTACK_CONF_RDC
#define NETSTACK_CONF_RDC     contikimac_driver
#undef NETSTACK_CONF_FRAMER
#define NETSTACK_CONF_FRAMER  framer_802154
//#define	NETSTACK_CONF_WITH_IPV6	1
#endif


/* IEEE802.15.4 frame version */
#undef FRAME802154_CONF_VERSION
#define FRAME802154_CONF_VERSION FRAME802154_IEEE802154E_2012

/* TSCH and RPL callbacks */
#define RPL_CALLBACK_PARENT_SWITCH tsch_rpl_callback_parent_switch
#define RPL_CALLBACK_NEW_DIO_INTERVAL tsch_rpl_callback_new_dio_interval
#define TSCH_CALLBACK_JOINING_NETWORK tsch_rpl_callback_joining_network
#define TSCH_CALLBACK_LEAVING_NETWORK tsch_rpl_callback_leaving_network

/* Needed for CC2538 platforms only */
/* For TSCH we have to use the more accurate crystal oscillator
 * by default the RC oscillator is activated */
#undef SYS_CTRL_CONF_OSC32K_USE_XTAL
#define SYS_CTRL_CONF_OSC32K_USE_XTAL 1

/* Needed for cc2420 platforms only */
/* Disable DCO calibration (uses timerB) */
#undef DCOSYNCH_CONF_ENABLED
#define DCOSYNCH_CONF_ENABLED 0
/* Enable SFD timestamps (uses timerB) */
#undef CC2420_CONF_SFD_TIMESTAMPS
#define CC2420_CONF_SFD_TIMESTAMPS 1

/*******************************************************/
/******************* Configure TSCH ********************/
/*******************************************************/

/* TSCH logging. 0: disabled. 1: basic log. 2: with delayed
 * log messages from interrupt */
#undef TSCH_LOG_CONF_LEVEL
#define TSCH_LOG_CONF_LEVEL 0

/* IEEE802.15.4 PANID */
#undef IEEE802154_CONF_PANID
#define IEEE802154_CONF_PANID 0xabcd

/* Do not start TSCH at init, wait for NETSTACK_MAC.on() */
#undef TSCH_CONF_AUTOSTART
#define TSCH_CONF_AUTOSTART 0

/* 6TiSCH minimal schedule length.
 * Larger values result in less frequent active slots: reduces capacity and saves energy. */

#if WITH_SECURITY

/* Enable security */
#undef LLSEC802154_CONF_ENABLED
#define LLSEC802154_CONF_ENABLED 1
/* TSCH uses explicit keys to identify k1 and k2 */
#undef LLSEC802154_CONF_USES_EXPLICIT_KEYS
#define LLSEC802154_CONF_USES_EXPLICIT_KEYS 1
/* TSCH uses the ASN rather than frame counter to construct the Nonce */
#undef LLSEC802154_CONF_USES_FRAME_COUNTER
#define LLSEC802154_CONF_USES_FRAME_COUNTER 0

#endif /* WITH_SECURITY */

#if WITH_ORCHESTRA

/* See apps/orchestra/README.md for more Orchestra configuration options */
//#define TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL 0 /* No 6TiSCH minimal schedule */
#define TSCH_CONF_WITH_LINK_SELECTOR 1 /* Orchestra requires per-packet link selection */
/* Orchestra callbacks */
#define TSCH_CALLBACK_NEW_TIME_SOURCE orchestra_callback_new_time_source
#define TSCH_CALLBACK_PACKET_READY orchestra_callback_packet_ready
#define NETSTACK_CONF_ROUTING_NEIGHBOR_ADDED_CALLBACK orchestra_callback_child_added
#define NETSTACK_CONF_ROUTING_NEIGHBOR_REMOVED_CALLBACK orchestra_callback_child_removed

#endif /* WITH_ORCHESTRA */

/*******************************************************/
/************* Other system configuration **************/
/*******************************************************/

#if CONTIKI_TARGET_Z1
/* Save some space to fit the limited RAM of the z1 */
#undef UIP_CONF_TCP
#define UIP_CONF_TCP 0
#undef QUEUEBUF_CONF_NUM
#define QUEUEBUF_CONF_NUM 3
#undef RPL_NS_CONF_LINK_NUM
#define RPL_NS_CONF_LINK_NUM  8
#undef NBR_TABLE_CONF_MAX_NEIGHBORS
#define NBR_TABLE_CONF_MAX_NEIGHBORS 8
#undef UIP_CONF_ND6_SEND_NS
#define UIP_CONF_ND6_SEND_NS 0
#undef SICSLOWPAN_CONF_FRAG
#define SICSLOWPAN_CONF_FRAG 0

#if WITH_SECURITY
/* Note: on sky or z1 in cooja, crypto operations are done in S/W and
 * cannot be accommodated in normal slots. Use 65ms slots instead, and
 * a very short 6TiSCH minimal schedule length */
#undef TSCH_CONF_DEFAULT_TIMESLOT_LENGTH
#define TSCH_CONF_DEFAULT_TIMESLOT_LENGTH 65000
#undef TSCH_SCHEDULE_CONF_DEFAULT_LENGTH
#define TSCH_SCHEDULE_CONF_DEFAULT_LENGTH 2
/* Reduce log level to make space for security on z1 */
#undef TSCH_LOG_CONF_LEVEL
#define TSCH_LOG_CONF_LEVEL 0
#endif /* WITH_SECURITY */

#endif /* CONTIKI_TARGET_Z1 */

#if CONTIKI_TARGET_CC2538DK || CONTIKI_TARGET_ZOUL ||   CONTIKI_TARGET_OPENMOTE_CC2538
#define TSCH_CONF_HW_FRAME_FILTERING    0
#endif /* CONTIKI_TARGET_CC2538DK || CONTIKI_TARGET_ZOUL        || CONTIKI_TARGET_OPENMOTE_CC2538 */

#if CONTIKI_TARGET_COOJA
#define COOJA_CONF_SIMULATE_TURNAROUND 0
#endif /* CONTIKI_TARGET_COOJA */

#endif /* __PROJECT_CONF_H__ */
