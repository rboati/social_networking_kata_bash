
bash_import libdata.bash
bash_import ./time.bash

declare -gA USERS_DB=( )
#declare -gA USERS_DB=( [file]=user.db [vfs]=unix )

init_users() {
	if [[ -f ${USERS_DB[file]} ]]; then
		open_db USERS_DB
		return
	fi

	open_db USERS_DB

	local sql="$( cat <<- EOF
		CREATE TABLE user (
			id INTEGER PRIMARY KEY,
			name TEXT NOT NULL UNIQUE
		);

		CREATE TABLE following (
			follower_id INTEGER NOT NULL REFERENCES user(id) ON DELETE CASCADE,
			followed_id INTEGER NOT NULL REFERENCES user(id) ON DELETE CASCADE,
			PRIMARY KEY (follower_id, followed_id)
		) WITHOUT ROWID;

		CREATE TABLE post (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			author_id INTEGER NOT NULL REFERENCES user(id) ON DELETE CASCADE,
			timestamp INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP,
			content TEXT
		);
		EOF
	)"
	query USERS_DB "$sql" > /dev/null
}

fini_users() {
	close_db USERS_DB
}


user_exists() {
	local user="$1"
	local -i record_id
	get_record USERS_DB "SELECT id FROM user WHERE name=$(sql_quote "$user")"
	return $?
}

add_user() {
	local user="$1"
	if user_exists "$user"; then
		return 1
	fi
	query USERS_DB "INSERT INTO user (name) VALUES ($(sql_quote "$user"))" > /dev/null
}

remove_user() { return 1; } #TODO

reset_users() {
	query USERS_DB "DELETE FROM user" > /dev/null
}

user_post() { return 1; } #TODO

user_follow() { return 1; } #TODO

user_unfollow() { return 1; } #TODO

user_read() { return 1; } #TODO

user_wall() { return 1; } #TODO
