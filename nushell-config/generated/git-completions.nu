
def "nu-complete git records" []: list<string> -> list<record> {
    each {|line| let parts = $line | split row "\t"; {value: $parts.0, description: ($parts.1? | default "" | str trim)} }
    | where value != ""
}

def "nu-complete git ls-files" [] {
    try { ^git ls-files | complete | get stdout | lines | nu-complete git records } catch { [] }
}

def "nu-complete git complete stashes" [] {
    try { ^git stash list '--format=%gd:%gs' | complete | get stdout | lines | str replace ':' "	" | nu-complete git records } catch { [] }
}

def "nu-complete git remotes" [] {
    try { ^git config --get-regexp '^remote\.[^[:space:]]+\.url$' | complete | get stdout | lines | where $it =~ '^remote\.(\S+)\.url (.*)' | str replace -r '^remote\.(\S+)\.url (.*)' "$1\t$2" | nu-complete git records } catch { [] }
}

def "nu-complete git commands" [] {
    $env.PATH | where ($it | path exists) | each {|dir| ls $dir | where type != dir | get name | path basename }
        | flatten | uniq | each { {value: $in} }
}

def "nu-complete git local branches" [] {
    try { ^git for-each-ref '--format=%(refname:strip=2)%09Local Branch' --sort=-committerdate refs/heads/ | complete | get stdout | lines | nu-complete git records } catch { [] }
}

def "nu-complete git commits" [] {
    try { ^git log --no-show-signature "--pretty=tformat:%H\t%<(64,trunc)%s" --all --max-count=1000 | complete | get stdout | lines | str replace -r '^([0-9a-f]{10})[0-9a-f]*\t(.*)' "$1\t$2" | nu-complete git records } catch { [] }
}

def "nu-complete git branches" [] {
    [
        (try { ^git for-each-ref '--format=%(refname:strip=2)%09Local Branch' --sort=-committerdate refs/heads/ | complete | get stdout | lines | nu-complete git records } catch { [] })
        (try { ^git for-each-ref '--format=%(refname:strip=2)%09Remote Branch' refs/remotes/ | complete | get stdout | lines | nu-complete git records } catch { [] })
    ] | flatten | uniq-by value
}

def "nu-complete git reflog" [] {
    try { ^git reflog --no-decorate | complete | get stdout | lines | str replace -r '[0-9a-f]* (.+@\{[0-9]+\}): (.*)$' "$1\t$2" | nu-complete git records } catch { [] }
}

def "nu-complete git unique remote branches" [] {
    try { ^git for-each-ref '--format=%(refname:strip=3)' --sort=refname:strip=3 refs/remotes/ | ^uniq -u | complete | get stdout | lines | nu-complete git records } catch { [] }
}

def "nu-complete git switch args" [] {
    [...(nu-complete git unique remote branches), ...(nu-complete git branches)] | uniq-by value
}

def "nu-complete git complete worktrees" [] {
    try { ^git worktree list --porcelain | complete | get stdout | lines | where $it =~ '^worktree\s*' | str replace -r '^worktree\s*' "" | nu-complete git records } catch { [] }
}

def "nu-complete git submodules" [] {
    try { ^git submodule | complete | get stdout | lines | str replace -r '^.[^ ]+ ([^ ]+).*$' "$1" | nu-complete git records } catch { [] }
}

def "nu-complete git tags" [] {
    try { ^git tag --sort=-creatordate | complete | get stdout | lines | nu-complete git records } catch { [] }
}

@complete external
export extern "git" [
    --help(-h)
    --version(-v)
    -C: directory
    -c: string
    --config-env: string
    --exec-path: directory
    --html-path
    --man-path
    --info-path
    --paginate(-p)
    --no-pager(-P)
    --git-dir: string
    --work-tree: string
    --namespace
    --bare
    --no-replace-objects
    --literal-pathspecs
    --glob-pathspecs
    --noglob-pathspecs
    --icase-pathspecs
    --no-optional-locks
    --list-cmds: string@[builtins]
]

@complete external
export extern "git log" [
    --pretty
    --dst-prefix
    --inter-hunk-context
    --ita-invisible-in-index
    --line-prefix
    --no-prefix
    --pickaxe-all
    --pickaxe-regex
    --relative
    --src-prefix
    --text(-a)
    --break-rewrites(-B)
    --find-copies(-C)
    --irreversible-delete(-D)
    -G
    --find-renames(-M)
    -R
    -S
    -O: string
    -l: string
    --diff-algorithm: string
    --dirstat: string
    --ignore-submodules: string
    --submodule: string
    --ws-error-highlight: string
    --follow
    --no-decorate
    --decorate
    --source
    --use-mailmap
    --full-diff
    --log-size
    -L: string
    --max-count(-n): string
    --skip: string
    --since: string
    --since-as-filter: string
    --after: string
    --until: string
    --before: string
    --author: string
    --committer: string
    --grep-reflog: string
    --grep: string
    --all-match
    --invert-grep
    --regexp-ignore-case(-i)
    --basic-regexp
    --extended-regexp(-E)
    --fixed-strings(-F)
    --perl-regexp
    --remove-empty
    --merges
    --no-merges
    --min-parents: string
    --max-parents: string
    --no-min-parents
    --no-max-parents
    --first-parent
    --not
    --all
    --branches
    --tags
    --remotes
    --glob: string
    --exclude: string
    --reflog
    --ignore-missing
    --bisect
    --stdin
    --cherry-mark
    --cherry-pick
    --left-only
    --right-only
    --cherry
    --walk-reflogs(-g)
    --merge
    --boundary
    --simplify-by-decoration
    --full-history
    --dense
    --sparse
    --simplify-merges
    --ancestry-path
    --date-order
    --author-date-order
    --topo-order
    --reverse
    --no-walk
    --do-walk
    --format: string
    --abbrev-commit
    --no-abbrev-commit
    --oneline
    --encoding: string
    --expand-tabs
    --no-expand-tabs
    --notes
    --no-notes
    --show-notes
    --standard-notes
    --no-standard-notes
    --show-signature
    --relative-date
    --date: string
    --parents
    --children
    --left-right
    --graph
    --show-linear-break
    -c
    --cc
    -m
    -r
    -t
    --patch(-p)
    -u
    --no-patch(-s)
    --unified(-U): string
    --raw
    --patch-with-raw
    --indent-heuristic
    --no-indent-heuristic
    --compaction-heuristic
    --no-compaction-heuristic
    --minimal
    --patience
    --histogram
    --stat: string
    --numstat
    --shortstat
    --summary
    --patch-with-stat
    -z
    --name-only
    --name-status
    --color
    --no-color
    --word-diff
    --color-words
    --no-renames
    --check
    --full-index
    --binary
    --abbrev
    --diff-filter: string
    --find-copies-harder
    --ignore-space-at-eol
    --ignore-space-change(-b)
    --ignore-all-space(-w)
    --ignore-blank-lines
    --function-context(-W)
    --ext-diff
    --no-ext-diff
    --no-textconv
    --textconv
    ...args: external_arg@"nu-complete git ls-files"
]

