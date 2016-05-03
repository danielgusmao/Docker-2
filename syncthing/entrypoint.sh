#!/bin/bash
export HOME=/home/user
mkdir -p /home/user/.config/syncthing/

until [ -n "$(curl --silent "http://localhost:2379/v2/keys")" ]
do
  echo "Trying: http://localhost:2379"
  sleep 1
done

curl -X PUT http://localhost:2379/v2/keys/syncthing?dir=true&prevExist=false -d ""

confd -backend etcd -node http://localhost:2379 -onetime

syncthing &

until [ -n "$(curl -H 'X-API-Key: 8EqKansuOM1TQPt3O3aJs-tDlMdlTpLF' --silent "http://localhost:8384/rest/system/status")" ]
do
  echo "Trying: http://localhost:8384"
  sleep 1
done
touch /initialized
ID=$(curl -H "X-API-Key: 8EqKansuOM1TQPt3O3aJs-tDlMdlTpLF" http://localhost:8384/rest/system/status | jq -r .myID)
curl -L -X PUT http://localhost:2379/v2/keys/syncthing/$(hostname) -d value=$ID

confd -backend etcd -node http://localhost:2379 -interval 10
