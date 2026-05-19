#!/bin/sh
set -e

DATA_DIR=/data
CONFIG="$DATA_DIR/config.yaml"

mkdir -p "$DATA_DIR"

# Always write fresh config from env vars (bridgev2 format)
cat > "$CONFIG" << YAML
# Database at ROOT level (bridgev2 requirement — NOT under appservice)
database:
    type: postgres
    uri: ${DATABASE_URL}
    max_open_conns: 5
    max_idle_conns: 1

homeserver:
    address: ${MATRIX_HOMESERVER_URL}
    domain: ${MATRIX_HOMESERVER_DOMAIN}
    software: standard

appservice:
    address: ${MAUTRIX_PUBLIC_URL}
    hostname: 0.0.0.0
    port: 29319
    id: meta
    bot:
        username: metabot
        displayname: Meta Bridge Bot
        avatar: mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak
    as_token: ${MAUTRIX_AS_TOKEN}
    hs_token: ${MAUTRIX_HS_TOKEN}

network:
    mode: instagram

bridge:
    command_prefix: "!meta"
    personal_filtering_spaces: false
    federate_rooms: false
    permissions:
        "*": relay
        "${MATRIX_HOMESERVER_DOMAIN}": user
        "@admin:${MATRIX_HOMESERVER_DOMAIN}": admin
    relay:
        enabled: false

encryption:
    allow: false
    default: false
    require: false

logging:
    min_level: debug
    writers:
        - type: stdout
          format: pretty-colored
          min_level: debug
YAML
echo "[entrypoint] Config written to $CONFIG"

exec /usr/bin/mautrix-meta -c "$CONFIG" "$@"
