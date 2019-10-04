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
	data_id=int($7)
	time_send=int($1)
	time_send_array[node_id, data_id]=time_send
}
( $3 ~ /DATA/ ) && ( $4 ~ /recv/ ) { 
	node_id=int($9) # int() can remove " ' "
	data_id=int($7)
	if (time_send_array[node_id, data_id] != 0) {
		time_recv=$1
		delay=time_recv-time_send_array[node_id, data_id]
		sum_delay[node_id]+=delay
		count[node_id]++
	}
}
END {
	for(node_id=1; node_id<=num_node; node_id++) {
		if (count[node_id]==0) printf("%d ", 0)
		else printf("%10d", sum_delay[node_id]/count[node_id]/1000)
	}
	printf("\n")
}
