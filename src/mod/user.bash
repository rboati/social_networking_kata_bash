
bash_import libdata.bash

bash_source ./time.bash

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

user_post() {
	local user="$1"
	local msg="$2"
	if [[ -z $msg ]]; then
		return 1
	fi
	add_user "$user" || true
	local -i record_id
	get_record USERS_DB "SELECT id FROM user WHERE name=$(sql_quote "$user")"
	query USERS_DB "INSERT INTO post (author_id, content, timestamp) VALUES ($record_id, $(sql_quote "$msg"), datetime('$(current_time)', 'unixepoch') )" > /dev/null
}

user_follow() {
	local user="$1"
	local user_followed="$2"
	if ! user_exists "$user_followed"; then
		return 1
	fi
	add_user "$user" || true

	local -i user_id followed_id
	get_record USERS_DB "SELECT id FROM user WHERE name=$(sql_quote "$user")" user_
	get_record USERS_DB "SELECT id FROM user WHERE name=$(sql_quote "$user_followed")" followed_
	query USERS_DB "INSERT INTO following (follower_id, followed_id) VALUES ($user_id, $followed_id)" > /dev/null

}

user_unfollow() { return 1; } #TODO

user_read() {
	local user="$1"
	if ! user_exists "$user"; then
		return 1
	fi
	local record_timestamp record_content
	local quoted_user="$(sql_quote "$user")"
	local sql="$( cat <<- EOF
		SELECT content, strftime('%s',timestamp) timestamp
		FROM post p JOIN user u ON p.author_id = u.id
		WHERE u.name = $quoted_user
		ORDER BY p.id DESC
		EOF
	)"
	while iter_record USERS_DB "$sql"; do
		printf '%s (%s)\n' "$record_content" "$(human_relative_time "@$record_timestamp")"
 	done
}

user_wall() {
	local user="$1"
	if ! user_exists "$user"; then
		return 1
	fi
 	local record_name record_content record_timestamp
	local quoted_user="$(sql_quote "$user")"
	local sql="$( cat <<- EOF
		SELECT u.name name, p.content content, strftime('%s',timestamp) timestamp
		FROM post p
			JOIN user u ON p.author_id = u.id
		WHERE u.name = $quoted_user OR
			u.id IN (
			SELECT u2.id id
			FROM following f
				JOIN user u1 ON f.follower_id = u1.id
				JOIN user u2 ON f.followed_id = u2.id
			WHERE u1.name = $quoted_user
		) ORDER BY p.id DESC
		EOF
	)"
	query USERS_DB "$sql" | while parse_record; do
 		printf '%s - %s (%s)\n' "$record_name" "$record_content" "$(human_relative_time "@$record_timestamp")"
 	done
}


