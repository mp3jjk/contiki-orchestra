#!/bin/bash 

. var.sh

label=$1
num_node=${2:-40}
METRIC=( prr delay duty )

for metric in "${METRIC[@]}"; do
	for FILE in log_${1}*; do
		NAME=$(echo "$FILE" | awk -F'_seed' '{print $1}')
		# rm -f ${NAME}_${metric}
		rm -f ${metric}_${NAME}
	done
done

for metric in "${METRIC[@]}"; do
	for FILE in log_${1}*; do
		#seed=$(echo $FILE | awk -F'seed' '{print $2}')
		NAME=$(echo "$FILE" | awk -F'_seed' '{print $1}')
		awk -f ${metric}.awk num_node=${num_node} ${FILE} >> ${metric}_${NAME}
	done
done

 
#	awk -f avr.awk num_node=${num_node} ${dir2}/${metric}_all >> ${dir2}/${metric}_all
