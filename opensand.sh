#!/bin/bash

export SCRIPT_VERSION="0.3-alpha"
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "${SCRIPT_DIR}/env.sh"
source "${SCRIPT_DIR}/setup.sh"
source "${SCRIPT_DIR}/setup-namespaces.sh"
source "${SCRIPT_DIR}/setup-opensand.sh"
source "${SCRIPT_DIR}/teardown.sh"
source "${SCRIPT_DIR}/teardown-namespaces.sh"
source "${SCRIPT_DIR}/teardown-opensand.sh"
source "${SCRIPT_DIR}/run-ping.sh"

# log(level, message...)
# Log a message of the specified level to the output and the log file.
function log() {
	local level="$1"
	shift
	local msg="$@"

	local log_time="$( date --rfc-3339=seconds )"
	local level_name="INFO"
	local level_color="\e[0m"
	case $level in
		D|d)
			level_name="DEBUG"
			level_color="\e[2m"
			;;
		I|i)
			level_name="INFO"
			level_color="\e[0m"
			;;
		W|w)
			level_name="WARN"
			level_color="\e[33m"
			;;
		E|e)
			level_name="ERROR"
			level_color="\e[31m"
			;;
		*)
			# No level given, assume info
			msg="$level $msg"
			level="I"
			level_name="INFO"
			level_color="\e[0m"
			;;
	esac

	# Build and print log message
	log_entry="$log_time [$level_name]: $msg"
	echo -e "$level_color$log_entry\e[0m"
	
	if [ -d "$EMULATION_DIR" ]; then
		echo "$log_entry" >> "$EMULATION_DIR/opensand.log"
	fi
}

function _main() {
	# TODO arg parse
	emulation_start="$( date +"%Y-%m-%d-%H-%M" )"
	EMULATION_DIR="${RESULTS_DIR}/${emulation_start}_opensand"
	mkdir -p $EMULATION_DIR

	_setup
	sleep 3
	_run_ping "${EMULATION_DIR}"
	sleep 3
	_teardown
}

_main "$@"