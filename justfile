default:
    just --list

up:
    podman compose -f ./tsd-proxy/compose.yml up 
    podman compose -f ./searxng/compose.yml up
