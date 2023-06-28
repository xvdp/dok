#!/bin/bash
# change cache paths for huggingface, torch, openai (uses ~/.cache/ by default)
# use: set_caches.sh /mnt/my/model/cache/path

cache_path=$1
# Check if the argument is provided
if [ -z "$cache_path" ]; then
  echo "Error: Cache path argument is missing."
  echo "Usage: $0 /path_to_cache"
  exit 1
fi

#
# back up .bashrc
#
bashrc_path=~/.bashrc
bashrc_backup=~/.bashrc_backup_$(date +"%Y%m%d_%H%M%S")
cp "$bashrc_path" "$bashrc_backup"


i=0
names=(XDG_CACHE_HOME TORCH_HOME TORCH_EXTENSIONS_DIR DNNLIB_CACHE_DIR HUGGINGFACE_HOME)
paths=($cache_path "${cache_path}/torch" "${cache_path}/torch_extensions" "${cache_path}/dnnlib" "${cache_path}/huggingface")
# defaults=(~/.cache/huggingface/ ~/.cache/torch/ ~/.cache)

for name in "${names[@]}"; do
  path=${paths[i]}

  existing_line="export ${name}="
  if grep -qF "$existing_line" "$bashrc_path"; then # Check if HUGGINGFACE_HOME already exists in .bashrc
    sed -i "s|$existing_line.*|$existing_line$path|" "$bashrc_path"
  else
    echo "$existing_line$path" >> "$bashrc_path"
  fi

  echo $name $path
  i=$((i + 1))
done


# Reload the .bashrc file
source "$bashrc_path"