/*
 * Copyright (c) 2015, SICS Swedish ICT.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Institute nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
/**
 * \file
 *         A RPL+TSCH node able to act as either a simple node (6ln),
 *         DAG Root (6dr) or DAG Root with security (6dr-sec)
 *         Press use button at startup to configure.
 *
 * \author Simon Duquennoy <simonduq@sics.se>
 *
 *  Modified by Jinhwan Jung <jhjung@lanada.kaist.ac.kr>
 *  Traffic Adaptive Orchestra with generalized slot type: n-PBS
 *
 */

#include "contiki.h"
#include "node-id.h"
#include "sys/process.h"
#include "net/rpl/rpl.h"
#include "net/ipv6/uip-ds6-route.h"
#include "net/mac/tsch/tsch.h"
#include "net/rpl/rpl-private.h"
#if WITH_ORCHESTRA
#include "orchestra.h"
#endif /* WITH_ORCHESTRA */


#define DEBUG DEBUG_PRINT
#include "net/ip/uip-debug.h"

#define CONFIG_VIA_BUTTON PLATFORM_HAS_BUTTON
#if CONFIG_VIA_BUTTON
#include "button-sensor.h"
#endif /* CONFIG_VIA_BUTTON */

#include "sys/ctimer.h"
#include "net/ip/uip.h"
#include "net/ipv6/uip-ds6.h"
#include "net/ip/uip-udp-packet.h"
#include <stdio.h>

/* Application Layer Connection */
#define UDP_CLIENT_PORT 8765
#define UDP_SERVER_PORT 5678

/* For random traffic generation */
#include "lib/random.h"
#include <math.h>
#include "core/sys/log_energy.h"

/* Initial waiting for scheduling */
#define INIT_WAIT_TIME 60

struct uip_udp_conn *app_conn;
static uip_ipaddr_t server_ipaddr;
/*---------------------------------------------------------------------------*/
PROCESS(node_process, "RPL Node");
#if CONFIG_VIA_BUTTON
AUTOSTART_PROCESSES(&node_process, &sensors_process);
#else /* CONFIG_VIA_BUTTON */
AUTOSTART_PROCESSES(&node_process);
#endif /* CONFIG_VIA_BUTTON */

/*---------------------------------------------------------------------------*/
static int seq_id;
static int reply;
static uint8_t myaddr;

