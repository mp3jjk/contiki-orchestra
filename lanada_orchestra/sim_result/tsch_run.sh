#!/bin/bash

JOONKI=0

if [ $JOONKI -eq 0 ]
then
    CONTIKI=/media/user/Harddisk/contiki-orchestra/
else
    CONTIKI=~/contiki-orchestra/
fi

echo "TSCH simulation"
#sed -i 's/\#define DUAL_RADIO 0/\#define DUAL_RADIO 1/g' $CONTIKI/platform/cooja/contiki-conf.h
sed -i 's/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 1/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 0/g' $CONTIKI/platform/cooja/contiki-conf.h

topology=$1
TRAFFIC_MODEL=$2
PERIOD=$3
ARRIVAL_RATE=$4
LABEL=$5
CHECK=$6
SEED_NUMBER=$7
TSCH=$8
ORCHESTRA=$9
RBS_SBS=${10}
ADAPTIVE=${11}
n_PBS=${12}
n_SF=${13}
UNICAST=${14}
MINIMAL=${15}
APP=${16}
SIM_TIME=${17}
MAXRT=${18}
REQ=${19}

sed -i "11s/.*/    <randomseed>$SEED_NUMBER<\/randomseed>/" $CONTIKI/lanada_orchestra/sim_script/$topology\_$APP\.csc 
sed -i "s/TIMEOUT([[:digit:]]*);/TIMEOUT($SIM_TIME);/" $CONTIKI/lanada_orchestra/sim_script/$topology\_$APP\.csc 

if [ $TRAFFIC_MODEL -eq 0 ]
then
    DIR=$LABEL\_topo$topology\_traffic$TRAFFIC_MODEL\_period$PERIOD\_seed$SEED_NUMBER
else
    DIR=$LABEL\_topo$topology\_traffic$TRAFFIC_MODEL\_rate$ARRIVAL_RATE\_seed$SEED_NUMBER
fi

if [ ! -e $DIR ]
then
    mkdir $DIR
fi
cd $DIR

if [ $ORCHESTRA -eq 0 ]
then
    ../tsch_param.sh $TRAFFIC_MODEL $PERIOD $ARRIVAL_RATE $TSCH $ORCHESTRA 1 $RBS_SBS $ADAPTIVE $n_PBS $n_SF $UNICAST $MINIMAL $APP $MAXRT $REQ
else
    ../tsch_param.sh $TRAFFIC_MODEL $PERIOD $ARRIVAL_RATE $TSCH $ORCHESTRA 0 $RBS_SBS $ADAPTIVE $n_PBS $n_SF $UNICAST $MINIMAL $APP $MAXRT $REQ
fi

IN_DIR=tsch$TSCH\_orche$ORCHESTRA\_adap$ADAPTIVE\_sbs$RBS_SBS\_n_pbs$n_PBS\_maxRT$MAXRT\_uni$UNICAST\_mini$MINIMAL\_req$REQ
if [ ! -e $IN_DIR ]
then
    mkdir $IN_DIR
fi
cd $IN_DIR

echo "#########################  We are in $PWD  ########################"

HERE=$PWD
cd $CONTIKI/lanada_$APP
make clean TARGET=cooja
cd $HERE

if [ ! -e COOJA.testlog ]
then
    java -mx512m -jar $CONTIKI/tools/cooja_$APP/dist/cooja.jar -nogui=$CONTIKI/lanada_orchestra/sim_script/$topology\_$APP\.csc -contiki="$CONTIKI"
#    java -mx512m -jar $CONTIKI/tools/cooja/dist/cooja.jar -nogui=$CONTIKI/lanada_orchestra/sim_script/$topology\.csc -contiki="$CONTIKI"
	#	java -mx512m -classpath $CONTIKI/tools/cooja/apps/mrm/lib/mrm.jar: -jar $CONTIKI/tools/cooja/dist/cooja.jar -nogui=$CONTIKI/lanada/sim_scripts/scripts/0729_$topology\_$LR_range\.csc -contiki="$CONTIKI"
		# ant run_nogui -Dargs=/home/user/Desktop/Double-MAC/lanada/sim_scripts/scripts/0729_36grid_2X.csc -Ddir=$PWD
	#	ant run_nogui -Dargs=/home/user/Desktop/Double-MAC/lanada/sim_scripts/scripts/0729_36grid_2X.csc
fi
# else # If MRM mode
# 	if [ ! -e COOJA.testlog ]
# 	then
# 		cd $CONTIKI/tools/cooja_mrm$MRM 
# 		if [ $ONLY_LONG -eq 0 ]
# 		then
# 			ant run_nogui -Dargs=$CONTIKI/lanada/sim_scripts/scripts/$topology\_$LR_range\.csc
# 		else
# 			ant run_nogui -Dargs=$CONTIKI/lanada/sim_scripts/scripts/$topology\_$LR_range\_L\.csc
# 		fi
# 		mv build/COOJA.testlog $HERE
# 		cd $HERE
# 	fi
# fi

sed -i '/last message/d' COOJA.testlog
if [ ! -e report_summary.txt ]
then
    ../../pp_test.sh
fi
cd ../..

echo "Simulation finished"
