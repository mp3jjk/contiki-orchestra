#!/bin/bash 

. var.sh

label=$1
num_node=${2:-40}
METRIC=( prr delay duty )

for metric in "${METRIC[@]}"; do
	rm -rf ${metric}_all
	for FILE in log_${1}*; do
		NAME=$((awk -F'seed' 'print $2' $FILE))
		# NAME=substr($FILE, 1, length($FILE)-2) # NAME = FILE - seed number
		awk -f ${metric}.awk num_node=${num_node} ${NAME} >> ${metric}_${NAME}
	done
done

