#!/bin/bash

JOONKI=0

if [ $JOONKI -eq 0 ]
then
    CONTIKI=/media/user/Harddisk/contiki-orchestra/
else
    CONTIKI=~/Desktop/contiki-orchestra/
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
n_SBS=${12}

sed -i "11s/.*/    <randomseed>$SEED_NUMBER<\/randomseed>/" $CONTIKI/lanada_orchestra/sim_script/$topology\.csc 

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
    ../tsch_param.sh $TRAFFIC_MODEL $PERIOD $ARRIVAL_RATE $TSCH $ORCHESTRA 1 $RBS_SBS $ADAPTIVE $n_SBS
else
    ../tsch_param.sh $TRAFFIC_MODEL $PERIOD $ARRIVAL_RATE $TSCH $ORCHESTRA 0 $RBS_SBS $ADAPTIVE $n_SBS
fi

IN_DIR=tsch$TSCH\_orche$ORCHESTRA\_adap$ADAPTIVE\_sbs$RBS_SBS\_n_sbs$n_SBS
if [ ! -e $IN_DIR ]
then
    mkdir $IN_DIR
#    mkdir sr\_strobe$STROBE_CNT\_$LR_range\_$CHECK\_rou$ROUTING_NO_ENERGY
fi
cd $IN_DIR
#cd sr\_strobe$STROBE_CNT\_$LR_range\_$CHECK\_rou$ROUTING_NO_ENERGY
echo "#########################  We are in $PWD  ########################"

HERE=$PWD
cd $CONTIKI/lanada_orchestra
make clean TARGET=cooja
cd $HERE

if [ ! -e COOJA.testlog ]
then
    java -mx512m -jar $CONTIKI/tools/cooja/dist/cooja.jar -nogui=$CONTIKI/lanada_orchestra/sim_script/$topology\.csc -contiki="$CONTIKI"
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


# if [ ! -e report_summary.txt ]
# then
#     ../../pp.sh
# fi
cd ../..

echo "Simulation finished"
