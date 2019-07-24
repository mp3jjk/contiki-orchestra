#!/bin/bash
# var.sh
# Use: In the file to use these variables, type ". var.sh"

label=A1
tsch=1 # Whether Async(0) or TSCH(1)
orchestra=1 # Whether Minimal(0) or Orchestra(1) **
sbs=1 # Whether RBS(0) or SBS(1) **
paas=1 # Whether basic(0) or PAAS(1) **
hetero=1
poisson=1 # Whether Periodic(0) or Poisson(1) **
avoid=1 # Avoid the situation that node id is multiple of slotframe length

CHECK_RATE=( 8 )

TRAFFIC_PARAM=( 10 ) # rate or period
TOPOLOGY=( random_40 ) # tree_c4_21 grid_36 random_40 child_4 **
SCHED_PARAM=( 0 ) # n-pbs(paas) or n-sf(ours)
SF_LENGTH=( 19 ) # SlotFrame length for Orchestra and paas **
SF_EB=( 20 ) # How many times the length of EB slotframe is the length of unicast slotframe.
SF_COMMON=( 2 ) # How many times the length of EB slotframe is the length of unicast slotframe.
MAX_RT=( 3 ) # maximum retries
STATIC=( 0 )
REQ=( 95 ) # reliability contraint
METRIC=( prr delay duty )

sim_time=54000000 #miliseconds

SBS_STRING=( rbs sbs )
POISSON_STRING=( periodic poisson )
HETERO_STRING=( homo hetero )

CONTIKI=/media/user/Harddisk/contiki-orchestra
