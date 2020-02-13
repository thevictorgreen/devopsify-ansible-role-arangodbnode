#!/bin/bash

# LOG OUTPUT TO A FILE
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/.adb_automate/log.out 2>&1

if [[ ! -f "/root/.adb_automate/init.cfg" ]]
then
  # GENERATE SELF SIGNED CERTIFICATES FOR NGINX REVERSE PROXY
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/arangodb.key -out /etc/nginx/arangodb.crt -config /etc/nginx/req.conf
  # GENERATE STRONG DIFFIEHELMAN PARAMS
  openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
  # RESTART nginx
  systemctl restart nginx
  # CHECK NGINX STATUS
  systemctl status nginx
  # RESTART ARANGODB
  systemctl restart arangodb3
  # CHECK ARANGODB STATUS
  systemctl status arangodb3
  # SLEEP FOR 60 SECONDS TO ALLOW ARANGODB SERVICE TIME TO COME UP
  sleep 60
  # ADD THE IP ADDRESS OF THE ARANGODB MASTER SERVER TO replication.js
  sed -i s/YYYYY/$(cat /tmp/adbmaster_ip)/g /root/.adb_automate/replication.js
  # CONNECT TO THE MASTER SERVER
  arangosh --server.endpoint=tcp://$(hostname -i|cut -d' ' -f1):8529 --server.username root --server.password g0th@m --javascript.execute /root/.adb_automate/replication.js
  # PREVENT THE SCRIPT FROM RUNNING RUNNING AGAIN
  touch /root/.adb_automate/init.cfg
fi
