#!/bin/bash

export JULIAVM_WORK_DIR="$HOME/.julia/juliavm"
mkdir -p $JULIAVM_WORK_DIR

juliavm_ls_remote() {
  git ls-remote -t "https://github.com/JuliaLang/julia" | cut -d '/' -f 3 | cut -c 1 --complement | cut -d '^' -f 1
}

juliavm_latest() {
  curl -s --head https://github.com/Julialang/julia/releases/latest | egrep -o 'v\d+\.\d+\.\d+' | cut -c 1 --complement
}

juliavm_install(){
  major=${1:0:3}
  file="julia-$1-mac64.dmg"
  url="https://julialang-s3.julialang.org/bin/mac/x64/$major/$file"
  dists_dir="$JULIAVM_WORK_DIR/$1"
  if ! [ -d $dists_dir ]; then
    mkdir -p "$dists_dir"
    cd "$dists_dir"
    if wget "$url"; then
      hdiutil attach $file
      cp -r "/Volumes/Julia-$1/Julia-$major.app/Contents/Resources/julia/"* .
      hdiutil detach "/Volumes/Julia-$1"
      rm $file
      echo "Julia "$1" installed!"
    else
      rm -r "$dists_dir"
    fi
  fi
  ln -sf "$JULIAVM_WORK_DIR/$1/bin/julia" "/usr/local/bin/julia"
}

juliavm_rm(){
  rm -r "$JULIAVM_WORK_DIR/$1"
}

juliavm_nightly(){
  nightly="$JULIAVM_WORK_DIR/nightly"
  today=$(date -d $(date +%D) +%s)
  if [ ! -d "$nightly" ] || [ $today -ge $(date -r "$nightly" +%s) ];
  then
    rm -rf "$nightly"
    mkdir -p "$nightly"
    cd "$nightly"
    wget "https://julialangnightlies-s3.julialang.org/bin/mac/x64/julia-latest-mac64.dmg"
    hdiutil attach 'julia-latest-mac64.dmg'
    cp -r /Volumes/Julia-*-DEV-*/Julia-*.app/Contents/Resources/julia/* .
    hdiutil detach /Volumes/Julia-*-DEV-*
    rm 'julia-latest-mac64.dmg'
    echo "$("$nightly/bin/julia" -v) installed"
  fi
  echo "$("$nightly/bin/julia" -v) installed"
  ln -sf "$nightly/bin/julia" "/usr/local/bin/julia"
}

if [[ "$1" == 'ls' ]]; then
  juliavm_ls_remote
elif [[ "$1" == 'ls-local' ]]; then
  ls -1 "$JULIAVM_WORK_DIR"
elif [[ "$1" == 'use' ]]; then
  juliavm_install "$2"
elif [[ "$1" == 'update' ]]; then
  juliavm_install $(juliavm_latest)
elif [[ "$1" == 'latest' ]]; then
  juliavm_latest
elif [[ "$1" == 'nightly' ]]; then
  juliavm_nightly
elif [[ "$1" == 'rm' ]]; then
  juliavm_rm "$2"
else
  echo
  echo "  Available commands are:"
  echo
  echo "  use x.y.z    switch-to/install x.y.x version"
  echo "  ls           list all remote versions"
  echo "  ls-local     list all local versions"
  echo "  latest       print the latest available version"
  echo "  update       use the latest available version"
  echo "  nightly      install and/or switch to the latest nightly build"
  echo "  rm           uninstall a version of julia"
  echo "  help         print this message"
  echo
fi
