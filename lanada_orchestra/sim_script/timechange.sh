#!/bin/bash

for script in *.csc; do
#    sed -i 's/TIMEOUT(18000000, log.log("last message: " + msg + "\\n"));/TIMEOUT(3600000);/' $script
    sed -i 's/TIMEOUT([[:digit:]]*);/TIMEOUT(1);/' $script
done
