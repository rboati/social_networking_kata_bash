bash_source ./user.bash


repl() {
	# shellcheck disable=SC2034
	local LOGDOMAIN="repl"
	local user cmd args
	if [[ ! -d  "$HOME/.config/social_networking_kata" ]]; then
		mkdir -p "$HOME/.config/social_networking_kata"
	fi
	local HISTFILE="$HOME/.config/social_networking_kata/repl_history"
	local HISTCONTROL="ignoreboth:erasedups"
	history -c
	history -r

	while :; do # repl loop
		while read -r -e -p '> ' user cmd args; do # read loop
			if [[ -z $user ]]; then
				continue 2 # back to repl loop
			fi
			break
		done

		if [[ -z $user ]]; then # manage CTRL-D
			echo
			return
		fi

		case "$cmd" in
			'->')
				echotrace "user_post \"$user\" \"$args\""
				user_post "$user" "$args"
				;;
			follows)
				echotrace "user_follow \"$user\" \"$args\""
				user_follow "$user" "$args"
				;;
			wall)
				echotrace "user_wall \"$user\""
				user_wall "$user"
				;;
			'')
				echotrace "user_read \"$user\""
				user_read "$user"
				;;
			*)
				echoerror "Unknown command '$cmd'"
		esac
		history -s "${user}${cmd:+ $cmd}${args:+ $args}"
		history -w
	done
}
