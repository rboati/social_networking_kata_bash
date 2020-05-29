bash_import "$SRC_DIR/mod/repl.bash"
bash_import "$SRC_DIR/mod/user.bash"

testsuite_repl_setup() {
	init_users
}

testsuite_repl_teardown() {
	fini_users
}

testsuite_repl_test_posting_and_reading() {
	local output
	local expected

	output="$(
		cat <<- EOF | repl | sed 's/ (.* ago)$//'
		Alice -> I love the weather today
		Bob -> Damn! We lost!
		Bob -> Good game though.
		Alice
		Bob
		EOF
	)"

	expected="$(cat <<- EOF | sed 's/ (.* ago)$//'
		I love the weather today (0 seconds ago)
		Good game though. (0 seconds ago)
		Damn! We lost! (0 seconds ago)
		EOF
	)"

	test_assert_eq "$output" "$expected"
}

testsuite_repl_test_following_and_wall() {
	local output
	local expected

	output="$(
		cat <<- EOF | repl | sed 's/ (.* ago)$//'
		Alice -> I love the weather today
		Bob -> Damn! We lost!
		Bob -> Good game though.
		Charlie -> I'm in New York today! Anyone wants to have a coffee?
		Charlie follows Alice
		Charlie wall
		Charlie follows Bob
		Charlie wall
		EOF
	)"

	expected="$(cat <<- EOF | sed 's/ (.* ago)$//'
		Charlie - I'm in New York today! Anyone wants to have a coffee? (0 seconds ago)
		Alice - I love the weather today (0 seconds ago)
		Charlie - I'm in New York today! Anyone wants to have a coffee? (0 seconds ago)
		Bob - Good game though. (0 seconds ago)
		Bob - Damn! We lost! (0 seconds ago)
		Alice - I love the weather today (0 seconds ago)
		EOF
	)"

	test_assert_eq "$output" "$expected"

}
