#!/usr/bin/env bash
#
# Example use:
# source cmdline_options.sh
# 
# cmdline.add_option "c:clean::Remove Temporary Files"
# cmdline.add_option "f:file:filename=default.txt:Specify filename to use"
# cmdline.add_option "v:version::Show version"
#
# cmdline.parse "$@"
# # print all the key/value pairs
# echo "Command line options values:"
# for key in "${!CMDLINE_ARGS[@]}" ; do
# 	echo "  ${key}=${CMDLINE_ARGS[$key]}"
# done

declare -g CMDLINE_OPTIONS=( )

#
# add a description of a command line option
#
function cmdline.add_option() {
  CMDLINE_OPTIONS+=("$@")
}

cmdline.add_option "h:help::Display this help message"

#
# 
#
function cmdline.max_width() {
	max_option_length=0
	for key in "${!CMDLINE_OPTIONS[@]}"; do
    str="${CMDLINE_OPTIONS[$key]}"

    IFS=":" read -r short long arg desc <<< "${CMDLINE_OPTIONS[$key]}"
    IFS="=" read -r txt default <<< "$arg"

		left_side="${short}${long}${txt}"
	  length=${#left_side}

		if [ $max_option_length -lt $length ] ; then
			max_option_length=$length
		fi
  done
  echo $max_option_length
}

function cmdline.print() {
	# print all the key/value pairs
	echo "Command line options values:"
	for key in "${!CMDLINE_ARGS[@]}" ; do
		echo "  ${key}=${CMDLINE_ARGS[$key]}"
	done
}


#
# print usage message
#
function cmdline.usage() {
  echo -e "Usage: $0 [OPTIONS]\n\nOptions:"	

  pad_width=$(cmdline.max_width)
  pad_width=$(( $pad_width + 8 ))

	for key in "${!CMDLINE_OPTIONS[@]}"; do
		#echo "$key = ${CMDLINE_OPTIONS[$key]}"
    IFS=":" read -r short long arg desc <<< "${CMDLINE_OPTIONS[$key]}"
 	
    IFS="=" read -r txt default <<< "$arg"
		left_string="-${short} --${long} ${arg:+<}${txt}${arg:+>}"
		right_string="${desc} ${default:+(default=}${default}${default:+)}"
    printf "  %-*s%s\n" "$pad_width" "$left_string" "$right_string"
	done
}

#
#  get strings for short and long options for passing to getopt
#
function cmdline.long_short() {
  # Build getopt strings and help message
  for key in $(printf "%s\n" "${!CMDLINE_OPTIONS[@]}" | sort); do
    IFS=":" read -r short long arg desc <<< "${CMDLINE_OPTIONS[$key]}"

    # Add short and long options to getopt strings
		# add : if arg is not null
		SHORT_OPTS+="${short}${arg:+:}"
		LONG_OPTS+="${long}${arg:+:},"
  done
  LONG_OPTS="${LONG_OPTS%,}"

	echo "Short=$SHORT_OPTS long=$LONG_OPTS"
}

#
# parse the command line strings to extract option values
#
function cmdline.parse() {
  # Define the options in short=long[:arg]:description format
  declare -gA CMDLINE_ARGS=()

  SHORT_OPTS=""
  LONG_OPTS=""
  USAGE="Usage: $0 [CMDLINE_OPTIONS]\n\nOptions:\n"

	cmdline.long_short

  # Parse the options using getopt
  PARSED=$(getopt -o "$SHORT_OPTS" --long "$LONG_OPTS" -- "$@")

  if [[ $? -ne 0 ]]; then
		echo "error parsing args with getopt"
    echo -e "$USAGE" >&2
    exit 1
  fi
  eval set -- "$PARSED"  # Modify the positional parameters

  # === Dispatch Loop ===
  while true; do
    case "$1" in
      --)
        shift
        break  # Stop processing options, everything after `--` is a positional argument
        ;;
      -*)
        opt="${1#-}"         # Remove single dash
        opt="${opt#-}"       # Remove second dash if it's long option
        shift
        matched=false

        for key in "${!CMDLINE_OPTIONS[@]}"; do
          IFS=":" read -r short long arg desc <<< "${CMDLINE_OPTIONS[$key]}"
          if [[ "$opt" == "$short" || "$opt" == "$long" ]]; then
            matched=true

						if [[ "$long" == "help" ]] ; then
							cmdline.usage
							exit 0
            elif [[ "$arg" == "" ]]; then
						  CMDLINE_ARGS[$long]="1"
            else
						  CMDLINE_ARGS[$long]="$1"
              shift
            fi
            break
          fi
        done

        if ! $matched; then
          echo "Unknown option: $opt" >&2
          exit 1
        fi
        ;;
      *)
        break
        ;;
    esac
  done

  # Return the remaining unprocessed arguments
  if [ -n "$*" ] ; then
	  CMDLINE_ARGS[positional]="$@" 
  fi
}
