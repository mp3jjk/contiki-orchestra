# avr.awk
# Calculate average along columns

BEGIN { 
	FS=" "
	for ( node_id = 1; node_id <= num_node; node_id++ ) {
		sum[node_id] = 0
		count[node_id] = 0
	}
} 
{ 
	for ( node_id = 1; node_id <= num_node; node_id++ ) {
		sum[node_id] += $node_id 
		count[node_id]++
	}
}
END { 
	for ( node_id = 1; node_id <= num_node; node_id++ )
		printf("%f ", sum[node_id]/count[node_id])
}


