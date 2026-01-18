# Nushell Script Writing Guide

You are helping write Nushell scripts. Nushell is a modern shell that treats data as structured tables rather than plain text.

## Key Differences from Bash

### No `&&` operator
- Use `;` instead of `&&` for sequential execution
- `;` in Nushell behaves like `&&` in bash (stops on error)
```nushell
# Bash: mkdir foo && cd foo
# Nushell:
mkdir foo; cd foo
```

### Redirection is different
- `>` is a comparison operator, NOT redirection
- Use `| save` for file output
```nushell
# Bash: echo "hello" > file.txt
# Nushell:
"hello" | save file.txt
"hello" | save --force file.txt  # overwrite
```

### Pipe and Redirect Operators

External commands can use special redirect operators:

```nushell
# Pipe operators
|        # pipe stdout to another command
e>|      # pipe stderr to another command
o+e>|    # pipe stdout and stderr to another command

# Redirect to file (overwrite)
o>       # redirect stdout
e>       # redirect stderr
o+e>     # redirect stdout and stderr

# Redirect to file (append)
o>>      # append stdout
e>>      # append stderr
o+e>>    # append stdout and stderr
```

Examples:
```nushell
# Pipe stderr to another command
^cmd1 e>| ^cmd2

# Redirect stdout to file
^cmd1 o> output.txt

# Redirect stderr to file
^cmd1 e> errors.txt

# Redirect both stdout and stderr to file
^cmd1 o+e> all_output.txt

# Append stdout to file
^cmd1 o>> output.txt

# Append both to file
^cmd1 o+e>> all_output.txt
```

Note: `o>|` is not supported since redirecting stdout to a pipe is the same as normal piping (`|`).

### Environment Variables
```nushell
# Set environment variable
$env.PATH = "/usr/local/bin"
$env.MY_VAR = "value"

# Read environment variable
$env.PATH
$env.MY_VAR?  # safe access (returns null if not exists)

# Set multiple at once
load-env { "FOO": "bar", "BAZ": "qux" }

# Temporary environment (scoped)
with-env { FOO: "bar" } { some_command }

# Delete environment variable
hide-env FOO
```

## Getting Help

```nushell
# View command documentation
help ls
help open
help str

# Search for commands
help --find file      # find commands related to "file"
help --find string    # find commands related to "string"
```

## Data Types

Nushell has rich data types:
- **int**: `-65535`
- **float**: `9.9999`, `Infinity`
- **string**: `"hello"`, `'world'`
- **bool**: `true`, `false`
- **datetime**: `2000-01-01`
- **duration**: `2min + 12sec`, `1hr`
- **filesize**: `64mb`, `1gb`
- **range**: `0..4`, `0..<5` (exclusive end)
- **list**: `[1 2 3]`, `["a", "b", "c"]`
- **record**: `{name: "Nushell", version: 1}`
- **table**: list of records

## String Interpolation

```nushell
let name = "World"

# Use $"..." for interpolation
$"Hello, ($name)!"

# Expression inside parentheses
$"2 + 2 = (2 + 2)"

# Escape parentheses with backslash
$"Price: \(100 yen)"
```

## Pipelines and `$in`

```nushell
# $in represents pipeline input
ls | where size > 1kb | each { $in.name }

# Use $in when piping to command arguments
"my_directory" | mkdir $in

# Multi-line pipelines with parentheses
let result = (
    open data.json
    | get items
    | where active == true
)
```

## Variables

```nushell
# Immutable by default
let x = 10

# Mutable variable
mut y = 10
$y = $y + 1

# Constants (evaluated at parse time)
const CONFIG_PATH = "~/.config/app"
```

## Control Flow

```nushell
# if/else (returns value)
let result = if $x > 0 { "positive" } else { "non-positive" }

# match
match $value {
    1 => "one"
    2 => "two"
    _ => "other"
}

# for loop
for item in [1 2 3] {
    print $item
}

# while loop
mut i = 0
while $i < 10 {
    $i = $i + 1
}

# loop with break
loop {
    if $condition { break }
}
```

## Custom Commands (Functions)

```nushell
# Basic definition
def greet [name: string] {
    $"Hello, ($name)!"
}

# With optional parameter
def greet [name?: string] {
    let n = $name | default "World"
    $"Hello, ($n)!"
}

# With default value
def greet [name = "World"] {
    $"Hello, ($name)!"
}

# With flags
def greet [
    name: string
    --excited (-e)  # short flag
    --times: int = 1
] {
    let msg = $"Hello, ($name)!"
    if $excited { $"($msg)!!!" } else { $msg }
}

# Rest parameters
def sum [...numbers: int] {
    $numbers | math sum
}

# Preserve environment changes with --env
def-env add_to_path [path: string] {
    $env.PATH = ($env.PATH | prepend $path)
}
```

## Script Structure

```nushell
#!/usr/bin/env nu

# Definitions can be anywhere
def helper [] { ... }

# main function receives script arguments
def main [
    file: string      # required positional
    --verbose (-v)    # flag
] {
    if $verbose { print "Starting..." }
    # script logic here
}
```

## Operators

```nushell
# Arithmetic
+ - * / // (floor div) mod **

# Comparison
== != < <= > >=

# String matching
=~ (regex match)   !~ (not match)
starts-with        ends-with
like               not-like

# Logical
and or xor not

# List operations
in     not-in     # check if value in list
has    not-has    # check if list has value
++                # concatenate lists
```

## Common Commands

```nushell
# File operations
open file.json           # auto-parse based on extension
open file.txt | lines    # read as lines
save output.json         # save with format detection

# List/Table operations
ls | where size > 1mb
ls | sort-by modified
ls | select name size
ls | get name

# String operations
"hello" | str upcase
"hello world" | split row " "
"hello" | str replace "l" "L"

# Data conversion
open data.csv | to json
{a: 1} | to yaml
```

## Error Handling

```nushell
# try/catch
try {
    open nonexistent.txt
} catch {
    print "File not found"
}

# Create custom error
error make { msg: "Something went wrong" }
```

## External Commands

```nushell
# Call external command with ^
^git status

# Pass structured data to external (converts to string)
ls | to text | ^external_cmd

# Capture external command output
let output = (^git status)
```

## Tips

1. **Everything returns a value** - last expression is automatically returned
2. **Variables are immutable by default** - use `mut` for mutable
3. **Environment changes are scoped** - changes in blocks don't persist outside
4. **Parse then evaluate** - all code is parsed before execution, no dynamic code generation
5. **Tables are first-class** - most commands work with structured data
