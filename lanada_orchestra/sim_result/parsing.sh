#!/bin/bash

for dir in */ ; do
    cd $dir
    for indir in */ ; do
	cd $indir
	sed -i '/last message/d' ./COOJA.testlog
	if [ ! -e report_summary.txt ]
	then
	    ../../pp_test.sh
	fi
	cd ..
    done
    cd ..
done
