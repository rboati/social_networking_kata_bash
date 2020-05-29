#!/bin/bash

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$(cd "$THIS_DIR/../src" && pwd)"

# shellcheck disable=SC2034
BASH_LIBRARY_PATH="$THIS_DIR/lib:$SRC_DIR/lib"

# shellcheck disable=SC1090
source "$SRC_DIR/lib/libimport.bash"
bash_import libtest.bash
bash_import libloglevel.bash

declare -a MY_TESTS=(
	"$THIS_DIR/test_acceptance.bash"
	"$THIS_DIR/test_repl.bash"
	"$THIS_DIR/test_user.bash"
)

for i in "${MY_TESTS[@]}"; do
	DEBUG=1 bash_import "$i"
done
run_tests
print_test_results
