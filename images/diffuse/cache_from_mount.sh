
#!/bin/bash
# query mounted volumes, send to set_caches.sh to write ()_CACHE(s) into .bashrc
# -> HUGGINGFACE_HOME TORCH_HOME XDG_CACHE_HOME

## from outside the container these can be queried as 
# docker inspect --format '{{range .Mounts}}{{.Source}}:{{.Destination}};{{end}}' containerid
## or 
# docker inspect -f '{{ .Mounts }}' containerid

## wihin the container it may vary,  in ubuntu 22.04 & docker 24.0.2
# mounts=($(cat /proc/mounts | grep /dev/sd | awk '{print $2}' | cut -d' ' -f1))

# WIP. on exceuting code, ensure that .bashrc has caches set and is loaded.
# in python check that os.enviro[$cache] points to correct store

cache_mount_name=weights

mounts=$(cat /proc/mounts | grep /dev/sd | awk '{print $2}' | grep $cache_mount_name)

if [ ! -z ${#mounts[@]} ]; then
    ./set_caches.sh ${mounts[0]}
else
    echo no mounts were found under /dev/sd, run set_caches.sh <mounted volume manually
fi
