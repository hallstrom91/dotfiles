# modular helper scripts

## Usage

1. **Circular deps:** avoid circular deps in modules.

```sh
# inside script, require mods thru
# ... COMING SOON ...
```

2. **Global variables:** few and far apart. Set value in main() or in env-var (bashrc ex: export VERBOSE=1)

```sh
# set Global variables in main script (install.sh)
:${VAR:=default}
```

```bash
# OR set global in env (.bashrc / .bash_exports)
export VERBOSE=1
export DRY_RUN=1
```

3. **Side effects:** no set -e, trap or execution in modules.

4. **Namespaces:** filename::func (Public API)

```sh


# module function internal helpers: (interal helper)
name::__helpfunc() { printf '%b\n' "$*" >&2; }

# module function public API:` "name::func()
name::func() { printf '%b\n' "$*" >&2; }
```

5. **ShellCheck:** add rule to dynamic path

```sh
# shellcheck source=/dev/null
source "$DOTFILES/bin/helpers/require.sh"

# shellcheck source=/dev/null
require logger
```

## modules

- `backup.sh:` ...
- `cmdrunner.sh:` ...
- `copy.sh:` ...
- `fs.sh:` ...
- `link.sh:` ...
- `logs.sh:` message logger for print with color and icons (err,warn,ok,info), and a arrow-icon.

```sh
# Global Envs
: "${ICONS:=1}" # requires nerdfont.
: "${COLOR:=1}" # requires color support in term.
: "${VERBOSE:=0}"

# USAGE: (after loaded with require.sh helper or fn inside main script)
# 	log "info"
# 	warn "warn"
# 	verbose "verbose (dbg) - flag needed."
# 	success "ok"
# 	fail "fail"

```

- `repo_guard.sh:` ...
- `require.sh:` ... one script to rule them all ...