static void
tcpip_handler(void)
{
  char *str;

  if(uip_newdata()) {
    str = uip_appdata;
    str[uip_datalen()] = '\0';
    reply++;
    printf("DATA recv '%s' ASN: %d\n", str, recv_ASN);
  }
}
/*---------------------------------------------------------------------------*/
static void
send_packet(void *ptr)
{
	char buf[50];
	//static char radio_temp = 'M';
	static int parent_temp = 0;
//	printf("current num_sibling %d\n",num_sibling);
	seq_id++;

#if PS_COUNT && 0
  data_message_count = seq_id-1;
	int total_count1, total_count2;
	total_count1 = dio_count + dao_count + dis_count + dio_ack_count;
	total_count2 = dao_ack_count + dao_fwd_count + dao_ack_fwd_count + LSA_count;
	if (data_message_count%PS == 0) {
		LOG_MESSAGE("[PS] Periodic status review:\n");
		LOG_MESSAGE("[PS] Control: %d, Data: %d, Data fwd: %d\n",
				tcp_output_count-data_message_count-data_fwd_count, data_message_count, data_fwd_count);
		LOG_MESSAGE("[PS] ICMP: %d, TCP_OUTPUT: %d\n",
				icmp_count, tcp_output_count);
		LOG_MESSAGE("[PS] DIO:%d, DAO: %d, DIS: %d, DIO_ACK: %d, Total: %d\n",
				dio_count, dao_count, dis_count, dio_ack_count, total_count1);
		LOG_MESSAGE("[PS] DAO_ACK:%d, DAO_FWD: %d, DAO_ACK_FWD: %d, LSA: %d, Total: %d\n",
				dao_ack_count, dao_fwd_count,dao_ack_fwd_count, LSA_count, total_count2 );
		LOG_MESSAGE("[PS] CSMA_Transmission: %d, CXMAC_Transmission: %d, CXMAC_Collision: %d\n",
				csma_transmission_count, rdc_transmission_count, rdc_collision_count);
		LOG_MESSAGE("[PS] CSMA_Drop: %d, CXMAC_Retransmission: %d\n",
				csma_drop_count, rdc_retransmission_count - csma_drop_count);
		LOG_MESSAGE("[PS] Remaining energy: %d\n", (int) get_residual_energy());
		rpl_parent_t *p = nbr_table_head(rpl_parents);
		if (p != NULL) {
			rpl_parent_t *preferred_parent = p->dag->preferred_parent;
			if (preferred_parent != NULL) {
				uip_ds6_nbr_t *nbr = rpl_get_nbr(preferred_parent);
				LOG_MESSAGE("[PS] My parent is : %c %d\n", nbr->ipaddr.u8[8]>128 ? 'L':'S', nbr->ipaddr.u8[15]) ;
			}
		}
	}

	if (lifetime > 0) {
		if (get_residual_energy() == 0) {
			LOG_MESSAGE("[LT] Control: %d, Data: %d, Data fwd: %d\n",
					tcp_output_count-data_message_count-data_fwd_count, data_message_count, data_fwd_count);
			LOG_MESSAGE("[LT] ICMP: %d, TCP_OUTPUT: %d\n",
					icmp_count, tcp_output_count);
			LOG_MESSAGE("[LT] DIO:%d, DAO: %d, DIS: %d, DIO_ACK: %d, Total: %d\n",
					dio_count, dao_count, dis_count, dio_ack_count, total_count1);
			LOG_MESSAGE("[LT] DAO_ACK:%d, DAO_FWD: %d, DAO_ACK_FWD: %d, LSA: %d, Total: %d\n",
					dao_ack_count, dao_fwd_count,dao_ack_fwd_count, LSA_count, total_count2 );
			LOG_MESSAGE("[LT] CSMA_Transmission: %d, CXMAC_Transmission: %d, CXMAC_Collision: %d\n",
					csma_transmission_count, rdc_transmission_count, rdc_collision_count);
			LOG_MESSAGE("Lifetime of this node ended here!!!\n");

		 	NETSTACK_MAC.off(0);
			dead = 1;
		}
	}
	lifetime = get_residual_energy();
#endif /* PS_COUNT */

	//	PRINTF("app: current E: %d\n",get_current_energy());
		PRINTF("app: DATA id:%04d from:%03d ASN:%d\n",
	         seq_id,myaddr, tx_ASN);
	//  printf("send_packet!\n");
	#if ZOUL_MOTE
		rpl_parent_t *p2 = nbr_table_head(rpl_parents);

		if (p2 != NULL) {
			rpl_parent_t *preferred_parent2 = p2->dag->preferred_parent;
			if (preferred_parent2 != NULL) {
				uip_ds6_nbr_t *nbr2 = rpl_get_nbr(preferred_parent2);
				parent_temp = nbr2->ipaddr.u8[15];
			}
		} else {
			parent_temp = 0;
		}
	  sprintf(buf,"DATA id:%04d from:%03dX E:%d P:%d ASN:%d",seq_id,myaddr,(int)get_current_energy(),\
				 parent_temp, tx_ASN);
	  uip_udp_packet_sendto(client_conn, buf, 50,
	                        &server_ipaddr, UIP_HTONS(UDP_SERVER_PORT));
	#else

		sprintf(buf,"DATA id:%04d from:%03d ASN:%d",seq_id,myaddr,tx_ASN);

		uip_udp_packet_sendto(app_conn, buf, 50,
	                        &server_ipaddr, UIP_HTONS(UDP_SERVER_PORT));
	#endif

}

