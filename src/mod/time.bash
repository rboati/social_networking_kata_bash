bash_import libassert.bash
bash_import libloglevel.bash


current_time() {
	date +%s
}


en_plural() {
	local -i n="$1"
	local singular="$2"
	local plural="${3:-${singular}s}"
	if (( n == 1 )); then
		echo -n "$n $singular"
	else
		echo -n "$n $plural"
	fi
}

human_relative_time() {
	local time_ref="$1"
	local -ri SEC_PER_MINUTE=$((60))
	local -ri   SEC_PER_HOUR=$((60*60))
	local -ri    SEC_PER_DAY=$((60*60*24))
	local -ri  SEC_PER_MONTH=$((60*60*24*30))
	local -ri   SEC_PER_YEAR=$((60*60*24*365))

	local -i last_unix
	last_unix="$(date --date="$time_ref" +%s)"

	local -i now_unix
	now_unix="$(current_time)"

	local -ri delta_s=$(( now_unix - last_unix ))
	local -i delta

	if (( delta_s < SEC_PER_MINUTE )); then
		delta=$((delta_s))
		echo "$(en_plural $delta second) ago"
	elif (( delta_s < SEC_PER_HOUR )); then
		delta=$((delta_s / SEC_PER_MINUTE))
		echo "$(en_plural $delta minute) ago"
	elif (( delta_s < SEC_PER_DAY )); then
		delta=$((delta_s / SEC_PER_HOUR))
		echo "$(en_plural $delta hour) ago"
	elif (( delta_s < SEC_PER_MONTH )); then
		delta=$((delta_s / SEC_PER_DAY))
		echo "$(en_plural $delta day) ago"
	elif (( delta_s < SEC_PER_YEAR )); then
		delta=$((delta_s / SEC_PER_MONTH))
		echo "$(en_plural $delta month) ago"
	else
		delta=$((delta_s / SEC_PER_YEAR))
		echo "$(en_plural $delta year) ago"
	fi
}
