#!/bin/bash 

. var.sh

label=$1 
SEED=(1 2 3 4 5 6 7 8)

for req in "${REQ[@]}"; do
	for traffic_param in "${TRAFFIC_PARAM[@]}";	do
		for topology in "${TOPOLOGY[@]}";	do
			for sched_param in "${SCHED_PARAM[@]}";	do
				for sf_length in "${SF_LENGTH[@]}";	do
					for max_rt in "${MAX_RT[@]}";	do
						for sf_eb in "${SF_EB[@]}"; do
							for sf_common in "${SF_COMMON[@]}"; do
								for static in "${STATIC[@]}"; do
									for metric in "${METRIC[@]}"; do
										for seed in "${SEED[@]}"; do
											# Open directories
											DIR=${label}_${topology}_${HETERO_STRING[$hetero]}_${POISSON_STRING[$poisson]}${traffic_param}
											if [ $orchestra -eq 1 ]; then
												if [ $paas -eq 1 ]; then # paas
													IN_DIR=paas_n_pbs${sched_param}_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}
												else # orchestra
													IN_DIR=orchestra_${SBS_STRING[${sbs}]}_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}
												fi
											else #minimal
												IN_DIR=minimal_sf_length${sf_length}_sf_eb${sf_eb}_sf_common${sf_common}_static${static}_avoid${avoid}_max_rt${max_rt}_req${req}
											fi
											dir=${DIR}_${seed}/${IN_DIR}
											NAME=${DIR}_${IN_DIR}
											# Check whether logfile exists
											echo $dir
											if [ -d ${dir} ]; then
												print 1
												cp ${dir}/COOJA.testlog log_${FILE}_seed${seed}
											fi
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
done
