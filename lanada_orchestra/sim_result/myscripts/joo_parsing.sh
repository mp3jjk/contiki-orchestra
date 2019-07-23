#q!/bin/bash 

. var.sh

label=$1
num_node=${2:-40}

for req in "${REQ[@]}"; do
	for traffic_param in "${TRAFFIC_PARAM[@]}";	do
		for topology in "${TOPOLOGY[@]}";	do
			for sched_param in "${SCHED_PARAM[@]}";	do
				for sf_length in "${SF_LENGTH[@]}";	do
					for max_rt in "${MAX_RT[@]}";	do
						for sf_eb in "${SF_EB[@]}"; do
							for sf_common in "${SF_COMMON[@]}"; do
								for static in "${STATIC[@]}"; do
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
											FILE=${DIR}_${IN_DIR}
											# Check whether logfile exists
											for metric in "${METRIC[@]}"; do
												for seed in "${SEED[@]}"; do
													if [ -e log_${FILE}_${seed} ]; then
														awk -f ${metric}.awk num_node=${num_node} ${FILE} >> ${metric}_all
													fi
										done
										if [ -d $dir2 ]; then
											echo >> ${dir2}/${metric}_all # blank line
											awk -f avr.awk num_node=${num_node} ${dir2}/${metric}_all >> ${dir2}/${metric}_all
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
