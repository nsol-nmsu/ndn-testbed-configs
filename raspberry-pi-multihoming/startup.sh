#!/bin/bash

# make sure we are root
if [[ $EUID != 0 ]]; then
        sudo $0 $@
        exit
fi

# exit on first error
set -e

# ndn-specific paths
NDN_ROOT=$HOME/ndn/dist
NDN_CONF=$HOME/ndn/ndn-testbed-configs/raspberry-pi-multihoming

# copy nfd config, make nlsr's required directories
cp -f $NDN_CONF/nfd.conf $NDN_ROOT/etc/ndn/nfd.conf

# set paths...
export PATH=$PATH:$NDN_ROOT/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NDN_ROOT/lib

# make keys... this part is borrowed from the ndn-start script
if ! ndnsec-get-default &>/dev/null ; then
  ndnsec-keygen /localhost/operator | ndnsec-install-cert -
fi

# start nfd
nfd 2>&1 > $NDN_CONF/${HOSTNAME}_nfd.log &
sleep 1

# configure nfd / start services
source ${HOSTNAME}-setup.txt