/*---------------------------------------------------------------------------*/
static void
print_network_status(void)
{
  int i;
  uint8_t state;
  uip_ds6_defrt_t *default_route;
#if RPL_WITH_STORING
  uip_ds6_route_t *route;
#endif /* RPL_WITH_STORING */
#if RPL_WITH_NON_STORING
  rpl_ns_node_t *link;
#endif /* RPL_WITH_NON_STORING */

  PRINTF("--- Network status ---\n");

  /* Our IPv6 addresses */
  PRINTF("- Server IPv6 addresses:\n");
  for(i = 0; i < UIP_DS6_ADDR_NB; i++) {
    state = uip_ds6_if.addr_list[i].state;
    if(uip_ds6_if.addr_list[i].isused &&
       (state == ADDR_TENTATIVE || state == ADDR_PREFERRED)) {
      PRINTF("-- ");
      PRINT6ADDR(&uip_ds6_if.addr_list[i].ipaddr);
      PRINTF("\n");
    }
  }

  /* Our default route */
  PRINTF("- Default route:\n");
  default_route = uip_ds6_defrt_lookup(uip_ds6_defrt_choose());
  if(default_route != NULL) {
    PRINTF("-- ");
    PRINT6ADDR(&default_route->ipaddr);
    PRINTF(" (lifetime: %lu seconds)\n", (unsigned long)default_route->lifetime.interval);
  } else {
    PRINTF("-- None\n");
  }

#if RPL_WITH_STORING
  /* Our routing entries */
  PRINTF("- Routing entries (%u in total):\n", uip_ds6_route_num_routes());
  route = uip_ds6_route_head();
  while(route != NULL) {
    PRINTF("-- ");
    PRINT6ADDR(&route->ipaddr);
    PRINTF(" via ");
    PRINT6ADDR(uip_ds6_route_nexthop(route));
    PRINTF(" (lifetime: %lu seconds)\n", (unsigned long)route->state.lifetime);
    route = uip_ds6_route_next(route);
  }
#endif

#if RPL_WITH_NON_STORING
  /* Our routing links */
  PRINTF("- Routing links (%u in total):\n", rpl_ns_num_nodes());
  link = rpl_ns_node_head();
  while(link != NULL) {
    uip_ipaddr_t child_ipaddr;
    uip_ipaddr_t parent_ipaddr;
    rpl_ns_get_node_global_addr(&child_ipaddr, link);
    rpl_ns_get_node_global_addr(&parent_ipaddr, link->parent);
    PRINTF("-- ");
    PRINT6ADDR(&child_ipaddr);
    if(link->parent == NULL) {
      memset(&parent_ipaddr, 0, sizeof(parent_ipaddr));
      PRINTF(" --- DODAG root ");
    } else {
      PRINTF(" to ");
      PRINT6ADDR(&parent_ipaddr);
    }
    PRINTF(" (lifetime: %lu seconds)\n", (unsigned long)link->lifetime);
    link = rpl_ns_node_next(link);
  }
#endif

  PRINTF("----------------------\n");
}
/*---------------------------------------------------------------------------*/
static void
print_init_status(void) {
#if TRAFFIC_PATTERN == 0
	printf("INIT STATUS, TSCH: %d, ORCHESTRA: %d, ADAPTIVE: %d, RBS_SBS: %d, n_PBS: %d, n_SF: %d, TRAFFIC: %d, PERIOD: %d, CHECK: %d\n",TSCH_ENABLED, WITH_ORCHESTRA, ORCHESTRA_TRAFFIC_ADAPTIVE_MODE, ORCHESTRA_CONF_UNICAST_SENDER_BASED,
			HARD_CODED_n_PBS, HARD_CODED_n_SF, TRAFFIC_PATTERN, PERIOD, NETSTACK_CONF_RDC_CHANNEL_CHECK_RATE);
#elif TRAFFIC_PATTERN == 1
	printf("INIT STATUS, TSCH: %d, ORCHESTRA: %d, ADAPTIVE: %d, RBS_SBS: %d, n_PBS: %d, n_SF: %d, TRAFFIC: %d, RATE: %d, CHECK: %d\n",TSCH_ENABLED, WITH_ORCHESTRA, ORCHESTRA_TRAFFIC_ADAPTIVE_MODE, ORCHESTRA_CONF_UNICAST_SENDER_BASED,
			HARD_CODED_n_PBS, HARD_CODED_n_SF, TRAFFIC_PATTERN, INTENSITY, NETSTACK_CONF_RDC_CHANNEL_CHECK_RATE);
#endif
#if WITH_ORCHESTRA == 1
	printf("UNI_PERIOD: %d\n",ORCHESTRA_CONF_UNICAST_PERIOD);
#elif TSCH_SCHEDULE_CONF_WITH_6TISCH_MINIMAL == 1
	printf("MINI_PERIOD: %d\n",TSCH_SCHEDULE_CONF_DEFAULT_LENGTH);
#endif
}
/*---------------------------------------------------------------------------*/
static void
net_init(uip_ipaddr_t *br_prefix)
{
  uip_ipaddr_t global_ipaddr;
  if(br_prefix) { /* We are RPL root. Will be set automatically
                     as TSCH pan coordinator via the tsch-rpl module */
//    memcpy(&global_ipaddr, br_prefix, 16);
	uip_ip6addr(&global_ipaddr,br_prefix, 0, 0, 0, 0, 0x00ff, 0xfe00, 1);
    uip_ds6_set_addr_iid(&global_ipaddr, &uip_lladdr);
//    uip_ds6_addr_add(&global_ipaddr, 0, ADDR_AUTOCONF);
    uip_ds6_addr_add(&global_ipaddr, 0, ADDR_MANUAL);
    rpl_set_root(RPL_DEFAULT_INSTANCE, &global_ipaddr);
    rpl_set_prefix(rpl_get_any_dag(), br_prefix, 64);
    rpl_repair_root(RPL_DEFAULT_INSTANCE);
    app_conn = udp_new(NULL, UIP_HTONS(UDP_CLIENT_PORT), NULL);
    if(app_conn == NULL) {
    	PRINTF("No UDP connection available exit!\n");
    	return;
    }
    udp_bind(app_conn, UIP_HTONS(UDP_SERVER_PORT));
  }
  else {
	  app_conn = udp_new(NULL, UIP_HTONS(UDP_SERVER_PORT), NULL);
	  if(app_conn == NULL) {
		  PRINTF("No UDP connection available exit!\n");
		  return;
	  }
	  udp_bind(app_conn, UIP_HTONS(UDP_CLIENT_PORT));
  }


  NETSTACK_MAC.on();
}