@complete external
export extern "git show" [
    --pretty
    --abbrev
    --binary
    --check
    --color
    --color-moved: string@[no default plain blocks zebra dimmed-zebra]
    --color-moved-ws: string@[no ignore-space-at-eol ignore-space-change ignore-all-space allow-indentation-change]
    --color-words
    --compact-summary
    --dst-prefix
    --ext-diff
    --find-copies-harder
    --find-object
    --full-index
    --histogram
    --ignore-blank-lines
    --ignore-cr-at-eol
    --ignore-space-at-eol
    --indent-heuristic
    --inter-hunk-context
    --ita-invisible-in-index
    --line-prefix
    --minimal
    --name-only
    --name-status
    --no-color
    --no-ext-diff
    --no-indent-heuristic
    --no-prefix
    --no-renames
    --no-textconv
    --numstat
    --patch-with-raw
    --patch-with-stat
    --patience
    --pickaxe-all
    --pickaxe-regex
    --relative
    --shortstat
    --src-prefix
    --stat
    --summary
    --textconv
    --word-diff
    --word-diff-regex
    --text(-a)
    --break-rewrites(-B)
    --ignore-space-change(-b)
    --find-copies(-C)
    --irreversible-delete(-D)
    -G
    --find-renames(-M)
    -R
    -S
    --function-context(-W)
    --ignore-all-space(-w)
    -z
    -O: string
    --anchored
    -l: string
    --diff-filter: string
    --diff-algorithm: string
    --dirstat: string
    --ignore-submodules: string
    --submodule: string
    --ws-error-highlight: string
    --format
    --abbrev-commit
    --no-abbrev-commit
    --oneline
    --encoding
    --expand-tabs
    --no-expand-tabs
    --notes
    --no-notes
    --no-patch(-s)
    --show-signature
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git diff-tree" [
    --pretty
]

@complete external
export extern "git rev-list" [
    --pretty
    --max-count(-n): string
    --skip: string
    --since: string
    --since-as-filter: string
    --after: string
    --until: string
    --before: string
    --author: string
    --committer: string
    --grep-reflog: string
    --grep: string
    --all-match
    --invert-grep
    --regexp-ignore-case(-i)
    --basic-regexp
    --extended-regexp(-E)
    --fixed-strings(-F)
    --perl-regexp
    --remove-empty
    --merges
    --no-merges
    --min-parents: string
    --max-parents: string
    --no-min-parents
    --no-max-parents
    --first-parent
    --not
    --all
    --branches
    --tags
    --remotes
    --glob: string
    --exclude: string
    --reflog
    --ignore-missing
    --bisect
    --stdin
    --cherry-mark
    --cherry-pick
    --filter: string
]

@complete external
export extern "git diff" [
    --abbrev
    --binary
    --check
    --color
    --color-moved: string@[no default plain blocks zebra dimmed-zebra]
    --color-moved-ws: string@[no ignore-space-at-eol ignore-space-change ignore-all-space allow-indentation-change]
    --color-words
    --compact-summary
    --dst-prefix
    --ext-diff
    --find-copies-harder
    --find-object
    --full-index
    --histogram
    --ignore-blank-lines
    --ignore-cr-at-eol
    --ignore-space-at-eol
    --indent-heuristic
    --inter-hunk-context
    --ita-invisible-in-index
    --line-prefix
    --minimal
    --name-only
    --name-status
    --no-color
    --no-ext-diff
    --no-indent-heuristic
    --no-prefix
    --no-renames
    --no-textconv
    --numstat
    --patch-with-raw
    --patch-with-stat
    --patience
    --pickaxe-all
    --pickaxe-regex
    --relative
    --shortstat
    --src-prefix
    --stat
    --summary
    --textconv
    --word-diff
    --word-diff-regex
    --text(-a)
    --break-rewrites(-B)
    --ignore-space-change(-b)
    --find-copies(-C)
    --irreversible-delete(-D)
    -G
    --find-renames(-M)
    -R
    -S
    --function-context(-W)
    --ignore-all-space(-w)
    -z
    -O: string
    --anchored
    -l: string
    --diff-filter: string
    --diff-algorithm: string
    --dirstat: string
    --ignore-submodules: string
    --submodule: string
    --ws-error-highlight: string
    --cached
    --staged
    --no-index
    --exit-code
    --quiet
    --base(-1)
    --ours(-2)
    --theirs(-3)
    -0
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git range-diff" [
    --abbrev
    --binary
    --check
    --color
    --color-moved: string@[no default plain blocks zebra dimmed-zebra]
    --color-moved-ws: string@[no ignore-space-at-eol ignore-space-change ignore-all-space allow-indentation-change]
    --color-words
    --compact-summary
    --dst-prefix
    --ext-diff
    --find-copies-harder
    --find-object
    --full-index
    --histogram
    --ignore-blank-lines
    --ignore-cr-at-eol
    --ignore-space-at-eol
    --indent-heuristic
    --inter-hunk-context
    --ita-invisible-in-index
    --line-prefix
    --minimal
    --name-only
    --name-status
    --no-color
    --no-ext-diff
    --no-indent-heuristic
    --no-prefix
    --no-renames
    --no-textconv
    --numstat
    --patch-with-raw
    --patch-with-stat
    --patience
    --pickaxe-all
    --pickaxe-regex
    --relative
    --shortstat
    --src-prefix
    --stat
    --summary
    --textconv
    --word-diff
    --word-diff-regex
    --text(-a)
    --break-rewrites(-B)
    --ignore-space-change(-b)
    --find-copies(-C)
    --irreversible-delete(-D)
    -G
    --find-renames(-M)
    -R
    -S
    --function-context(-W)
    --ignore-all-space(-w)
    -z
    -O: string
    --anchored
    -l: string
    --diff-filter: string
    --diff-algorithm: string
    --dirstat: string
    --ignore-submodules: string
    --submodule: string
    --ws-error-highlight: string
    --creation-factor
    --no-dual-color
]

