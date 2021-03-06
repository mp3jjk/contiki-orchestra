#!/bin/bash 

label=$1 
old=$2

for DIR in ${1}*; do
	cd $DIR
	for IN_DIR in *; do
		if [ $old -eq 1 ]; then
			seed=$(echo $DIR | awk -F'_seed' '{print $2}')
			FILE_F=$(echo $DIR | awk -F'seed' '{print $1}')
		else
			seed=$(echo $DIR | awk '{ print substr($1, length($1)) }')
			FILE_F=$(echo $DIR | awk '{print substr($1, 1, length($1)-1)}' )
		fi
		FILE=log_${FILE_F}${IN_DIR}_seed${seed}
		mv ${IN_DIR}/COOJA.testlog ../${FILE}
	done
  cd ..
done
