export module g {
def master_or_main [] {
  if (git show-ref | parse "{hash} {name}" | find "refs/heads/master" | is-empty) {
    return "main"
  } else {
    return "master"
  }
}
export def fetch [] { git fetch --all --prune; git switch (master_or_main); git pull; git switch -}

export def reb [] { 
  fetch; git rebase (master_or_main) 
}

export def cre [name : string, trelloid?: string] {
  fetch
  if trelloid != null {
    git switch -c $"($name).($trelloid)" origin/(master_or_main)
  } else {
    git switch -c $"($name).(trello_current_sprint)" origin/(master_or_main)
  }
}

export def diff [] { ^git diff (master_or_main) }

export def del [branch_name : string@gdel_completion] {
  git branch -D $branch_name
}

def gdel_completion [] {
  git branch | lines | each { str substring 2.. | str trim }
}

export def switch [branch_name : string@gswitch_completion] {
  git switch $branch_name
}

def gswitch_completion [] {
  git branch | lines | each { str substring 2.. | str trim } | where { |s| not ($s | str starts-with "_") }
}


export def finish [] {
  let prev_branch = (git rev-parse --abbrev-ref HEAD)
  git switch (master_or_main)
  git branch -D $prev_branch
}

export def obsolete [] {
  let branch_name = (git rev-parse --abbrev-ref HEAD)
  git branch -m $"_($branch_name)"
}

export def cresame [name : string] {
  let trelloid = git branch --show-current 
                  | parse -r '.*\.(?P<id>.*)' 
                  | get id 
                  | first
  cre $name $trelloid
}
export def chore_pr_with_diff [pr_title: string, pr_body: string, trello_id?: string] {
  let before_branch = git symbolic-ref --short HEAD | str trim
  if $trello_id == null {
    cresame "chore_pr_branch"
  } else {
    cre "chore_pr_branch" $trello_id
  }
  let chore_branch = git branch --show-current | str trim
  git add .
  git commit -m $pr_title
  git push -u origin HEAD
  gh pr create --title $pr_title --body $pr_body
  git switch $before_branch
  git branch -d $chore_branch
}

export def update_snapshots_pr [] {
  ^just e2e_update_snapshots
  git add .
  git commit -m "update_snapshots"
  chore_pr_head_commit "chore(e2e): update snapshots" "update snapshots" (trello_current_sprint)
}

export def review [branch_name: string] {
  fetch
  let hash = git rev-parse  $"origin/($branch_name)" | str trim
  git switch --detach $hash
}

}
