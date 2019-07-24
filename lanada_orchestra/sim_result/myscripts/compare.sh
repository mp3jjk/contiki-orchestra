#!/bin/bash

compare=${1:-traffic}
num_node=${2:-40}

for metric in "${METRIC[@]}"; do
	for FILE in ${metric}_*; do
		for FILE2 in $((awk -F"${compare[0-9]+}" "{ print ${1}${2} }")); done
			awk -f avr.awk num_node=${num_node} ${FILE} >> compare_${metric}_${FILE2}
		done
	done
done

: << END
		index=$(( awk { print index($FILE, $compare) }))
		NAME_F=$(( awk { print substr($FILE, 1, $index) } ))
		NAME_R=$(( awk { print substr($FILE, $index+length(
		awk -F"${compare}" 
END
