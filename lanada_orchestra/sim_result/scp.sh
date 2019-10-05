#!/bin/bash

TARGET=$1

tar -zcvf ${TARGET}.tar.gz allseed_*

scp ${TARGET}.tar.gz jinhwanjung@143.248.57.148:~/ipsn_result/

# scp allseed_* jhjung@cafe3.kaist.ac.kr:~/infocom_result/${TARGET}
