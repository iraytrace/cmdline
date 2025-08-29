#!/usr/bin/env bash

source cmdline_options.sh

cmdline.add_option "c|clean||Remove Temporary Files"
cmdline.add_option "f|file|filename=default.txt|Specify filename to use format:filename.txt"
cmdline.add_option "t|timestamp|date=now|Specify timestamp"
cmdline.add_option "v|version||Show version"

cmdline.set_default "timestamp" "date=$(date)"

clean() { # simple function to handle command line option
	echo "removing temporary files $@"
}

# Parse the command line arguments into CMDLINE_ARGS array
# Default values can be set with: cmdline.parse -f default_filename "$@"
cmdline.parse "$@"

set -- ${CMDLINE_ARGS[positional]}

# print all the key/value pairs
cmdline.print_args

# optional debugging output
# cmdline.print_options

# To invoke usage message directly:
# cmdline.usage

# call functions for each command line argument if defined
for key in "${!CMDLINE_ARGS[@]}" ; do
	if declare -F $key > /dev/null ; then
		"$key" "${CMDLINE_ARGS[$key]}"
	fi
done

if [[ -v CMDLINE_ARGS[file] ]] ; then
	# handle --file filename
	echo "read file ${CMDLINE_ARGS[file]}"
fi

if [[ -v CMDLINE_ARGS[version] ]] ; then
	# handle -v
	echo "Version 1.0"
fi


if [ $# -gt 0 ] ; then
	for arg in $@ ; do
		echo "process $arg"
	done
else
	echo "no positional args"
fi
