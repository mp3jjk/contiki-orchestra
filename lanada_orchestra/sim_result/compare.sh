#!/bin/bash

compare=${1:-poisson}
num_node=${2:-40}
METRIC=( prr delay duty )

for metric in "${METRIC[@]}"; do
	for FILE in ${metric}_*; do
		COMMON=$(echo $FILE | awk -F"_$compare" '{ print $1substr($2,index($2,"_")) }')
		rm -f compare_${COMMON}
	done
done

for metric in "${METRIC[@]}"; do
	for FILE in ${metric}_*; do
		COMMON=$(echo $FILE | awk -F"_$compare" '{ print $1substr($2,index($2,"_")+1) }')
		diff=$(echo $FILE | awk -F"_$compare" '{ print substr($2,1,index($2,"_")-1) }')
		echo "$diff  |   $(awk -f avr.awk num_node=${num_node} ${FILE})" >> compare_${COMMON}
	done
done

