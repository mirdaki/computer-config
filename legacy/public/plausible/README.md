# Extra Plausible Information

There was an issue where clickhouse was creating tons of logs (16GB before removal). Fortunately, there was an excellent [blog post](https://theorangeone.net/posts/calming-down-clickhouse/) talking about this exact issue and how to fix it. Those changes are now part of the clickhouse config.

To clean
```bash
docker-compose exec plausible_events_db bash
clickhouse-client -q "SELECT name FROM system.tables WHERE name LIKE '%log%';" | xargs -I{} clickhouse-client -q "TRUNCATE TABLE system.{};"
```

In addition to that, I wanted to post how I looked through the first layer of folders and report the storage used in a human readable format
```bash
sudo du -hc --max-depth=1 clickhouse/clickhouse/
```