@complete external
export extern "git apply" [
    --stat
    --numstat
    --summary
    --check
    --index
    --cached
    --intent-to-add
    --3way(-3)
    --build-fake-ancestor
    --reverse(-R)
    --reject
    -p: string
    -C: string
    --unidiff-zero
    --apply
    --no-add
    --allow-binary-replacement
    --binary
    --exclude
    --include
    --ignore-space-change
    --ignore-whitespace
    --whitespace: string@[nowarn warn fix error error-all]
    --inaccurate-eof
    --verbose(-v)
    --recount
    --directory
    --unsafe-paths
]

@complete external
export extern "git fetch" [
    --unshallow
    --set-upstream
    --recurse-submodules: string@[yes on-demand no]
    --no-recurse-submodules
    --quiet(-q)
    --verbose(-v)
    --append(-a)
    --upload-pack
    --force(-f)
    --prune(-p)
    --all
    --atomic
    --multiple(-m)
    --tags(-t)
    --prune-tags(-P)
    --prefetch
    --jobs(-j)
    -n
    --dry-run
    --depth
    --with-fetch-head
    --update-shallow
    --keep(-k)
    --update-head-ok(-u)
    --progress
    --deepen
    --shallow-since
    --shallow-exclude
    --refetch
    --negotiate-only
    --filter: string
    --ipv4(-4)
    --ipv6(-6)
    --refmap: string
    --write-fetch-head
    --no-write-fetch-head
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git pull" [
    --unshallow
    --set-upstream
    --recurse-submodules: string@[yes on-demand no]
    --no-recurse-submodules
    --quiet(-q)
    --verbose(-v)
    --all
    --append(-a)
    --force(-f)
    --keep(-k)
    --no-tags
    --prune(-p)
    --progress
    --commit
    --no-commit
    --edit(-e)
    --no-edit
    --ff
    --no-ff
    --ff-only
    --gpg-sign(-S)
    --log
    --no-log
    --signoff
    --no-signoff
    --stat
    --no-stat(-n)
    --squash
    --no-squash
    --strategy(-s): string
    --strategy-option(-X): string
    --verify-signatures
    --no-verify-signatures
    --allow-unrelated-histories
    --rebase(-r)
    --no-rebase
    --autostash
    --no-autostash
    --verify
    --no-verify
    --upload-pack: string
    --depth: string
    --deepen: string
    --shallow-since: string
    --shallow-exclude: string
    --update-shallow
    --jobs(-j): string
    --ipv4(-4)
    --ipv6(-6)
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git filter-branch" [
    --env-filter
    --tree-filter
    --index-filter
    --parent-filter
    --msg-filter
    --commit-filter
    --tag-name-filter
    --subdirectory-filter
    --prune-empty
    --original
    -d: string
    --force(-f)
]

@complete external
export extern "git remote" [
    --verbose(-v)
]

@complete external
export extern "git remote add" [
    -f
    --tags
    --no-tags
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote rm" [
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote remove" [
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote show" [
    -n
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote prune" [
    --dry-run
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote update" [
    --prune
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote rename" [
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote set-head" [
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote set-url" [
    --push
    --add
    --delete
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote set-branches" [
    --add
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git remote get-url" [
    --push
    --all
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git show-branch" [
    --remotes(-r)
    --all(-a)
    --current
    --topo-order
    --date-order
    --sparse
    --no-name
    --sha1-name
    --no-color
    --merge-base
    --independent
    --topics
    --more: string
    --list
    --color: string@[always never auto]
]

@complete external
export extern "git add" [
    --dry-run(-n)
    --verbose(-v)
    --force(-f)
    --interactive(-i)
    --patch(-p)
    --edit(-e)
    --update(-u)
    --all(-A)
    --intent-to-add(-N)
    --refresh
    --chmod: string@['-x' '+x']
    --ignore-errors
    --ignore-missing
]

