default:
    just --list

up:
    podman compose -f ./tsd-proxy/compose.yml up --wait
    podman compose -f ./searxng/compose.yml up
