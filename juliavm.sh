#!/bin/bash

export JULIAVM_WORK_DIR="$HOME/.julia/juliavm"
mkdir -p $JULIAVM_WORK_DIR

juliavm_ls_remote() {
  git ls-remote -t "https://github.com/JuliaLang/julia" | cut -d '/' -f 3 | cut -c 1 --complement | cut -d '^' -f 1
}

juliavm_install(){
  major=${1:0:3}
  file="julia-$1-osx10.7+.dmg"
  url="https://s3.amazonaws.com/julialang/bin/osx/x64/$major/$file"
  dists_dir="$JULIAVM_WORK_DIR/dists/$1"
  if ! [ -d $dists_dir ]; then
    mkdir -p "$dists_dir"
    cd "$dists_dir"
    wget "$url"
    hdiutil attach $file
    cp -r "/Volumes/Julia-$1/Julia-$major.app/Contents/Resources/julia/"* .
    hdiutil detach "/Volumes/Julia-$1"
    rm $file
    echo "Julia "$1" installed!"
  fi
  ln -sf "$JULIAVM_WORK_DIR/dists/$1/bin/julia" "/usr/local/bin/julia"
}

if [[ "$1" == 'ls' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'ls-local' ]]; then
  ls -1 "$JULIAVM_WORK_DIR/dists"
elif [[ "$1" == 'use' ]]; then
  juliavm_install "$2"
else
  echo "  Available commands are:"
  echo "  use x.y.z         install x.y.x version [ARCHITECTURE]"
  echo "  ls                list all remote versions"
  echo "  ls-local          list all local versions"
  echo "  help              print this message"
fi
