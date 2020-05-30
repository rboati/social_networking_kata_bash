bash_import "$SRC_DIR/mod/time.bash"

testsuite_time_setup() {
	# overwrite time.bash::current_time()
	current_time() { echo "$MOCK_TIME"; }
	declare -gi MOCK_TIME=0
}

testsuite_time_teardown() {
	unset MOCK_TIME
	bash_import "$SRC_DIR/mod/time.bash" # restore current_time
}


testsuite_time_test_relative_time() {
	local -i timestamp
	MOCK_TIME=$(date +%s)

	test_assert_eq "$(human_relative_time @$MOCK_TIME)" "0 seconds ago"
	timestamp=$(( MOCK_TIME - 1 ))
	test_assert_eq "$(human_relative_time @$timestamp)" "1 second ago"
	timestamp=$(( MOCK_TIME - 10 ))
	test_assert_eq "$(human_relative_time @$timestamp)" "10 seconds ago"
	timestamp=$(( MOCK_TIME - 60 ))
	test_assert_eq "$(human_relative_time @$timestamp)" "1 minute ago"
	timestamp=$(( MOCK_TIME - 60*10 ))
	test_assert_eq "$(human_relative_time @$timestamp)" "10 minutes ago"
}
