bash_import "$SRC_DIR/mod/repl.bash"
bash_import "$SRC_DIR/mod/time.bash"


testsuite_acceptance_setup() {
	# overwrite time::current_time()
	current_time() { echo "$MOCK_TIME"; }
	declare -gi MOCK_TIME=0
}

testsuite_acceptance_teardown() {
	fini_users
	unset MOCK_TIME
	bash_import "$SRC_DIR/mod/time.bash" # restore current_time
}


testsuite_acceptance_test_1() {
	local output

	# posting

	MOCK_TIME=$(( $(date +%s) - 10*60))
	output="$(echo 'Alice -> I love the weather today' | repl)"
	test_assert_eq "$output" ''

	(( MOCK_TIME += 3*60 ))
	output="$(echo 'Bob -> Damn! We lost!' | repl)"
	test_assert_eq "$output" ''

	(( MOCK_TIME += 1*60 ))
	output="$(echo 'Bob -> Good game though.' | repl)"
	test_assert_eq "$output" ''

	# reading

	(( MOCK_TIME += 60 ))
	output="$(echo 'Alice' | repl)"
	expected='I love the weather today (5 minutes ago)'
	test_assert_eq "$output" "$expected"

	(( MOCK_TIME += 5 ))
	output="$(echo 'Bob' | repl)"
	expected="$(cat <<- EOF
		Good game though. (1 minute ago)
		Damn! We lost! (2 minutes ago)
		EOF
	)"
	test_assert_eq "$output" "$expected"

	# following

	(( MOCK_TIME += 5 ))
	output="$(echo "Charlie -> I'm in New York today! Anyone wants to have a coffee?" | repl)"
	test_assert_eq "$output" ''

	(( MOCK_TIME += 1 ))
	output="$(echo "Charlie follows Alice" | repl)"
	test_assert_eq "$output" ''

	(( MOCK_TIME += 1 ))
	output="$(echo "Charlie wall" | repl)"
	expected="$(cat <<- EOF
		Charlie - I'm in New York today! Anyone wants to have a coffee? (2 seconds ago)
		Alice - I love the weather today (5 minutes ago)
		EOF
	)"
	test_assert_eq "$output" "$expected"
}

