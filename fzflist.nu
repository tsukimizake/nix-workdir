export def fzflist [getter?: string] {
  if $getter == null {
    $in | to text | fzf
  } else {
    let chosen = $in | get $getter | to text | fzf
    $in | where {|x| ($x | get $getter | to text) == $chosen } | get 0
  }
}
