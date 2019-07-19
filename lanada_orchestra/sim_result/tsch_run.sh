#!/bin/bash

label=$1; shift
orchestra=$1; shift
sbs=$1; shift
paas=$1; shift
hetero=$1; shift

poisson=$1; shift
req=$1; shift
sim_time=$1; shift
seed=$1; shift
traffic_param=$1; shift

topology=$1; shift
sched_param=$1; shift
sf_length=$1; shift
max_rt=$1; shift
app=$1; shift

replace=$1; shift
avoid=$1; shift
sf_eb=$1; shift
sf_common=$1; shift

SBS_STRING=( rbs sbs )
POISSON_STRING=( periodic poisson )
HETERO_STRING=( homo hetero )

CONTIKI=/media/user/Harddisk/contiki-orchestra
DIR=${label}_${topology}_${POISSON_STRING[$poisson]}_${HETERO_STRING[$hetero]}_${traffic_param}_${seed}

if [ $orchestra -eq 1 ]; then
	if [ $paas -eq 1 ]; then # paas
		IN_DIR=paas_${SBS_STRING[${sbs}]}_n_pbs_${sched_param}_sf_length_${sf_length}_max_rt_${max_rt}_req_${req}
	else # orchestra
		IN_DIR=orchestra_${SBS_STRING[${sbs}]}_sf_length_${sf_length}_max_rt_${max_rt}_req_${req}
	fi
else #minimal
	IN_DIR=minimal_sf_length_${sf_length}_max_rt_${max_rt}_req_${req}
fi

echo "tsch simulation"

#sed -i 's/\#define DUAL_RADIO 0/\#define DUAL_RADIO 1/g' $CONTIKI/platform/cooja/contiki-conf.h
sed -i 's/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 1/\#define TCPIP_CONF_ANNOTATE_TRANSMISSIONS 0/g' $CONTIKI/platform/cooja/contiki-conf.h # Hide routing information
sed -i "11s/.*/    <randomseed>${seed}<\/randomseed>/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc 
sed -i "s/TIMEOUT([0-9]*);/TIMEOUT(${sim_time});/" ${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc 

# when the node id is multiple of slotframe length, it is allocated to the first slot of the slotframe, which is what we don't want.
# So, change the node id to different one.

mkdir -p $DIR; cd ${DIR}

if [[ -d $IN_DIR && $replace -eq 1 ]]; then
	rm -rf $IN_DIR 
fi
mkdir -p $IN_DIR; cd $IN_DIR

# Update project-conf.h using tsch_param.sh
../../tsch_param.sh $app 1 $orchestra $paas $sf_length \
									 $sf_length $max_rt $poisson $traffic_param $traffic_param \
									 $hetero $sbs $sched_param $sched_param $req \
									 $avoid $sf_eb $sf_common

cd $CONTIKI/lanada_$app
make clean TARGET=cooja
cd -

if [ ! -e COOJA.testlog ]; then
    java -mx512m -jar ${CONTIKI}/tools/cooja_${app}/dist/cooja.jar -nogui=${CONTIKI}/lanada_orchestra/sim_script/${topology}_${app}.csc -contiki="${CONTIKI}"
#    java -mx512m -jar $CONTIKI/tools/cooja/dist/cooja.jar -nogui=$CONTIKI/lanada_orchestra/sim_script/$topology\.csc -contiki="$CONTIKI"
	#	java -mx512m -classpath $CONTIKI/tools/cooja/apps/mrm/lib/mrm.jar: -jar $CONTIKI/tools/cooja/dist/cooja.jar -nogui=$CONTIKI/lanada/sim_scripts/scripts/0729_$topology\_$LR_range\.csc -contiki="$CONTIKI"
		# ant run_nogui -Dargs=/home/user/Desktop/Double-MAC/lanada/sim_scripts/scripts/0729_36grid_2X.csc -Ddir=$PWD
	#4	ant run_nogui -Dargs=/home/user/Desktop/Double-MAC/lanada/sim_scripts/scripts/0729_36grid_2X.csc
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
: <<'END'
topology=$1;
poisson=$2;
PERIOD=$3
RATE=$4
label=$5
CHECK_RATE=$6
seed=$7
tsch=$8
orchestra=$9
sbs=${10}
paas=${11}
N_PBS=${12}
N_SF=${13}
UNICAST_PERIOD=${14}
MINIMAL_PERIOD=${15}
app=${16}
sim_time=${17}
max_rt=${18}
req=${19}
hetero=${20}
replace=${21}
END
