#!/bin/bash

THIS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
LIB_DIR="$(cd "$THIS_DIR/lib" && pwd)"

# shellcheck disable=SC2034
BASH_LIBRARY_PATH="$LIB_DIR"

# shellcheck disable=SC1090
source "$LIB_DIR/libimport.bash"
bash_import libloglevel.bash

[[ -z $LOGLEVEL ]] && LOGLEVEL=6
set_loglevel "$LOGLEVEL"

bash_import libassert.bash

bash_source ./mod/repl.bash # repl
bash_source ./mod/user.bash # init_users, fini_users



main() {
	repl
}

init_users
trap 'fini_users' EXIT
main "$@"
