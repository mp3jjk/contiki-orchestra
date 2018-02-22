#!/bin/bash

for dir in *; do
    if [ -d $dir ]
    then
	cd $dir
	rm -r tsch1_orche1_adap1*
	cd ..
    fi
done