@complete external
export extern "git am" [
    --signoff(-s)
    --keep-non-patch
    --no-keep-cr
    --scissors(-c)
    --no-scissors
    --quoted-cr: string@[nowarn warn strip]
    --no-messageid
    --quiet(-q)
    --no-utf8
    --3way(-3)
    --no-3way
    --rerere-autoupdate
    --ignore-space-change
    --directory
    --exclude
    --include
    --reject
    --patch-format: string@[mbox mboxrd stgit stgit-series hg]
    --interactive(-i)
    --committer-date-is-author-date
    --ignore-date
    --skip
    --gpg-sign(-S): string
    --no-gpg-sign
    --no-verify(-n)
    --resolved(-r)
    --continue
    --resolvemsg: string
    --abort
    --quit
    --show-current-patch
    -p: string
    -C: string
    --ignore-whitespace
    --whitespace: string@[nowarn warn fix error error-all]
    -k
    -u
    --message-id(-m)
    --keep-cr
]

@complete external
export extern "git checkout" [
    -b
    -B
    --track(-t)
    --theirs
    --ours
    --recurse-submodules
    --no-recurse-submodules
    --progress
    --no-progress
    --force(-f)
    --quiet(-q)
    --detach
    --guess
    --no-guess
    --overlay
    --no-overlay
    --pathspec-from-file
    --pathspec-file-nul
    --ignore-skip-worktree-bits
]

@complete external
export extern "git sparse-checkout" []

@complete external
export extern "git sparse-checkout set" [
    --stdin
    --no-cone
    --sparse-index
    --no-sparse-index
]

@complete external
export extern "git sparse-checkout list" []

@complete external
export extern "git sparse-checkout add" [
    --stdin
]

@complete external
export extern "git sparse-checkout reapply" [
    --no-cone
    --sparse-index
    --no-sparse-index
]

@complete external
export extern "git sparse-checkout disable" []

@complete external
export extern "git sparse-checkout check-rules" []

@complete external
export extern "git archive" [
    --list(-l)
    --verbose(-v)
    --worktree-attributes
    --format: string@[tar zip tar.gz tgz]
    --output(-o)
    --prefix: string
    --add-file
    --remote: string
    --exec: string
]

@complete external
export extern "git bisect" []

@complete external
export extern "git bisect start" [
    --term-new: string
    --term-bad: string
    --term-old: string
    --term-good: string
    --no-checkout
    --first-parent
]

@complete external
export extern "git bisect bad" []

@complete external
export extern "git bisect new" []

@complete external
export extern "git bisect good" []

@complete external
export extern "git bisect old" []

@complete external
export extern "git bisect terms" []

@complete external
export extern "git bisect skip" []

@complete external
export extern "git bisect reset" []

@complete external
export extern "git bisect replay" []

@complete external
export extern "git bisect run" [
    ...args: external_arg@"nu-complete git commands"
]

@complete external
export extern "git branch" [
    --delete(-d): string@"nu-complete git local branches"
    -D: string@"nu-complete git local branches"
    --force(-f)
    --move(-m)
    -M
    --copy(-c)
    -C
    --all(-a)
    --remotes(-r)
    --track(-t)
    --no-track
    --set-upstream-to
    --merged
    --no-merged
    --unset-upstream
    --edit-description
    --contains: string@"nu-complete git commits"
    --no-contains: string@"nu-complete git commits"
    --sort
    ...args: external_arg@"nu-complete git branches"
]

@complete external
export extern "git bundle" []

@complete external
export extern "git bundle create" [
    --quiet(-q)
    --progress
    --all-progress
    --all-progress-implied
    --version: string
    ...args: external_arg@['--all']
]

@complete external
export extern "git bundle verify" [
    --quiet(-q)
]

@complete external
export extern "git bundle unbundle" [
    --progress
]

@complete external
export extern "git cherry" [
    -v
]

@complete external
export extern "git cherry-pick" [
    --edit(-e)
    -x
    --no-commit(-n)
    --signoff(-s)
    --ff
    --continue
    --abort
    --skip
]

@complete external
export extern "git clone" [
    --no-hardlinks
    --quiet(-q)
    --verbose(-v)
    --no-checkout(-n)
    --bare
    --mirror
    --origin(-o)
    --branch(-b)
    --depth
    --recursive
    --filter: string
    --single-branch
    --no-single-branch
    --local(-l)
    --no-local
    --shared(-s)
    --dissociate
    --progress
    --server-option
    --no-reject-shallow
    --reject-shallow
    --sparse
    --also-filter-submodules
    --revision: string
    --upload-pack(-u): string
    --template: string
    --config(-c): string
    --shallow-since: string
    --shallow-exclude: string
    --no-tags
    --tags
    --recurse-submodules: string
    --shallow-submodules
    --no-shallow-submodules
    --remote-submodules
    --no-remote-submodules
    --separate-git-dir: string
    --ref-format
    --jobs(-j): string
    --bundle-uri: string
]

@complete external
export extern "git commit" [
    --amend
    --all(-a)
    --patch(-p)
    --fixup
    --squash
    --reset-author
    --author: string
    --cleanup: string
    --date: string
    --message(-m): string
    --no-edit
    --no-gpg-sign
    --no-verify(-n)
    --allow-empty
    --allow-empty-message
    --signoff(-s)
    --no-signoff
    --reuse-message(-C)
    --reedit-message(-c)
    --edit(-e)
    --quiet(-q)
    --dry-run
    --short
    --porcelain
    --long
    --null(-z)
    --status
    --no-status
    --include(-i)
    --only(-o)
    --trailer
    --template(-t)
    --pathspec-from-file
    --pathspec-file-nul
]

@complete external
export extern "git count-objects" [
    --verbose(-v)
    --human-readable(-H)
]

