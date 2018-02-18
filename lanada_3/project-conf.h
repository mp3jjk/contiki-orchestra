#ifndef __PROJECT_CONF_H__
#define __PROJECT_CONF_H__

#define TSCH_ENABLED	1

/* Set to run orchestra */
#ifndef WITH_ORCHESTRA
#define WITH_ORCHESTRA 1 /* jk */
#endif /* WITH_ORCHESTRA */

#if WITH_ORACHESTRA == 0
#define TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL 0 // For 6TiSCH minimal configuration without orchestra /* jk */
#endif

/* Orchestra Options */
#define TSCH_CONF_JOIN_HOPPING_SEQUENCE TSCH_HOPPING_SEQUENCE_1_1 // Do not hopping in the joining process
#define TSCH_CONF_DEFAULT_HOPPING_SEQUENCE TSCH_HOPPING_SEQUENCE_4_4
#define RPL_MRHOF_CONF_SQUARED_ETX	1 // For reliable link choice, use squared ETX
#define ORCHESTRA_TRAFFIC_ADAPTIVE_MODE	1 // Traffic adaptive mode is enabled /* jk */

#define TRAFFIC_PATTERN 0	// 0: Periodic, 1: Event-driven /* jk */
#if TRAFFIC_PATTERN == 0 // If periodic
#define PERIOD	30 /* jk */
#else	// If event driven (assume poisson)
#define INTENSITY 0 // lambda /* jk */
#endif

#define ORCHESTRA_CONF_UNICAST_SENDER_BASED	1 /* jk */

#define HARD_CODED_n_SBS	4 // If you want to use hard coded n-SBS value, define it except 0 /* jk */

uint8_t n_SBS; // n denotes the number of TX assigned to a slot, e.g., 1-SBS = SBS, 2-SBS = 2TX per slot, Inf(-1 in the code)-SBS = RBS

uint8_t received_n_SBS; // For practical scenario, received_n_SBS from EB Not implemented yet

#define ORCHESTRA_RANDOMIZED_TX_SLOT	0 // Mode for randomized TX slot assignment 1 otherwise deterministic mode

uint8_t state_traffic_adaptive_TX; // Traffic adaptive mode as a TX is started when receive num_sibling
uint8_t state_traffic_adaptive_RX; // Traffic adaptive mode as a RX is started when transmit my_child_numbersss

#if ORCHESTRA_RANDOMIZED_TX_SLOT	  // Randomized mode

#else 								// Deterministic TX slot assignment
#define MAX_NUMBER_CHILD	10
	int	TX_slot_assignment;	// Using 32bits, represent slot assignment from LSB (slot 0) to MSB (slot 31)
	int recv_TX_slot_assignment; // Received TX slot assignment from the parent
	uint8_t TX_slot_changed; // Store slot assignment to check change of assignment
	uint8_t recv_TX_slot_changed; // To check change of received assignment
	uint8_t list_ordered_child[MAX_NUMBER_CHILD]; // List for store child ID's with ordering
	uint8_t child_changed; // Notifying the change of child list
	uint8_t current_TX_slot; // To store current TX slot
	uint8_t prev_TX_slot; // To store previous TX slot
#endif

/* Used for ORCHESTRA_TRAFFIC_ADAPTIVE_MODE */
#define RPL_CALLBACK_REMOVE_LINK tsch_rpl_remove_link_by_slot
#define RPL_CALLBACK_ADD_LINK tsch_rpl_add_link_by_slot

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
#define ORCHESTRA_CONF_RULES { &eb_per_time_source, &unicast_per_neighbor_rpl_storing_traffic_adaptive, &default_common } /* Orchestra in non-storing */
#else
#define ORCHESTRA_CONF_RULES { &eb_per_time_source, &unicast_per_neighbor_rpl_storing, &default_common } /* Orchestra in non-storing */
#endif

#define	RPL_CONF_OF_OCP RPL_OCP_MRHOF /* jk */
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
#undef TSCH_SCHEDULE_CONF_DEFAULT_LENGTH
#define TSCH_SCHEDULE_CONF_DEFAULT_LENGTH 3

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
#define TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL 0 /* No 6TiSCH minimal schedule */
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
