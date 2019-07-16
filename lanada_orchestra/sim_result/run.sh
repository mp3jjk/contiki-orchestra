#!/bin/bash

label=JOO #**
tsch=1 # Whether Async(0) or TSCH(1)
orchestra=1 # Whether Minimal(0) or Orchestra(1) **
sbs=1 # Whether RBS(0) or SBS(1) **
paas=0 # Whether basic(0) or PAAS(1) **
hetero=0
poisson=1 # Whether Periodic(0) or Poisson(1) **
req=95 # reliability contraint
sim_time=1100000 #**

CHECK_RATE=( 8 )

SEED=( 1 2 ) #**
TRAFFIC_PARAM=( 30 ) # rate or period
TOPOLOGY=( tree_c4_21 ) # tree_c4_21 grid_36 random_50 child_4 **
SCHED_PARAM=( 0 ) # n-pbs(paas) or n-sf(ours)
SF_LENGTH=( 23 ) # SlotFrame length for Orchestra and paas **
MAX_RT=( 3 ) # maximum retries

app=$1
replace=$2

# Async sim

if [ $tsch -eq 0 ]; then
	for seed in "${SEED[@]}";	do
		for traffic_param in "${TRAFFIC_PARAM[@]}"; do
			for topology in "${TOPOLOGY[@]}";	do
				for check_rate in "${CHECK_RATE[@]}";	do
					./async_run.sh $topology $poisson $traffic_param $label $check_rate $seed $tsch $app $sim_time $replace
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
							./tsch_run.sh $label $orchestra $sbs $paas $hetero \
														$poisson $req $sim_time $seed $traffic_param \
														$topology $sched_param $sf_length $max_rt $app \
														$replace
						done
					done
				done
			done
		done
	done
fi
