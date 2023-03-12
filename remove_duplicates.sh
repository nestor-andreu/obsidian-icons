#! /bin/bash

showHelp () {
    cat <<EOF

Scans folder-to-clean. For each file present there, it scans 
source-folder for a file of equal name (no matter which extension). If
it is found, then the file in folder-to-clean is deleted (unless 
--dry-run is invoked)

Usage: $(basename "$0") [options...] source-folder folder-to-clean

Options:
  --help: display help
  --dry-run: do not actually do the changes, just prompt them

EOF
}

showErrorUsage () {
# shows an error message (paramter 1) and then calls showHelp
    echo -e "Error: $1"
    showHelp
}

debug () {
#Comment the echo to avoid debug output
	echo "debug: $1"
}

if [ $# -gt 3 ]
then
    showErrorUsage "Wrong number of parameters"
    exit 1
fi

if [ $# -eq 0 ]
then
    showHelp
    exit 0
fi

case $1 in
	--help)
		showHelp
		exit 0
	;;
	--dry-run)
		dryRun=true
		shift
	;;
esac

SOURCE=$1
DEST=$2

if [ ! -d "$SOURCE" ]; then
	showErrorUsage "source-folder $SOURCE not found"
	exit 1
fi

if [ ! -d "$DEST" ]; then
	showErrorUsage "folder-to-clean $DEST not found"
	exit 1
fi

for filename_to_possibly_clean in $DEST/*; do
	# debug "file in $DEST a to possibly clean: $filename_to_possibly_clean"
	filename_no_ext="$(basename "${filename_to_possibly_clean%.*}")"
	# debug "filename without extension: $filename_no_ext"
	ls $SOURCE/$filename_no_ext.* > /dev/null 2> /dev/null
	if [ $? -eq 0 ]; then
		echo "Found an equivalent for $filename_to_possibly_clean!"
		[ "$dryRun" = true ] && echo "   dry-run activated, ignoring..." || echo "   deleting $filename_to_possibly_clean..."
		[ ! "$dryRun" = true ] && rm $filename_to_possibly_clean
	else
		echo "File $filename_no_ext not found in $SOURCE, sparing..."
	fi
done
