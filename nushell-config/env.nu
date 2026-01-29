# Nushell Environment Config File
#
# version = 0.83.1

def create_left_prompt [] {
    mut home = ""
    try {
        if $nu.os-info.name == "windows" {
            $home = $env.USERPROFILE
        } else {
            $home = $env.HOME
        }
    }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)\n"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | date format '%Y/%m/%d %r')
    ] | str join | str replace --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
$env.PROMPT_COMMAND_RIGHT = {|| "" }
$env.PROMPT_COMMAND = {|| $"(ansi reset)(ansi magenta)(date now | format date "%Y-%m-%dT%H:%M:%S%z")\n(pwd)" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    $nu.default-config-dir
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# source '~/openai-key.nu'



# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

def --env prepend_path [path] {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $path)
}

prepend_path '/opt/homebrew/bin'
prepend_path '/Users/tsukimizake/.ghcup/bin'
prepend_path '/Users/tsukimizake/.nimble/bin'
prepend_path '/Users/tsukimizake/.cargo/bin'
prepend_path '/Users/tsukimizake/.cabal/bin'
prepend_path '/Users/tsukimizake/.local/bin'
prepend_path '/Users/tsukimizake/.deno/bin'
prepend_path '/Users/tsukimizake/.claude/local/'

$env.BUN_INSTALL = $"($env.HOME)/.bun"
prepend_path $'($env.BUN_INSTALL)/bin'


$env.DENOPS_TEST_DENOPS_PATH = "/Users/tsukimizake/denops.vim/"
$env.EDITOR = "nvim"

let mise_path = $nu.cache-dir | path join mise.nu
if not ($nu.cache-dir | path exists) {
    mkdir $nu.cache-dir
}
^mise activate nu | save $mise_path --force
