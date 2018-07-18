#!/bin/bash

TARGET=$1
LABEL=$2

rm $LABEL
./avr.sh prr $TARGET > $LABEL
./avr.sh delay $TARGET >> $LABEL
./avr.sh duty $TARGET >> $LABEL

scp $LABEL jhjung@cafe3.kaist.ac.kr:~/
