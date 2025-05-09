alias b := backup
alias upu := up-update
alias pup := proxy-up
alias pdown := proxy-down
alias pub := pull-update-backup
alias uu := update-all

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

pull:
    git pull

pull-update-backup: proxy-down down pull backup proxy-up up

update-all: proxy-down down pull proxy-up up
