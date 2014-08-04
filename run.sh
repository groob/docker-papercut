#!/bin/bash
SETUP=${SETUP:-}
sed -i 's/database.type=Internal/database.type=PostgreSQL/g' server/server.properties
sed -i 's/database.driver=/database.driver=org.postgresql.Driver/g' server/server.properties
sed -i "s/database.url=/database.url=jdbc:postgresql:\/\/$DB_PORT_5432_TCP_ADDR\/papercut/g" server/server.properties
sed -i 's/database.username=/database.username=admin/g' server/server.properties
sed -i 's/database.password=/database.password=password/g' server/server.properties

if [ ! -z "$SETUP" ] ; then
  echo "initializing db"
  su papercut && server/bin/linux-x64/bin/db-tools init-db
fi
service papercut start
