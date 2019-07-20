#!/bin/bash

label=jul20 #**

tsch=1 # Whether Async(0) or TSCH(1)
orchestra=1 # Whether Minimal(0) or Orchestra(1) **
sbs=1 # Whether RBS(0) or SBS(1) **
paas=1 # Whether basic(0) or PAAS(1) **
hetero=0
poisson=1 # Whether Periodic(0) or Poisson(1) **
avoid=1 # Avoid the situation that node id is multiple of slotframe length

CHECK_RATE=( 8 )

SEED=( 1 2 3 4 5 6 ) #**
TRAFFIC_PARAM=( 10 20 40 80 ) # rate or period
TOPOLOGY=( random_40 tree_c4_21 ) # tree_c4_21 grid_36 random_40 child_4 **
SCHED_PARAM=( 0 ) # n-pbs(paas) or n-sf(ours)
SF_LENGTH=( 19 ) # SlotFrame length for Orchestra and paas **
SF_EB=( 20 ) # How many times the length of EB slotframe is the length of unicast slotframe.
SF_COMMON=( 2 ) # How many times the length of EB slotframe is the length of unicast slotframe.
MAX_RT=( 3 ) # maximum retries
STATIC=( 0 )
REQ=( 95 98 ) # reliability contraint

app=${1:-1} # Defualt 1
replace=${2:-0} # Default 0.

# Async sim

if [ $tsch -eq 0 ]; then
	for seed in "${SEED[@]}";	do
		for traffic_param in "${TRAFFIC_PARAM[@]}"; do
			for topology in "${TOPOLOGY[@]}";	do
				for check_rate in "${CHECK_RATE[@]}";	do
					for req in "${REQ[@]}"; do
						sim_time=$((traffic_param*1500000))
						./async_run.sh $topology $poisson $traffic_param $label $check_rate $seed $tsch $app $sim_time $replace
					done
				done
			done
		done
	done
else
	for seed in "${SEED[@]}"; do
		for traffic_param in "${TRAFFIC_PARAM[@]}";	do
			for topology in "${TOPOLOGY[@]}";	do
				for sched_param in "${SCHED_PARAM[@]}";	do
					for sf_length in "${SF_LENGTH[@]}";	do
						for max_rt in "${MAX_RT[@]}";	do
							for sf_eb in "${SF_EB[@]}"; do
								for sf_common in "${SF_COMMON[@]}"; do
									for static in "${STATIC[@]}"; do
										for req in "${REQ[@]}"; do
											sim_time=$((traffic_param*1500000))
											./tsch_run.sh $label $orchestra $sbs $paas $hetero \
																		$poisson $req $sim_time $seed $traffic_param \
																		$topology $sched_param $sf_length $max_rt $app \
																		$avoid $sf_eb $sf_common $replace $static 
										done
									done
								done
							done
						done
					done
				done
			done
		done
	done
fi