@complete external
export extern "git daemon" [
    --strict-paths
    --base-path
    --base-path-relaxed
    --interpolated-path
    --export-all
    --inetd
    --listen: string
    --port: string
    --init-timeout: string
    --timeout: string
    --max-connections: string
    --syslog
    --log-destination: string@[stderr syslog none]
    --user-path: string
    --verbose
    --reuseaddr
    --detach
    --user: string
    --group: string
    --enable: string@[upload-pack upload-archive receive-pack]
    --disable: string@[upload-pack upload-archive receive-pack]
    --allow-override: string@[upload-pack upload-archive receive-pack]
    --forbid-override: string@[upload-pack upload-archive receive-pack]
    --informative-errors
    --no-informative-errors
    --access-hook: string
]

@complete external
export extern "git describe" [
    --dirty
    --broken
    --all
    --tags
    --contains
    --abbrev
    --candidates
    --exact-match
    --debug
    --long
    --match
    --exclude
    --always
    --first-parent
]

@complete external
export extern "git difftool" [
    --cached
    --gui(-g)
    --dir-diff(-d)
    --prompt
    --no-prompt(-y)
    --symlinks
    --tool(-t)
    --tool-help
    --trust-exit-code
    --extcmd(-x)
    --no-gui
    --no-symlinks
    --no-trust-exit-code
]

@complete external
export extern "git gc" [
    --aggressive
    --auto
    --prune
    --no-prune
    --quiet
    --force
    --keep-largest-pack
]

@complete external
export extern "git grep" [
    --cached
    --no-index
    --untracked
    --no-exclude-standard
    --exclude-standard
    --recurse-submodules
    --text(-a)
    --textconv
    --no-textconv
    --ignore-case(-i)
    -I
    --recursive(-r)
    --no-recursive
    --word-regexp(-w)
    --invert-match(-v)
    --full-name
    --extended-regexp(-E)
    --basic-regexp(-G)
    --perl-regexp(-P)
    --fixed-strings(-F)
    --line-number(-n)
    --column
    --files-with-matches(-l)
    --files-without-match(-L)
    --null(-z)
    --only-matching(-o)
    --count(-c)
    --no-color
    --break
    --heading
    --show-function(-p)
    --function-context(-W)
    -e
    --and
    --or
    --not
    --all-match
    --quiet(-q)
    --max-depth: string
    -h
    -H
    --open-files-in-pager(-O): string
    --context(-C): string
    --after-context(-A): string
    --before-context(-B): string
    --threads: string
]

@complete external
export extern "git history" []

@complete external
export extern "git history drop" [
    --dry-run
    --update-refs: string@[branches head]
    --empty: string@[drop keep abort]
]

@complete external
export extern "git history fixup" [
    --dry-run
    --update-refs: string@[branches head]
    --reedit-message
    --empty: string@[drop keep abort]
]

@complete external
export extern "git history reword" [
    --dry-run
    --update-refs: string@[branches head]
]

@complete external
export extern "git history split" [
    --dry-run
    --update-refs: string@[branches head]
]

@complete external
export extern "git init" [
    --quiet(-q)
    --bare
    --template
    --separate-git-dir
    --object-format: string@[sha1 sha256]
    --initial-branch(-b): string
    --shared: string@['false' 'true' umask group all world everybody]
]

@complete external
export extern "git interpret-trailers" [
    --in-place
    --trim-empty
    --trailer: string
    --where: string@[after before end start]
    --no-where
    --if-exists: string@[addIfDifferent addIfDifferentNeighbor add replace doNothing]
    --no-if-exists
    --if-missing: string@[doNothing add]
    --no-if-missing
    --only-trailers
    --only-input
    --unfold
    --parse
    --no-divider
]

@complete external
export extern "git shortlog" [
    --numbered(-n)
    --no-numbered
    --summary(-s)
    --no-summary
    --email(-e)
    --no-email
    --committer(-c)
    --no-committer
    --group: string@[author committer trailer: format:]
    --no-group
    -w
    --max-count: string
    --skip: string
    --since: string
    --since-as-filter: string
    --after: string
    --until: string
    --before: string
    --author: string
    --grep-reflog: string
    --grep: string
    --all-match
    --invert-grep
    --regexp-ignore-case(-i)
    --basic-regexp
    --extended-regexp(-E)
    --fixed-strings(-F)
    --perl-regexp
    --remove-empty
    --merges
    --no-merges
    --min-parents: string
    --max-parents: string
    --no-min-parents
    --no-max-parents
    --first-parent
    --not
    --all
    --branches
    --tags
    --remotes
    --glob: string
    --exclude: string
    --reflog
    --ignore-missing
    --bisect
    --stdin
    --cherry-mark
    --cherry-pick
    --left-only
    --right-only
    --cherry
    --walk-reflogs(-g)
    --merge
    --boundary
    --simplify-by-decoration
    --full-history
    --dense
    --sparse
    --simplify-merges
    --ancestry-path
    --date-order
    --author-date-order
    --topo-order
    --reverse
    --no-walk
    --do-walk
    --format: string
    --date: string
    ...args: external_arg@"nu-complete git ls-files"
]

@complete external
export extern "git ls-files" [
    --cached(-c)
    --deleted(-d)
    --modified(-m)
    --others(-o)
    --ignored(-i)
    --stage(-s)
    --directory
    --no-empty-directory
    --unmerged(-u)
    --killed(-k)
    -z
    --exclude(-x)
    --exclude-from(-X)
    --exclude-per-directory
    --exclude-standard
    --error-unmatch
    --with-tree
    -t
    -v
    -f
    --full-name
    --recurse-submodules
    --abbrev
    --debug
    --eol
]

@complete external
export extern "git mailinfo" [
    -k
    -b
    -u
    --encoding: string
    -n
    --message-id(-m)
    --scissors
    --no-scissors
    --quoted-cr: string@[nowarn warn strip]
]

@complete external
export extern "git mailsplit" [
    -o
    -b
    -d: string
    -f: string
    --keep-cr
    --mboxrd
]

