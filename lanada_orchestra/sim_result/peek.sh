#!/bin/bash

echo "duty cycle"
tail -n 4 parsing/AVG.txt

echo "delay"
cat delay/avg_packet_delay.txt

echo "PRR"
cat PRR/PRR.txt
