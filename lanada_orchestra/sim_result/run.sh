#!/bin/bash

APP=$1
REPLACE=$2

TSCH=1 # Whether Async(0) or TSCH(1)
ORCHESTRA=1 # Whether Minimal(0) or Orchestra(1) **
RBS_SBS=0 # Whether RBS(0) or SBS(1) **
TRAFFIC=1 # Whether Periodic(0) or Poisson(1) **
ADAPTIVE_MODE=0 # Whether basic(0) or PAAS(1) **
VAR_PERIOD=(30) # T **
VAR_ARRIVAL=(30) # lambda **
VAR_TOPOLOGY=( random_40 tree_c4_21 ) # tree_c4_21 grid_36 random_50 child_4 **
LABEL="JOO" #**
SEED_NUMBER=( "1" "2" "3" "4" "5" ) #**
VAR_N_PBS=("0") # Hard coded n-PBS. for PAAS
VAR_N_SF=("0") # Hard coded n-SF. For our scheduling algorithm
VAR_CHECK_RATE=(8)
VAR_UNICAST_PERIOD=(19) # SlotFrame length for Orchestra and PAAS **
VAR_MINIMAL_PERIOD=(23) # SlotFrame length for Minimal **
VAR_MAX_RT=("3") # maximum retries
REQ=95 # reliability contraint
HETERO=0
SIM_TIME=1000000 #**
BOTH_TRAFFIC=0

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
						./async_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH $APP $SIM_TIME $REPLACE
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
elif [ $TSCH -eq 1 ]
then
	if [ $TRAFFIC -eq 0 ]
	then
		for seed in "${SEED_NUMBER[@]}"
		do
	    for period in "${VAR_PERIOD[@]}"
	    do
				for topology in "${VAR_TOPOLOGY[@]}"
				do
					for n_pbs in "${VAR_N_PBS[@]}"
					do
						for n_sf in "${VAR_N_SF[@]}"
						do
							for check in "${VAR_CHECK_RATE[@]}"
							do
								for uni in "${VAR_UNICAST_PERIOD[@]}"
								do
									for mini in "${VAR_MINIMAL_PERIOD[@]}"
									do
										for maxRT in "${VAR_MAX_RT[@]}"
										do
											echo $SIM_TIME
											./tsch_run.sh $topology $TRAFFIC $period 0 "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE $n_pbs $n_sf $uni $mini $APP $SIM_TIME $maxRT $REQ $HETERO
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
	if [ $BOTH_TRAFFIC -eq 1 ]
	then
		TRAFFIC=1
		LABEL="G6"
	fi
	if [ $TRAFFIC -eq 1 ]
	then
		for seed in "${SEED_NUMBER[@]}"
		do
			for arrival in "${VAR_ARRIVAL[@]}"
			do
				for topology in "${VAR_TOPOLOGY[@]}"
				do
					for n_pbs in "${VAR_N_PBS[@]}"
					do
						for n_sf in "${VAR_N_SF[@]}"
						do
							for check in "${VAR_CHECK_RATE[@]}"
							do
								for uni in "${VAR_UNICAST_PERIOD[@]}"
								do
									for mini in "${VAR_MINIMAL_PERIOD[@]}"
									do
										for maxRT in "${VAR_MAX_RT[@]}"
										do
											./tsch_run.sh $topology $TRAFFIC 0 $arrival "${LABEL}" $check $seed $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE_MODE $n_pbs $n_sf $uni $mini $APP $SIM_TIME $maxRT $REQ $HETERO
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
fi