/* Polling application process
 * after joining TSCH network
 */
void application_polling(void *ptr) {
	process_poll(&node_process);
}

/*---------------------------------------------------------------------------*/
PROCESS_THREAD(node_process, ev, data)
{
  static struct etimer et;
  static struct etimer gen; // Packet generation timer
  static struct ctimer backoff;
  static clock_time_t packet_interval;
  static double prob_packet_gen;
#if TRAFFIC_PATTERN == 1
  static float random_num;
#endif

  PROCESS_BEGIN();
  print_init_status();
  state_traffic_adaptive_TX = 0; // Init state as a TX
  state_traffic_adaptive_RX = 0; // Init state as a RX
  n_PBS = 1; // In the init state, operate in n_PBS = 1
  n_SF = 1;
  my_SF = 0;
  /* 3 possible roles:
   * - role_6ln: simple node, will join any network, secured or not
   * - role_6dr: DAG root, will advertise (unsecured) beacons
   * - role_6dr_sec: DAG root, will advertise secured beacons
   * */
  static int is_coordinator = 0;
  static enum { role_6ln, role_6dr, role_6dr_sec } node_role;
  node_role = role_6ln;

  int coordinator_candidate = 0;

#ifdef CONTIKI_TARGET_Z1
  /* Set node with MAC address c1:0c:00:00:00:00:01 as coordinator,
   * convenient in cooja for regression tests using z1 nodes
   * */
  extern unsigned char node_mac[8];
  unsigned char coordinator_mac[8] = { 0xc1, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 };

  coordinator_candidate = (memcmp(node_mac, coordinator_mac, 8) == 0);
#elif CONTIKI_TARGET_COOJA
  coordinator_candidate = (node_id == 1); // Node id 1 becomes coordinator
  myaddr = node_id; // Simply myaddr is set to be the same as node id (last digit of address)
#elif ZOUL_MOTE
#if IEEE_ADDR_NODE_ID
  myaddr = IEEE_ADDR_NODE_ID;
  coordinator_candidate = (myaddr == 1);
#endif
#endif


  if(coordinator_candidate) {
    if(LLSEC802154_ENABLED) {
      node_role = role_6dr_sec;
    } else {
      node_role = role_6dr;
    }
  } else {
    node_role = role_6ln;
  }

#if CONFIG_VIA_BUTTON && 0
  {
#define CONFIG_WAIT_TIME 5

    SENSORS_ACTIVATE(button_sensor);
    etimer_set(&et, CLOCK_SECOND * CONFIG_WAIT_TIME);

    while(!etimer_expired(&et)) {
      printf("Init: current role: %s. Will start in %u seconds. Press user button to toggle mode.\n",
             node_role == role_6ln ? "6ln" : (node_role == role_6dr) ? "6dr" : "6dr-sec",
             CONFIG_WAIT_TIME);
      PROCESS_WAIT_EVENT_UNTIL(((ev == sensors_event) &&
                                (data == &button_sensor) && button_sensor.value(0) > 0)
                               || etimer_expired(&et));
      if(ev == sensors_event && data == &button_sensor && button_sensor.value(0) > 0) {
        node_role = (node_role + 1) % 3;
        if(LLSEC802154_ENABLED == 0 && node_role == role_6dr_sec) {
          node_role = (node_role + 1) % 3;
        }
        etimer_restart(&et);
      }
    }
  }

#endif /* CONFIG_VIA_BUTTON */

  printf("Init: node starting with role %s\n",
         node_role == role_6ln ? "6ln" : (node_role == role_6dr) ? "6dr" : "6dr-sec");

  tsch_set_pan_secured(LLSEC802154_ENABLED && (node_role == role_6dr_sec));
  is_coordinator = node_role > role_6ln;

  if(is_coordinator) {
    uip_ipaddr_t prefix;
    uip_ip6addr(&prefix, UIP_DS6_DEFAULT_PREFIX, 0, 0, 0, 0, 0, 0, 0);
    net_init(&prefix);
  } else {
#if ZOUL_MOTE
	uip_ip6addr(&server_ipaddr,UIP_DS6_DEFAULT_PREFIX, 0, 0, 0, 0x0212,0x4b00, 0x1003, 1);
#else
	uip_ip6addr(&server_ipaddr,UIP_DS6_DEFAULT_PREFIX, 0, 0, 0, 0x0201, 1, 1, 1);
#endif
    net_init(NULL);
  }

#if WITH_ORCHESTRA
  orchestra_init();
#endif /* WITH_ORCHESTRA */

  /* Wait until the node joins the network */
  static struct ctimer poll_timer;
  while(tsch_is_associated == 0) {
	  ctimer_set(&poll_timer,CLOCK_SECOND,&application_polling,NULL);
	  PROCESS_YIELD();
  }
  ctimer_stop(&poll_timer);

  etimer_set(&et, CLOCK_SECOND * INIT_WAIT_TIME);
  PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&et));

  /* Start to generate data packets after joining TSCH network */
