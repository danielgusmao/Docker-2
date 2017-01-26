#!/bin/bash
set -e
chmod 0600 /keys/ssh-privatekey

ACTION=$1

if [ "$ACTION" == "restore" ]
then
    IP=$3
    ID=$2
    REF=$4
    mkdir -p /mnt/restore
    ssh -o StrictHostKeyChecking=no -o IdentityFile=/keys/ssh-privatekey $IP -C "sudo mkdir -p /restore; sudo chown \$USER:\$USER /restore" || true
    sshfs $IP:/restore/ /mnt/restore -o IdentityFile=/keys/ssh-privatekey -o StrictHostKeyChecking=no
    echo $ACTION
    exec ./restore.sh $ID $REF
elif [ "$ACTION" == "backup" ]
then
  PERIOD=$2
  ID=$3
  IP=$4
  DIRECTORY=$5
  for dir in $DIRECTORY
  do
    mkdir -p /mnt/$dir
    ssh -o StrictHostKeyChecking=no -o IdentityFile=/keys/ssh-privatekey $IP -C "sudo mkdir -p $dir; sudo chown \$USER:\$USER $dir" || true
    sshfs $IP:$dir /mnt/$dir -o IdentityFile=/keys/ssh-privatekey -o StrictHostKeyChecking=no
  done
  echo $ACTION
  exec ./$PERIOD.sh $ID
else
  exec $*
fi
