alias b := backup
alias upu := up-update
alias pup := proxy-up
alias pdown := proxy-down
alias pub := pull-update-backup

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

backup:
    ./backup.sh

pull-update-backup:
    pdown
    down
    backup
    git pull
    pup
    up
