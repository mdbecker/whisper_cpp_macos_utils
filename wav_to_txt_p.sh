#!/bin/bash

# Directory containing wav files
dir_one="/Users/mbecker/git/whisper.cpp"
dir_two="/Users/mbecker/git/whisper.cpp"

# Default number of parallel processes
parallel_jobs=7

# Default model
default_model="large-v3-turbo-q5_0"
selected_model="$default_model"

# Supported models
supported_models=("large-v3-turbo-q5_0" "large-v3-turbo" "large-v2")

# Parse arguments
while getopts "m:p:" opt; do
    case ${opt} in
        m) 
            # Check if the specified model is valid
            if [[ " ${supported_models[@]} " =~ " ${OPTARG} " ]]; then
                selected_model="$OPTARG"
            else
                echo "Invalid model specified. Supported models: ${supported_models[*]}"
                exit 1
            fi
            ;;
        p)
            # Validate parallel jobs argument
            if [[ $OPTARG =~ ^[1-9]$ ]]; then
                parallel_jobs=$OPTARG
            else
                echo "Invalid number of parallel jobs. Must be an integer between 1 and 9."
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 [-m <model>] [-p <parallel_jobs>]"
            echo ""
            echo "Options:"
            echo "  -m <model>         Specify the model to use (default: $default_model)."
            echo "                     Supported models: ${supported_models[*]}"
            echo "  -p <parallel_jobs> Number of parallel jobs to run (default: $parallel_jobs)."
            exit 1
            ;;
    esac
done

# Ensure the model file exists
model_file="models/ggml-${selected_model}.bin"
if [[ ! -f "$model_file" ]]; then
    echo "Error: Model file '$model_file' not found."
    echo "Hint: Available model files are:"
    ls models/*.bin
    exit 1
fi

# Ensure the binary exists
binary_name="whisper_metal"
if [[ ! -f "$binary_name" ]]; then
    echo "Error: Binary '$binary_name' not found. Please build it first."
    exit 1
fi

# Function to process a single file
process_file() {
    local file=$1
    local txt_file="$dir_two/$(basename "$file").txt"

    # Check if the txt file already exists in dir_two
    if [ ! -f "$txt_file" ]; then
        # If not, convert the wav to txt
        echo "$file"
        ./"$binary_name" -m "$model_file" -f "$file" -otxt -p 1 -t 1 -mc 223

        # Set the timestamp of the txt file to be the same as the wav file
        touch -r "$file" "$txt_file"
        rm "$file"
    fi
}

export -f process_file
export dir_two
export binary_name
export model_file

# Find all wav files in dir_one and process them in parallel
find "$dir_one" -name "*.wav" | xargs -n 1 -P $parallel_jobs -I {} bash -c 'process_file "$@"' _ {}
