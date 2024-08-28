#!/bin/bash

###
# Инициализируем бд
###
docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate({_id : "config_server", configsvr: true, members: [{ _id : 0, host : "configSrv:27017" }]})
exit()
EOF

docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate({_id : "shard1", members: [{ _id : 0, host : "shard1:27018" }]})
exit()
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.initiate({_id : "shard2", members: [{ _id : 1, host : "shard2:27019" }]})
exit()
EOF

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard("shard1/shard1:27018")
sh.addShard("shard2/shard2:27019")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" })
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
exit()
EOF

docker compose exec -T shard1 mongosh --port 27018 <<EOF
use somedb
db.helloDoc.countDocuments()
exit();
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF
use somedb
db.helloDoc.countDocuments()
exit()
EOF

docker compose exec -T mongodbrpl1 mongosh --port 27021 <<EOF
rs.initiate({_id: "rs0", members: [
{_id: 0, host: "mongodbrpl1:27021"},
{_id: 1, host: "mongodbrpl2:27022"},
]})
exit()
EOF