@complete external
export extern "git maintenance" [
    --quiet
    --task: string@[commit-graph prefetch gc loose-objects incremental-repack pack-refs]
    --auto
    --schedule
    ...args: external_arg@[register run start stop unregister]
]

@complete external
export extern "git merge" [
    --commit
    --no-commit
    --edit(-e)
    --no-edit
    --ff
    --no-ff
    --ff-only
    --gpg-sign(-S)
    --log
    --no-log
    --signoff
    --no-signoff
    --stat
    --no-stat(-n)
    --squash
    --no-squash
    --strategy(-s): string
    --strategy-option(-X): string
    --verify-signatures
    --no-verify-signatures
    --quiet(-q)
    --verbose(-v)
    --progress
    --no-progress
    --allow-unrelated-histories
    -m: string
    --rerere-autoupdate
    --no-rerere-autoupdate
    --abort
    --continue
    --autostash
    --no-autostash
]

@complete external
export extern "git merge-base" [
    --all(-a)
    --octopus
    --independent
    --is-ancestor
    --fork-point
]

@complete external
export extern "git merge-tree" [
    --write-tree
    --trivial-merge
    --stdin
    -z
    --name-only
    --messages
    --no-messages
    --quiet
    --allow-unrelated-histories
    --strategy-option(-X): string
]

@complete external
export extern "git mergetool" [
    --tool(-t)
    --tool-help
    --no-prompt(-y)
    --prompt
    -O
]

@complete external
export extern "git mv" [
    --force(-f)
    -k
    --dry-run(-n)
    --verbose(-v)
    ...args: external_arg@"nu-complete git ls-files"
]

@complete external
export extern "git notes" []

@complete external
export extern "git notes list" []

@complete external
export extern "git notes add" [
    --force(-f)
    --allow-empty
    --file(-F): string
    --message(-m): string
    --reuse-message(-C)
    --reedit-message(-c)
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes copy" [
    --force(-f)
    --stdin
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes append" [
    --allow-empty
    --file(-F): string
    --message(-m): string
    --reuse-message(-C)
    --reedit-message(-c)
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes edit" [
    --allow-empty
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes show" [
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes merge" [
    --verbose(-v)
    --quiet(-q)
    --strategy(-s): string
    --commit
    --abort
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes remove" [
    --stdin
    --verbose(-v)
    --quiet(-q)
    --ignore-missing
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git notes prune" [
    --verbose(-v)
    --quiet(-q)
]

@complete external
export extern "git notes get-ref" []

@complete external
export extern "git prune" [
    --dry-run(-n)
    --verbose(-v)
    --progress
    --expire: string
]

@complete external
export extern "git push" [
    --all
    --prune
    --mirror
    --delete
    --tags
    --follow-tags
    --dry-run(-n)
    --porcelain
    --force(-f)
    --force-with-lease
    --force-if-includes
    --set-upstream(-u)
    --quiet(-q)
    --verbose(-v)
    --progress
    --verify
    --no-verify
    --recurse-submodules: string@[check on-demand only no]
    --signed
    --no-signed
    --atomic
    --no-atomic
    --thin
    --no-thin
    --ipv4(-4)
    --ipv6(-6)
    --push-option(-o): string
    --repo: string
    --receive-pack: string
    --exec: string
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git rebase" [
    --keep-empty
    --keep-base
    --merge(-m)
    --quiet(-q)
    --verbose(-v)
    --stat
    --no-stat(-n)
    --verify
    --no-verify
    --force-rebase(-f)
    --committer-date-is-author-date
    --ignore-date
    --interactive(-i)
    --preserve-merges(-p)
    --rebase-merges(-r)
    --root
    --autosquash
    --no-autosquash
    --autostash
    --no-autostash
    --no-ff
    --update-refs
    --no-update-refs
    --exec: string
]

@complete external
export extern "git reflog" [
    ...args: external_arg@"nu-complete git branches"
]

@complete external
export extern "git reflog show" []

@complete external
export extern "git reflog expire" []

@complete external
export extern "git reflog delete" []

@complete external
export extern "git reflog exists" []

@complete external
export extern "git reset" [
    --hard
    --soft
    --mixed
    --quiet(-q)
    --patch(-p)
    --merge
    --keep
    --pathspec-from-file
    --pathspec-file-nul
    ...args: external_arg@"nu-complete git reflog"
]

@complete external
export extern "git restore" [
    --source(-s): string
    --patch(-p)
    --worktree(-W)
    --staged(-S)
    --ours
    --theirs
    --merge(-m)
    --ignore-unmerged
    --ignore-skip-worktree-bits
    --overlay
    --no-overlay
    --quiet(-q)
    --progress
    --no-progress
]

@complete external
export extern "git switch" [
    --create(-c)
    --force-create(-C)
    --detach(-d): string
    --guess
    --no-guess
    --force(-f)
    --discard-changes
    --merge(-m)
    --track(-t)
    --no-track
    --orphan: string
    --ignore-other-worktrees
    --recurse-submodules
    --no-recurse-submodules
    --quiet(-q)
    --progress
    --no-progress
    ...args: external_arg@"nu-complete git switch args"
]

@complete external
export extern "git rev-parse" [
    --abbrev-ref
    --is-inside-git-dir
    --is-inside-work-tree
]

@complete external
export extern "git revert" [
    --continue
    --abort
    --skip
    --quit
    --no-edit
    --no-commit(-n)
    --signoff(-s)
    --rerere-autoupdate
    --no-rerere-autoupdate
    --edit(-e)
    --mainline(-m): string
    --gpg-sign(-S): string
    --no-gpg-sign
    --strategy: string
    --strategy-option(-X): string
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git rm" [
    --cached
    --ignore-unmatch
    -r
    --quiet(-q)
    --force(-f)
    --dry-run(-n)
    --sparse
    --pathspec-from-file
    --pathspec-file-nul
]

