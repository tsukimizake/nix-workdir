#!/usr/bin/env nu

def fzflist [getter?: string] {
  if $getter == null {
    $in | to text | fzf
  } else {
    let chosen = $in | get $getter | to text | fzf
    $in | where {|x| ($x | get $getter | to text) == $chosen } | get 0
  }
}

def main [query: string] {
  let choice = (
    nix search --json nixpkgs $query
    | from json
    | transpose
    | each { {name: $in.column0, desc: $in.column1.description, pname: $in.column1.pname, version: $in.column1.version} }
    | fzflist name
  )

  nix edit $"nixpkgs#($choice.pname)"
}
