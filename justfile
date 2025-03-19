alias upu := up-update
alias pup := proxy-up
alias pdown := proxy-down

default:
    just --list

up:
    ./manage-services.sh up -d

up-update:
    ./manage-services.sh up --pull -d

restart:
    ./manage-services.sh restart

down:
    ./manage-services.sh down

proxy-up:
    (cd ./tsd-proxy/ && podman-compose up --pull -d)

proxy-down:
    (cd ./tsd-proxy/ && podman-compose down)

backuo:
    restic backup .
