#!/bin/bash

TSCH=1 # Whether Async(0) or TSCH(1)
ORCHESTRA=0 # Whether Minimal(0) or Orchestra(1)
RBS_SBS=0 # Whether RBS(0) or SBS(1)
TRAFFIC=1 # Whether Periodic(0) or Poisson(1)
ADAPTIVE_MODE=0 # Whether basic(0) or adaptive(1)
VAR_PERIOD=(1) # T
VAR_ARRIVAL=(1 5 25) # lambda
VAR_TOPOLOGY=("tree_c4_21") # tree_c2_31 tree_c3_40 grid_36 random_50
LABEL="G2"
SEED_NUMBER=("1" "2")
VAR_N_SBS=("0") # Hard coded n-SBS
VAR_CHECK_RATE=(8)
VAR_UNICAST_PERIOD=(11)
VAR_MINIMAL_PERIOD=(7)
SIM_TIME=(3600000)
APP=3

# Async sim

if [ $TSCH -eq 0 ]
then
    if [ $TRAFFIC -eq 0 ]
    then
	for seed in "${SEED_NUMBER[@]}"
	do
	    for period in "${VAR_PERIOD[@]}"
	    do
		for topology in "${VAR_TOPOLOGY[@]}"
		do
		    for check in "${VAR_CHECK_RATE[@]}"
		    do
			./async_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH $APP $SIM_TIME
		    done
		done
	    done
	done
    else
	for seed in "${SEED_NUMBER[@]}"
	do
	    for arrival in "${VAR_ARRIVAL[@]}"
	    do
		for topology in "${VAR_TOPOLOGY[@]}"
		do
		    for check in "${VAR_CHECK_RATE[@]}"
		    do
			./async_run.sh $topology $TRAFFIC 0 $arrival "${LABEL}" $check $seed $TSCH $APP $SIM_TIME
		    done
		done
	    done
	done
    fi
fi

# TSCH sim
if [ $TSCH -eq 1 ]
then
    if [ $TRAFFIC -eq 0 ]
    then
	for seed in "${SEED_NUMBER[@]}"
	do
	    for period in "${VAR_PERIOD[@]}"
	    do
		for topology in "${VAR_TOPOLOGY[@]}"
		do
		    for n_sbs in "${VAR_N_SBS[@]}"
		    do
			for check in "${VAR_CHECK_RATE[@]}"
			do
			    for uni in "${VAR_UNICAST_PERIOD[@]}"
			    do
				for mini in "${VAR_MINIMAL_PERIOD[@]}"
				do
				    if [ $period = 1 ]
				    then
					SIM_TIME=3600000
				    elif [ $period = 2 ]
				    then
					SIM_TIME=7200000
				    fi
				    ./tsch_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE $n_sbs $uni $mini $APP $SIM_TIME
				done
			    done
			done
		    done
		done
	    done
	done
    else
	for seed in "${SEED_NUMBER[@]}"
	do
	    for arrival in "${VAR_ARRIVAL[@]}"
	    do
		for topology in "${VAR_TOPOLOGY[@]}"
		do
		    for n_sbs in "${VAR_N_SBS[@]}"
		    do
			for check in "${VAR_CHECK_RATE[@]}"
			do
			    for uni in "${VAR_UNICAST_PERIOD[@]}"
			    do
				for mini in "${VAR_MINIMAL_PERIOD[@]}"
				do
				    if [ $arrival = 1 ]
				    then
					SIM_TIME=3600000
				    elif [ $arrival = 5 ]
				    then
					SIM_TIME=7200000
				    elif [ $arrival = 25]
				    then
					SIM_TIME=10800000
				    fi
				    ./tsch_run.sh $topology $TRAFFIC 0 $arrival "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE $n_sbs $uni $mini $APP $SIM_TIME
				done
			    done
			done
		    done
		done
	    done
	done
    fi
fi
