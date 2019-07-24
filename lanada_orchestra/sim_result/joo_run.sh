#!/bin/bash

. var.sh

app=${1:-1} # Defualt 1
replace=${2:-0} # Default 0.

for req in "${REQ[@]}"; do
	for traffic_param in "${TRAFFIC_PARAM[@]}";	do
		for topology in "${TOPOLOGY[@]}";	do
			for sched_param in "${SCHED_PARAM[@]}";	do
				for sf_length in "${SF_LENGTH[@]}";	do
					for max_rt in "${MAX_RT[@]}";	do
						for sf_eb in "${SF_EB[@]}"; do
							for sf_common in "${SF_COMMON[@]}"; do
								for static in "${STATIC[@]}"; do
									for seed in "${SEED[@]}"; do
										DIR=${label}_${topology}_${HETERO_STRING[$hetero]}_${POISSON_STRING[$poisson]}${traffic_param}
										if [ $orchestra -eq 1 ]; then
											if [ $paas -eq 1 ]; then # paas
												IN_DIR=paas_n_pbs${sched_param}_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}_seed${seed}
											else # orchestra
												IN_DIR=orchestra_${SBS_STRING[${sbs}]}_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}_seed${seed}
											fi
										else #minimal
											IN_DIR=minimal_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}_seed${seed}
										fi
										FILE=${DIR}_${IN_DIR}
										echo "tsch simulation"

										#sed -i 's/\#define DUAL_RADIO 0/\#define DUAL_RADIO 1/g' $CONTIKI/platform/cooja/contiki-conf.h
										sed -i 's/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 1/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 0/g' $CONTIKI/platform/cooja/contiki-conf.h # Hide routing information
										sed -i "11s/.*/    <randomseed>${seed}<\/randomseed>/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc 
										sed -i "s/TIMEOUT([0-9]*);/TIMEOUT(${sim_time});/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc 

										# when the node id is multiple of slotframe length, it is allocated to the first slot of the slotframe, which is what we don't want.
										# So, change the node id to different one.

										# Update project-conf.h using tsch_param.sh
										./tsch_param.sh $app 1 $orchestra $paas $sf_length \
																			 $sf_length $max_rt $poisson $traffic_param $traffic_param \
																			 $hetero $sbs $sched_param $sched_param $req \
																			 $avoid $sf_eb $sf_common $static

										cd $CONTIKI/lanada_$app && make clean TARGET=cooja && cd -

										if [ ! -e COOJA.testlog ]; then
												java -mx512m -jar ${CONTIKI}/tools/cooja_${app}/dist/cooja.jar -nogui=${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc -contiki="${CONTIKI}"
										fi

										mv COOJA.testlog $FILE

										
										# ./joo_parsing.sh $label $num_node

										echo "Simulation finished"
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

: <<'END'
END
