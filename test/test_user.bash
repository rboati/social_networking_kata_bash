bash_source "$SRC_DIR/mod/user.bash"

testsuite_user_setup() {
	init_users
}

testsuite_user_teardown() {
	fini_users
}

testsuite_user_test_adding_a_new_user() {
	test_assert "! user_exists Alice"
	add_user Alice
	test_assert "user_exists Alice"
}

testsuite_user_test_posting() {
	test_assert "! user_exists Alice"
	user_post Alice "I love the weather today"
	test_assert "user_exists Alice"
	local -i record_count
	local record_content
	get_record USERS_DB "SELECT count(*) count, p.content content FROM post p JOIN user u ON p.author_id = u.id WHERE u.name='Alice'"
	test_assert_eq "$record_count" 1
	test_assert_eq "$record_content" "I love the weather today"
}

testsuite_user_test_following() {
	test_assert "! user_exists Alice"
	test_assert "! user_exists Bob"
	user_follow Alice Bob
	test_assert "! user_exists Alice"
	test_assert "! user_exists Bob"
	add_user Alice
	add_user Bob
	user_follow Alice Bob
	local -i record_count
	local record_name
	get_record USERS_DB "SELECT count(*) count FROM following f JOIN user u1 ON f.follower_id = u1.id JOIN user u2 ON f.followed_id = u2.id WHERE u1.name='Alice'"
	test_assert_eq "$record_count" 1
	get_record USERS_DB "SELECT u2.name FROM following f JOIN user u1 ON f.follower_id = u1.id JOIN user u2 ON f.followed_id = u2.id WHERE u1.name='Alice'"
	test_assert_eq "$record_name" "Bob"
	get_record USERS_DB "SELECT count(*) count FROM following f JOIN user u1 ON f.follower_id = u1.id JOIN user u2 ON f.followed_id = u2.id WHERE u2.name='Bob'"
	test_assert_eq "$record_count" 1
	get_record USERS_DB "SELECT u1.name FROM following f JOIN user u1 ON f.follower_id = u1.id JOIN user u2 ON f.followed_id = u2.id WHERE u2.name='Bob'"
	test_assert_eq "$record_name" "Alice"
}