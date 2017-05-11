#!/bin/bash

export JULIAVM_WORK_DIR="$HOME/.julia/juliavm"
mkdir -p $JULIAVM_WORK_DIR

juliavm_ls_remote() {
  git ls-remote -t "https://github.com/JuliaLang/julia" | cut -d '/' -f 3 | cut -c 1 --complement | cut -d '^' -f 1
}

juliavm_install(){
  file=$(juliavm_get_file_name "$1" "$2")
  url=$(juliavm_get_download_url "$1" "$2")
  dists_dir=$(juliavm_get_dist_dir "$1" "$2")
  if ! [ -d $dists_dir ]; then
    mkdir -p "$dists_dir"
    cd "$dists_dir"
    wget "$url"
    hdiutil attach $file
    major=${1:0:3}
    cp -r "/Volumes/Julia-$1/Julia-$major.app/Contents/Resources/julia/"* .
    hdiutil detach "/Volumes/Julia-$1"
    rm $file
    echo "Julia "$1" installed!"
  fi
  juliavm_use $1
}

juliavm_use(){
  ln -sf "$JULIAVM_WORK_DIR/dists/$1/bin/julia" "/usr/local/bin/julia"
}

juliavm_ls(){
  ls -1 "$JULIAVM_WORK_DIR/dists/"
}

juliavm_get_file_name(){
  printf 'julia-'$1'-osx10.7+.dmg'
}

juliavm_get_download_url(){
  file=$(juliavm_get_file_name $1 $2)
  major=${1:0:3}
  printf "https://s3.amazonaws.com/julialang/bin/osx/x64/$major/$file"
}

juliavm_get_dist_dir(){
  printf $JULIAVM_WORK_DIR'/dists/'$1
}

juliavm_help() {
  echo "  use x.y.z         install x.y.x version [ARCHITECTURE]"
  echo "  ls                list all remote versions"
  echo "  ls-local          list all local versions"
  echo "  help              list all commands"
}

if [[ "$1" == 'ls' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'ls-local' ]]; then
  juliavm_ls "$2"
elif [[ "$1" == 'use' ]]; then
  juliavm_install "$2"
elif [[ "$1" == *"help"* ]]; then
  echo "Commands available are: "
  juliavm_help
else
  echo "Command not found, commands available are: "
  juliavm_help
fi