@complete external
export extern "git status" [
    --short(-s)
    --branch(-b)
    --porcelain
    -z
    --untracked-files(-u): string@[no normal all]
    --ignore-submodules: string@[none untracked dirty all]
    --verbose(-v)
    --no-ahead-behind
    --renames
    --no-renames
    --ahead-behind
    --long
    --show-stash
    --column: string
    --no-column
    --pathspec-from-file
    --pathspec-file-nul
]

@complete external
export extern "git stripspace" [
    --strip-comments(-s)
    --comment-lines(-c)
]

@complete external
export extern "git tag" [
    --annotate(-a)
    --sign(-s)
    --delete(-d)
    --verify(-v)
    --force(-f)
    --list(-l)
    --contains: string@"nu-complete git commits"
    --message(-m): string
    --file(-F)
    --local-user(-u): string
    --cleanup: string@[strip whitespace verbatim]
    --create-reflog
    --no-create-reflog
    --color: string@[always never auto]
    --column
    --no-column
    --sort: string
    --merged
    --no-merged
    --points-at: string
]

@complete external
export extern "git update-index" [
    --add
    --remove
    --refresh
    -q
    --ignore-submodules
    --unmerged
    --ignore-missing
    --index-info
    --chmod: string@['+x' '-x']
    --assume-unchanged
    --no-assume-unchanged
    --really-refresh
    --skip-worktree
    --no-skip-worktree
    --fsmonitor-valid
    --no-fsmonitor-valid
    --again(-g)
    --unresolve
    --info-only: string
    --force-remove
    --replace
    --stdin
    --verbose
    --index-version: string@['2']
    -z
    --split-index
    --no-split-index
    --untracked-cache
    --no-untracked-cache
    --test-untracked-cache
    --force-untracked-cache
    --fsmonitor
    --no-fsmonitor
]

@complete external
export extern "git worktree" []

@complete external
export extern "git worktree add" [
    --force(-f)
    -b: string
    -B: string
    --detach
    --checkout
    --no-checkout
    --guess-remote
    --no-guess-remote
    --track
    --no-track
    --lock
    --quiet(-q)
]

@complete external
export extern "git worktree list" [
    --porcelain
]

@complete external
export extern "git worktree lock" [
    --reason: string
    ...args: external_arg@"nu-complete git complete worktrees"
]

@complete external
export extern "git worktree move" [
    --force(-f)
    ...args: external_arg@"nu-complete git complete worktrees"
]

@complete external
export extern "git worktree prune" [
    --dry-run(-n)
    --verbose(-v)
    --expire: string
]

@complete external
export extern "git worktree remove" [
    --force(-f)
    ...args: external_arg@"nu-complete git complete worktrees"
]

@complete external
export extern "git worktree unlock" [
    ...args: external_arg@"nu-complete git complete worktrees"
]

@complete external
export extern "git stash" []

@complete external
export extern "git stash list" []

@complete external
export extern "git stash show" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash pop" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash apply" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash clear" []

@complete external
export extern "git stash drop" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash create" []

@complete external
export extern "git stash save" []

@complete external
export extern "git stash branch" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash push" []

@complete external
export extern "git stash export" [
    ...args: external_arg@"nu-complete git complete stashes"
]

@complete external
export extern "git stash import" []

@complete external
export extern "git export" [
    --print
    --to-ref: string
]

@complete external
export extern "git config" [
    --local
    --global
    --system
    --worktree
    --file(-f)
    --blob
    --list(-l)
    --edit(-e)
    --get
    --get-all
    --get-regexp
    --get-urlmatch
    --add
    --unset
    --unset-all
    --replace-all
    --rename-section
    --remove-section
    --type: string@[bool int bool-or-int path expiry-date color]
    --bool
    --int
    --bool-or-int
    --path
    --null(-z)
    --name-only
    --show-origin
    --show-scope
    --includes
    --no-includes
    --default: string
    -t
    --expiry-date
]

@complete external
export extern "git format-patch" [
    --output-directory(-o): directory
    --no-stat(-p)
    --no-patch(-s)
    --minimal
    --patience
    --histogram
    --stdout
    --numstat
    --shortstat
    --summary
    --no-renames
    --full-index
    --binary
    --find-copies-harder
    --text(-a)
    --ignore-space-at-eol
    --ignore-space-change(-b)
    --ignore-all-space(-w)
    --ignore-blank-lines
    --function-context(-W)
    --ext-diff
    --no-ext-diff
    --no-textconv
    --textconv
    --no-prefix
    --numbered(-n)
    --no-numbered(-N)
]

@complete external
export extern "git submodule" [
    --quiet(-q)
]

@complete external
export extern "git submodule add" [
    --force
]

@complete external
export extern "git submodule status" [
    --cached
    --recursive
    ...args: external_arg@"nu-complete git submodules"
]

@complete external
export extern "git submodule init" []

@complete external
export extern "git submodule deinit" [
    --force
    --all
    ...args: external_arg@"nu-complete git submodules"
]

@complete external
export extern "git submodule update" [
    --init
    --checkout
    --merge
    --rebase
    --no-fetch(-N)
    --remote
    --force
    --filter: string
    --recursive
]

@complete external
export extern "git submodule set-branch" [
    --branch(-b)
    --default(-d)
]

@complete external
export extern "git submodule set-url" []

@complete external
export extern "git submodule summary" [
    --cached
    --files
]

@complete external
export extern "git submodule foreach" [
    --recursive
    ...args: external_arg@"nu-complete git commands"
]

@complete external
export extern "git submodule sync" []

@complete external
export extern "git submodule absorbgitdirs" []

@complete external
export extern "git whatchanged" []

