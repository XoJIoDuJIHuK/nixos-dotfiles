# Vaultwarden VPS+client setup guide

## Prerequisites

1. VPS capable of running docker
2. Any domain

## Steps

1. Create folder

```sh
mkdir vaultwarden
cd vaultwarden
```

2. Create files

```yaml
# docker-compose.yml

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      - WEBSOCKET_ENABLED=true  # Enables instant sync across devices
      - SIGNUPS_ALLOWED=true    # Set to false AFTER you create your account
      - DOMAIN=https://subdomain.example.com:8443
    volumes:
      - ./vw-data:/data

  caddy:
    image: caddy:2
    container_name: caddy
    restart: always
    ports:
      - 80:80
      - 8443:443 # or 443:443 if port 443 is not taken by other service
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    links:
      - vaultwarden

volumes:
  caddy_data:
  caddy_config:
```

```Caddyfile
# Caddyfile
subdomain.example.com:443 { # note: port 443 anyway, even if 8443 will be used for end users
    encode gzip
    reverse_proxy vaultwarden:80 {
        header_up X-Real-IP {remote_host}
    }
}
```

3. Start everything

```sh
docker compose up -d
```

4. Wait for caddy to fetch certificate from Let'sEncrypt
5. Open http://subdomain.example.com:8443, register, set env to false in docker-compose.yml, restart services, import data, connect clients, enjoy
