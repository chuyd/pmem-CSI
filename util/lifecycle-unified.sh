#!/bin/bash -xeu

# run simple volume lifecycle in singlehost, drivermode=Unified
# VOLUME_ID is parsed from output of create command

export CSI_ENDPOINT=tcp://127.0.0.1:10000
NAME=nspace5
SIZE=1073741824
#ERASE=false
ERASE=true
#FSTYPE=xfs
FSTYPE=ext4
NSMODE=fsdax
STAGEPATH=/tmp/stage-${NAME}
TARGETPATH=/tmp/target-${NAME}

out=`$GOPATH/bin/csc controller create-volume --req-bytes $SIZE --cap SINGLE_NODE_WRITER,mount,$FSTYPE --params eraseafter=$ERASE --params nsmode=$NSMODE $NAME`
VOLID=`echo $out |awk '{print $1}' |tr -d \"`
#echo VolumeID=$VOLID
mkdir -p $STAGEPATH $TARGETPATH
$GOPATH/bin/csc node stage $VOLID --cap SINGLE_NODE_WRITER,mount,$FSTYPE --staging-target-path $STAGEPATH --attrib name=$NAME --attrib nsmode=$NSMODE
$GOPATH/bin/csc node publish $VOLID --cap SINGLE_NODE_WRITER,mount,$FSTYPE --staging-target-path $STAGEPATH --target-path $TARGETPATH
$GOPATH/bin/csc node unpublish $VOLID --target-path $TARGETPATH
$GOPATH/bin/csc node unstage $VOLID --staging-target-path $STAGEPATH
$GOPATH/bin/csc controller delete-volume $VOLID
rmdir $STAGEPATH $TARGETPATH
