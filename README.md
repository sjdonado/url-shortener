# url-shortener
> Lightning fast, lightweight and minimal self-hosted url shortener

## Benchmark
```shell
./benchmark.sh
Semaphore initialized with 2666 slots.
Setup...
[+] Running 1/0
 ✔ Container url-shortener-app-1  Running                                                                                                                                                                                   0.0s
2024-05-20T16:39:53.818306Z   INFO - micrate: No migrations to run. current version: 20240513130054
Captured API Key: 4y2mblZDneZLcI-YywHGFA
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
Average Memory Usage: 11.00 MiB
Average Response Time: 5.28 µs
[+] Running 2/2
 ✔ Container url-shortener-app-1  Removed                                                                                                                                                                                  10.2s
 ✔ Network url-shortener_default  Removed
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
    --name url-shortener \
    -p 4000:4000 \
    -e ENV="production" \
    -e DATABASE_URL="sqlite3://./sqlite/data.db?journal_mode=wal&synchronous=normal&foreign_keys=true" \
    -e APP_URL="http://localhost:4000" \
    sjdonado/url-shortener

docker exec -it url-shortener migrate
docker exec -it url-shortener cli --create-user=Admin
```

- Dokku
```dockerfile
FROM sjdonado/url-shortener
```

```bash
dokku apps:create url-shortener

dokku domains:set url-shortener bit.donado.co 
dokku letsencrypt:enable url-shortener

dokku storage:ensure-directory url-shortener-sqlite
dokku storage:mount url-shortener /var/lib/dokku/data/storage/url-shortener-sqlite:/usr/src/app/sqlite/

dokku config:set url-shortener DATABASE_URL="sqlite3://./sqlite/data.db?journal_mode=wal&synchronous=normal&foreign_keys=true" APP_URL=https://bit.donado.co

dokku ports:add url-shortener http:80:4000
dokku ports:add url-shortener https:443:4000

dokku run url-shortener migrate
dokku run url-shortener cli --create-user=Admin
```

## Usage

**REST API**

| Endpoint | HTTP Method | Description | Payload |
|----------|-------------|-------------|---------|
| `/api/ping` | GET | Ping the API to check if it's running | - |
| `/:slug` | GET | Retrieve a link by its slug | - |
| `/api/links` | GET | Retrieve all links | - |
| `/api/links` | POST | Create a new link | `{"url": "https://example.com"}` |
| `/api/links/:id` | PUT | Update an existing link by its ID | `{"url": "https://newexample.com"}` |
| `/api/links/:id` | DELETE | Delete a link by its ID | - |

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
shards run url-shortener
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

1. Fork it (<https://github.com/sjdonado/url-shortener/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [sjdonado](https://github.com/sjdonado) - creator and maintainer
