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
BASE_PATH=
TEST_FLAG=0
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -p|--path)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                BASE_PATH=$2
                shift
            else
                die 'ERROR: "--path" requires a non-empty option argument.'
            fi
            ;;
        --path=?*)
            BASE_PATH=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --path=)         # Handle the case of an empty --file=
            die 'ERROR: "--path" requires a non-empty option argument.'
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        -t|--test)
            TEST_FLAG=1
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

echo "Searching $BASE_PATH"

if [ "$TEST_FLAG" -eq "1" ]; then
   echo "Test flag active, will only convert first file and not delete source";
fi

# find $BASE_PATH -type f -name "*.avi" -exec echo {} \; -exec message='The secret code is 12345' echo "${message//[0-9]/X}" \;

while IFS= read -r -d '' -u 9
do

    oldfile=$REPLY
    echo "Found file: $oldfile" 

    newfile="${REPLY//.avi/.mp4}"

    echo "Transforming to file: $newfile" 

    HandBrakeCLI -O -Z "Fast 1080p30" -i "$oldfile" -o "$newfile" -v=1

    if [ "$TEST_FLAG" -eq "1" ]; then
        echo "Test run completed"
        exit;    
    fi

    rm "$oldfile"

done 9< <( find $BASE_PATH -type f -name "*.avi" -exec printf '%s\0' {} + )

 