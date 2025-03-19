alias upu := up-update
alias pup := proxy-up
alias pdown := proxy-down

default:
    just --list

up:
    ./manage-services.sh up -d

up-update:
    ./manage-services.sh up --pull -d

down:
    ./manage-services.sh down

proxy-up:
    cd ./tsd-proxy/
    podman-compose up --pull -d
    cd - >/dev/null

proxy-down:
    cd ./tsd-proxy/
    podman-compose down
    cd - >/dev/null
