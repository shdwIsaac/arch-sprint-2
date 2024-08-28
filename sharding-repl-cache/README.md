# mongo-sharding

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```


Проверка

docker exec -it shard1 mongosh --port 27018
use somedb;
db.helloDoc.countDocuments();
exit(); 
