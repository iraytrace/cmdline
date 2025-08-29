# cmdline

Parse command line options in bash

This script makes parsing command line arguments in bash scripts a comoddity
rather than having to write the getopt code each time.

## Example usage:
```
!/usr/bin/env bash

source cmdline_options.sh

cmdline.add_option "c:clean:Remove Temporary Files"
cmdline.add_option "f:file:filename:Specify filename to use"
cmdline.add_option "v:version:Show version"

cmdline.parse "$@"
set -- ${CMDLINE_ARGS[positional]}

echo "Command line options values:"
for key in "${!CMDLINE_ARGS[@]}" ; do
	echo "  ${key}=${CMDLINE_ARGS[$key]}"
done
```

```
$ ./sample_use.sh --help
Usage: ./sample_use.sh [OPTIONS]

Options:
  -h --help            Display this help message
  -c --clean           Remove Temporary Files
  -f --file <filename> Specify filename to use
  -v --version         Show version

$ ./sample_use.sh --file filename.txt
Command line options values:
  file=filename.txt
```
