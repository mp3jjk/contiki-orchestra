# duty.awk
# Input: COOJA.testlog

BEGIN { FS=" " }
# ( $1 ~ /PowerTracker/ ) { max_on_ratio = 0 }
# ( $2 ~ /MONITORED/ ) { total_time=$3 }
( $1 ~ /Contiki_[0-9]+/ ) && ( $2 ~ /ON/ ) {
	node_id = substr($1, 9)
	on_ratio[node_id] = $5
	#if (max_on_ratio < on_ratio )	max_on_ratio = on_ratio 
}
END {	
	for (node_id = 1; node_id < num_node; node_id++) {
		printf("%*.*f", 10, 3, on_ratio[node_id]) 
	}		
	printf("\n")
}
											
