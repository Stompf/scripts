#!/bin/bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

show_help() {
    echo 'help help'
}


# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
FILE_PATH=
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -p|--path)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                FILE_PATH=$2
                shift
            else
                die 'ERROR: "--path" requires a non-empty option argument.'
            fi
            ;;
        --path=?*)
            FILE_PATH=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --path=)         # Handle the case of an empty --file=
            die 'ERROR: "--path" requires a non-empty option argument.'
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        -k|--keep)
            KEEP_FLAG=1
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

echo "Searching $FILE_PATH"

if [ "$KEEP_FLAG" ]; then
   echo "Test flag active, will only convert first file and not delete source";
fi

oldfile=$FILE_PATH
echo "Found file: $oldfile" 

newfile="${FILE_PATH//.mp4/.new.mp4}"

echo "Transforming to file: $newfile" 

HandBrakeCLI -O -Z "Fast 1080p30" -i "$oldfile" -o "$newfile" -v=1

if [ "$KEEP_FLAG" ]; then
    echo "Test run completed"
    exit;
fi

rm "$oldfile"


 