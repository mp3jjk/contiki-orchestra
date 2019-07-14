#!/bin/bash

topology=$1
TRAFFIC_TYPE=$2
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
HETERO=${20}

CONTIKI=/media/user/Harddisk/contiki-orchestra
DIR_SIM=${CONTIKI}/lanada_orchestra/sim_result

declare -a TSCH_STRING=( async tsch )
declare -a RBS_SBS_STRING=( sbs rbs )
declare -a TRAFFIC_TYPE_STRING=( periodic poisson )
declare -a HETERO_STRING=( homo hetero )

if [ $ADAPTIVE -eq 1 ]; then
	SCHEDULING=paas
	IN_DIR=${SCHEDULING}_${RBS_SBS_STRING[${RBS_SBS}]}_npbs_${n_PBS}_maxrt_${MAXRT}_sfl_${UNICAST}_relreq_${REQ}
elif [ $ORCHESTRA -eq 1 ]; then
	SCHEDULING=orchestra
	IN_DIR=${SCHEDULING}_${RBS_SBS_STRING[${RBS_SBS}]}_maxrt_${MAXRT}_sfl_${UNICAST}_relreq_${REQ}
else 
	SCHEDULING=minimal
	IN_DIR=${SCHEDULING}_maxrt_${MAXRT}_sfl_${MINIMAL}_relreq_${REQ}
fi

echo "TSCH simulation"
#sed -i 's/\#define DUAL_RADIO 0/\#define DUAL_RADIO 1/g' $CONTIKI/platform/cooja/contiki-conf.h
sed -i 's/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 1/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 0/g' $CONTIKI/platform/cooja/contiki-conf.h

sed -i "11s/.*/    <randomseed>${SEED_NUMBER}<\/randomseed>/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${APP}.csc 
sed -i "s/TIMEOUT([0-9]*);/TIMEOUT(${SIM_TIME});/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${APP}.csc 

# when the node id is multiple of slotframe length, it is allocated to the first slot of the slotframe, which is what we don't want.
# So, change the node id to different one.


if [ $TRAFFIC_TYPE -eq 0 ]; then
	DIR=${LABEL}_${topology}_${TRAFFIC_TYPE_STRING[$TRAFFIC_TYPE]}_${HETERO_STRING[$HETERO]}_${PERIOD}_${SEED_NUMBER}
else
	DIR=${LABEL}_${topology}_${TRAFFIC_TYPE_STRING[$TRAFFIC_TYPE]}_${HETERO_STRING[$HETERO]}_${ARRIVAL_RATE}_${SEED_NUMBER}
fi

mkdir -p $DIR
cd ${DIR}

# Update project-conf.h using tsch_param.sh
bash $DIR_SIM/tsch_param.sh $TRAFFIC_TYPE $PERIOD $ARRIVAL_RATE $TSCH $ORCHESTRA $RBS_SBS $ADAPTIVE $n_PBS $n_SF $UNICAST $MINIMAL $APP $MAXRT $REQ $HETERO

mkdir -p $IN_DIR
cd $IN_DIR

cd $CONTIKI/lanada_$APP
make clean TARGET=cooja
cd -

if [ ! -e COOJA.testlog ]; then
    java -mx512m -jar $CONTIKI/tools/cooja_$APP/dist/cooja.jar -nogui=${CONTIKI}/lanada_orchestra/sim_script/${topology}_${APP}.csc -contiki="${CONTIKI}"
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