@complete external
export extern "git clean" [
    --force(-f)
    --interactive(-i)
    --dry-run(-n)
    --quiet(-q)
    -d
    -x
    -X
    --exclude(-e): string
]

@complete external
export extern "git blame" [
    -b
    --root
    --show-stats
    -L
    -l
    -t
    -S: string
    --reverse
    --porcelain(-p)
    --line-porcelain
    --incremental
    --contents: string
    --date: string
    -M
    -C
    -h
    -c
    --show-name(-f)
    --show-number(-n)
    -s
    --show-email(-e)
    -w
]

@complete external
export extern "git help" [
    ...args: external_arg@[add am apply archive bisect blame branch checkout cherry-pick clean clone commit config count-objects describe diff daemon difftool fetch filter-branch format-patch gc grep init log ls-files mailinfo mailsplit maintenance merge merge-base merge-tree mergetool mv notes prune pull push range-diff rebase reflog remote reset restore revert rev-parse rm show show-branch stash status submodule stripspace switch tag update-index whatchanged worktree]
]

@complete external
export extern "git for-each-ref" [
    --count
    --format: string
    --color
    --points-at
    --merged: string@"nu-complete git commits"
    --no-merged: string@"nu-complete git commits"
    --contains: string@"nu-complete git commits"
    --no-contains: string@"nu-complete git commits"
    --ignore-case: string
    --sort
]

@complete external
export extern "git send-email" [
    --annotate
    --bcc: string
    --cc: string
    --compose
    --from: string
    --reply-to: string
    --in-reply-to: string
    --subject: string
    --to: string
    --8bit-encoding: string@[UTF-8]
    --compose-encoding: string@[UTF-8]
    --transfer-encoding: string@['7bit' '8bit' quoted-printable base64 auto]
    --xmailer
    --no-xmailer
    --envelope-sender: string
    --sendmail-cmd: string@"nu-complete git commands"
    --smtp-encryption: string@[ssl tls]
    --smtp-domain: string
    --smtp-auth: string
    --smtp-pass: string
    --no-smtp-auth
    --smtp-server: string
    --smtp-server-port: string
    --smtp-server-option: string
    --smtp-ssl-cert-path: string
    --smtp-user: string
    --smtp-debug: string@['0' '1']
    --batch-size: string
    --relogin-dleay: string
    --no-to
    --no-cc
    --no-bcc
    --no-identity
    --to-cmd: string@"nu-complete git commands"
    --cc-cmd: string@"nu-complete git commands"
    --header-cmd: string@"nu-complete git commands"
    --no-header-cmd
    --chain-reply-to
    --no-chain-reply-to
    --identity: string
    --signed-off-by-cc
    --no-signed-off-by-cc
    --cc-cover
    --no-cc-cover
    --to-cover
    --no-to-cover
    --suppress-cc: string
    --suppress-from
    --no-suppress-from
    --thread
    --no-thread
    --confirm: string
    --dry-run
    --format-patch
    --no-format-patch
    --quiet
    --validate
    --no-validate
    --force
    --dump-aliases
]

@complete external
export extern "git cat-file" [
    -t
    -s
    -e
    -p
    --textconv
    --filters
    --batch
    --batch-check
    --batch-all-objects
    --follow-symlinks
]

@complete external
export extern "git ls-remote" [
    --heads(-h)
    --tags(-t)
    --refs
    --quiet(-q)
    --upload-pack: string
    --exit-code
    --get-url
    --symref
    --sort: string
    ...args: external_arg@"nu-complete git remotes"
]

@complete external
export extern "git ls-tree" [
    -d
    -r
    -t
    --name-only
    --name-status
    --full-name
    --full-tree
    -z
    --long
    --abbrev
]

@complete external
export extern "git show-ref" [
    --head
    --heads
    --tags
    --dereference(-d)
    --hash(-s)
    --verify
    --abbrev
    --quiet(-q)
    --exclude-existing
]

@complete external
export extern "git symbolic-ref" [
    --delete(-d)
    --quiet(-q)
    --short
    -m: string
]

@complete external
export extern "git check-ignore" [
    --quiet(-q)
    --verbose(-v)
    --stdin
    -z
    --non-matching(-n)
    --no-index
]

@complete external
export extern "git checkout-index" [
    --all(-a)
    --force(-f)
    --no-create(-n)
    --quiet(-q)
    --index(-u)
    -z
    --prefix: string
    --stage: string@[all '1' '2' '3']
    --temp
]

@complete external
export extern "git commit-tree" [
    -p: string
    -m: string
    -F
    --gpg-sign(-S): string
    --no-gpg-sign
]

@complete external
export extern "git diff-index" [
    --cached
    -m
    --raw
    --patch(-p)
    --quiet(-q)
]

@complete external
export extern "git hash-object" [
    -t: string@[blob tree commit tag]
    -w
    --stdin
    --stdin-paths
    --path
    --no-filters
    --literally
]

@complete external
export extern "git read-tree" [
    -m
    --reset
    -u
    -i
    --dry-run(-n)
    -v
    --trivial
    --aggressive
    --prefix: string
    --index-output
    --empty
    --no-sparse-checkout
]

@complete external
export extern "git update-ref" [
    -d
    --no-deref
    -m: string
    --create-reflog
    --stdin
    -z
]

@complete external
export extern "git verify-commit" [
    --verbose(-v)
    --raw
    ...args: external_arg@"nu-complete git commits"
]

@complete external
export extern "git verify-pack" [
    --verbose(-v)
    --stat-only(-s)
]

@complete external
export extern "git verify-tag" [
    --verbose(-v)
    --raw
    --format: string
    ...args: external_arg@"nu-complete git tags"
]

@complete external
export extern "git write-tree" [
    --missing-ok
    --prefix: string
]
