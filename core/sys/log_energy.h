#ifndef LOG_ENERGY_H__
#define LOG_ENERGY_H__

#include <stdio.h>
#include <stdint.h>
#include "contiki-conf.h"
typedef int32_t energy_t;


#ifdef COOJA

const energy_t DISSIPATION_RATE[];

energy_t COOJA_radioOn;
energy_t COOJA_radioTx;
energy_t COOJA_radioRx;
energy_t COOJA_duration;
#endif

#ifdef ZOLERTIA_Z1
#include "energest.h"
#endif
 
#ifdef ZOUL_MOTE
#include "energest.h"
#endif

energy_t get_current_energy(void);


#endif
