#!/bin/bash

TSCH=0 # Whether Async(0) or TSCH(1)
ORCHESTRA=0 # Whether Minimal(0) or Orchestra(1)
RBS_SBS=0 # Whether RBS(0) or SBS(1)
TRAFFIC=0 # Whether Periodic(0) or Poisson(1)
ADAPTIVE_MDOE=0 # Whether basic(0) or adaptive(1)
VAR_PERIOD=(5)
VAR_ARRIVAL=(1)
VAR_TOPOLOGY=("grid_36") # tree_c2_31 tree_c3_40 grid_36 random_50
LABEL="test"
SEED_NUMBER=("1")

VAR_CHECK_RATE=(8)

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
			./async_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH
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
			./async_run.sh $topology $TRAFFIC 0 $arrival "${LABEL}" $check $seed $TSCH
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
		    for check in "${VAR_CHECK_RATE[@]}"
		    do
			./tsch_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE
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
			./tsch_run.sh $topology $TRAFFIC 0 $arrival "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE
		    done
		done
	    done
	done
    fi
fi
