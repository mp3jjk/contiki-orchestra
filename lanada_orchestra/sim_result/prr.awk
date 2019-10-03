# prr.awk
# Input: COOJA.testlog
# parameters: num_node
# field: time/(int)/app//DATA/
#					id/(int)/from/(int)/ASN/
#				(int) : 11 fields
# field: time/1/DATA/recv/'DATA/
#					id/(int)/from/(int)' 
#          9 fields
# Use: awk -f prr.awk num_node=40 (or 21) COOJA.testlog

BEGIN { 
	FS="[: ]"
	for(node_id=1; node_id<=num_node; node_id++) {
		count_send[node_id]=0
		count_recv[node_id]=0
	}
}
( $3 ~ /app/ ) && ( $5 ~ /DATA/ ) { 
	node_id=int($9)
	data_id[node_id]=$7
	count_send[node_id]++
}
( $3 ~ /DATA/ ) && ( $4 ~ /recv/ ) { 
	node_id=int($9) # int() can remove " ' "
	count_recv[node_id]++
}
END {
	for(node_id=1; node_id<=num_node; node_id++) {
		if (count_send[node_id]==0)
			printf("%d ", 0)
		else
			printf("%*.*f", 10, 5, count_recv[node_id]/count_send[node_id])
	}
	printf("\n")
}
