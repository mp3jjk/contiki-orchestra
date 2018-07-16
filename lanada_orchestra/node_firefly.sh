#!/bin/bash
SKIP=0
UPLOAD=1
PORT=1
NODE="0x1"

for opt in $@
do
	case "$opt" in
		"k" ) SKIP=1;;
		"l" ) UPLOAD=0;;
		0x* ) NODE=$opt;;
		* ) PORT=$opt;;
	esac
done

if [ $UPLOAD -eq 1 ]
then
	if [ $SKIP -eq 0 ]
	then
		sudo make clean TARGET=zoul BOARD=firefly
		sudo make node TARGET=zoul BOARD=firefly
	fi
	sudo make node.upload NODEID=$NODE TARGET=zoul PORT=/dev/ttyUSB$PORT BOARD=firefly
fi
sudo make login TARGET=zoul PORT=/dev/ttyUSB$PORT BOARD=firefly


