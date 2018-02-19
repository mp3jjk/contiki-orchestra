#!/bin/bash

for dir in *; do
    echo $dir
    cd $dir
    echo "duty cycle"
    tail -n 4 parsing/AVG.txt

    echo "delay"
    cat delay/avg_packet_delay.txt

    echo "PRR"
    cat PRR/PRR.txt
    cd ..
done
