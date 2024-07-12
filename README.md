`latest` tag is unstable (Under development!)

## Benchmark

```shell
$ ./benchmark.sh
Semaphore initialized with 2666 slots.
Setup...
[+] Running 2/2
 ✔ Network bit_default  Created                                                                              0.0s
 ✔ Container bit-app-1  Started                                                                              0.2s
2024-07-12T18:41:20.962052Z   INFO - micrate: Migrating db, current version: 0, target: 20240711224103
2024-07-12T18:41:20.965729Z   INFO - micrate: OK   20240512214223_create_links.sql
2024-07-12T18:41:20.969198Z   INFO - micrate: OK   20240512225208_add_slug_index_to_links.sql
2024-07-12T18:41:20.973136Z   INFO - micrate: OK   20240513115731_create_users.sql
2024-07-12T18:41:20.975525Z   INFO - micrate: OK   20240513130054_add_api_key_index_to_users.sql
2024-07-12T18:41:20.979195Z   INFO - micrate: OK   20240711224103_create_clicks.sql
Captured API Key: Z01Qk4M5E0xhggZUCdQAPw
Waiting for database to be ready...
Creating 1000 short links...
Created short link 100/1000
Created short link 200/1000
Created short link 300/1000
Created short link 400/1000
Created short link 500/1000
Created short link 600/1000
Created short link 700/1000
Created short link 800/1000
Created short link 900/1000
Created short link 1000/1000
Accessing each link 10 times concurrently...
****Results****
Average Memory Usage: 16.36 MiB
Average CPU Usage: 0%
Average Response Time: 12.37 µs
```

## Self-hosted

- Run via docker-compose

```bash
docker-compose up

docker-compose exec -it app migrate
docker-compose exec -it app cli --create-user=Admin
```

- Run via docker cli

```bash
docker run \
    --name bit \
    -p 4000:4000 \
    -e ENV="production" \
    -e DATABASE_URL="sqlite3://./sqlite/data.db?journal_mode=wal&synchronous=normal&foreign_keys=true" \
    -e APP_URL="http://localhost:4000" \
    sjdonado/bit

docker exec -it bit migrate
docker exec -it bit cli --create-user=Admin
```

- Dokku

```dockerfile
FROM sjdonado/bit
```

```bash
dokku apps:create bit

dokku domains:set bit bit.donado.co
dokku letsencrypt:enable bit

dokku storage:ensure-directory bit-sqlite
dokku storage:mount bit /var/lib/dokku/data/storage/bit-sqlite:/usr/src/app/sqlite/

dokku config:set bit DATABASE_URL="sqlite3://./sqlite/data.db?journal_mode=wal&synchronous=normal&foreign_keys=true" APP_URL=https://bit.donado.co

dokku ports:add bit http:80:4000
dokku ports:add bit https:443:4000

dokku run bit migrate
dokku run bit cli --create-user=Admin
```

## Usage

**REST API**

| Endpoint         | HTTP Method | Description                           | Payload                             |
| ---------------- | ----------- | ------------------------------------- | ----------------------------------- |
| `/api/ping`      | GET         | Ping the API to check if it's running | -                                   |
| `/:slug`         | GET         | Retrieve a link by its slug           | -                                   |
| `/api/links`     | GET         | Retrieve all links                    | -                                   |
| `/api/links/:id` | GET         | Retrieve a link by its ID             | -                                   |
| `/api/links`     | POST        | Create a new link                     | `{"url": "https://example.com"}`    |
| `/api/links/:id` | PUT         | Update an existing link by its ID     | `{"url": "https://newexample.com"}` |
| `/api/links/:id` | DELETE      | Delete a link by its ID               | -                                   |

**CLI**

```
Usage: ./cli [options]
Options:
  --create-user=NAME  Create a new user with the given name
  --list-users        List all users
  --delete-user=USER_ID Delete a user by ID
```

## Development

**Installation**

```bash
brew tap amberframework/micrate
brew install micrate
```

```bash
shards run migrate
shards run bit
```

**Generate the `X-Api-Key`**

```bash
shards run cli -- --create-user=Admin
```

## Run tests

```bash
ENV=test crystal spec
```

## Contributing

1. Fork it (<https://github.com/sjdonado/bit/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [sjdonado](https://github.com/sjdonado) - creator and maintainer
