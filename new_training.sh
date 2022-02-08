#!/bin/bash

# ============================================================================
# This script is used for every new training of DeepSpeech
# ============================================================================


print_help () {
	echo "new_training.sh : Create a new repo with all resources needed by DeepSpeech for a training"
	echo "Usage : ./new_training.sh [OPTIONAL: repo_name]"
}


# Check if argument is present
if [ $# == 0 ]; then
    echo "No args, the repo name will be new_training";
    filename="new_training"	
else
    # Check if help argument is present
    if [ $1 == '-h' ]; then
        print_help
            exit 0
    fi
    filename=$1
fi



echo "Creating repos and moving files in" $filename
mkdir ../$filename