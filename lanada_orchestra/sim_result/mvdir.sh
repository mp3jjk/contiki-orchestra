#!/bin/bash 

label=$1 

for DIR in ${1}*; do
	cd $DIR
	for IN_DIR in *; do
		seed=$(echo $DIR | awk '{ print substr($1, length($1)) }')
		FILE_F=$(echo $DIR | awk '{print substr($1, 1, length($1)-1)}' )
		FILE=log_${FILE_F}${IN_DIR}_seed${seed}
		cp ${IN_DIR}/COOJA.testlog ../${FILE}
	done
  cd ..
done