#if TRAFFIC_PATTERN == 0 // Periodic traffic
#if HETEROGENEOUS_TRAFFIC
  static int period;
  period = PERIOD * 3;
  period = random_rand() % period + PERIOD;
  PRINTF("Hetero period %d\n",period);
  packet_interval = CLOCK_SECOND * period;
#else
  packet_interval = CLOCK_SECOND * PERIOD;
#endif
#else // Event-driven traffic
  random_num = random_rand() / (float)RANDOM_RAND_MAX;
#if HETEROGENEOUS_TRAFFIC
  static int rate;
  rate = INTENSITY * 4;
  rate = random_rand() % rate + INTENSITY;
  PRINTF("Hetero rate %d\n",rate);
  packet_interval = (-rate) * logf(random_num) * CLOCK_SECOND;
#else
  packet_interval = (-INTENSITY) * logf(random_num) * CLOCK_SECOND;
#endif
	  if(packet_interval == 0) {
		  packet_interval = 1;
	  }
#endif
  if(!is_coordinator) {
//	  /* For test packet_interval is fixed 30 seconds */
//	  packet_interval = 30 * CLOCK_SECOND;
	  etimer_set(&gen,packet_interval);
  }

  while(1) {
	  PROCESS_YIELD();
	  if(ev == tcpip_event) {
		  tcpip_handler();
	  }
/*	  else if(etimer_expired(&et)) { // For debug
		  print_network_status();
		  etimer_reset(&et);
	  }*/
	  else if(etimer_expired(&gen)) {
#if TRAFFIC_PATTERN == 0
		  etimer_reset(&gen);
#if HETEROGENEOUS_TRAFFIC
		  ctimer_set(&backoff,random_rand()%(period*CLOCK_SECOND/2),send_packet,NULL);
#else
		  ctimer_set(&backoff,random_rand()%(PERIOD*CLOCK_SECOND/2),send_packet,NULL);
#endif
#else
		  send_packet(NULL);
		  random_num = random_rand() / (float)RANDOM_RAND_MAX;
#if HETEROGENEOUS_TRAFFIC
		  packet_interval = (-rate) * logf(random_num) * CLOCK_SECOND;
#else
		  packet_interval = (-INTENSITY) * logf(random_num) * CLOCK_SECOND;
#endif
		  if(packet_interval == 0) {
			  packet_interval = 1;
		  }
		  etimer_set(&gen,packet_interval);
#endif
	  }



  }

  PROCESS_END();
}
/*---------------------------------------------------------------------------*/
