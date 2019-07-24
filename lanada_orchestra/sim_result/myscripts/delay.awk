# delay.awk
# Input: COOJA.testlog
# field: time/(int)/app//DATA/id/(int)/from/(int)/ASN/(int) : 11 fields
# field: time/1/DATA/recv/'DATA/id/(int)/from/(int)' : 9 fields
# Use: awk -f delay.awk num_node=40 (or 21)

BEGIN { 
	FS="[: ]"
	for(node_id=1; node_id<=num_node; node_id++) 
		count[node_id]=0
}
( $3 ~ /app/ ) && ( $5 ~ /DATA/ ) { 
	node_id=int($9)
	data_id[node_id]=$7
	time_send[node_id]=$1 
}
( $3 ~ /DATA/ ) && ( $4 ~ /recv/ ) { 
	node_id=int($9) # int() can remove " ' "
	if (data_id[node_id] == int($7)) {
		time_recv[node_id]=$1
		delay[node_id]=time_recv[node_id]-time_send[node_id]
		sum_delay[node_id]+=delay[node_id]
		count[node_id]++
	}
}
END {
	for(node_id=1; node_id<=num_node; node_id++) {
		if (count[node_id]==0) printf("%d ", 0)
		else printf("%10d", sum_delay[node_id]/count[node_id])
	}
	printf("\n")
}
