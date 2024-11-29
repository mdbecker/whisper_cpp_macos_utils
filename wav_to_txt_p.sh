#!/bin/bash

# Default directories
input_dir="${HOME}/git/whisper.cpp"
output_dir="${HOME}/git/whisper.cpp"

# Default number of parallel processes
parallel_jobs=7

# Default model
default_model="large-v3-turbo-q5_0"
selected_model="$default_model"

# Supported models
supported_models=("large-v3-turbo-q5_0" "large-v3-turbo" "large-v2")

# Parse arguments
while getopts "m:p:i:o:" opt; do
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
        i)
            # Set input directory
            input_dir="$OPTARG"
            ;;
        o)
            # Set output directory
            output_dir="$OPTARG"
            ;;
        *)
            echo "Usage: $0 [-m <model>] [-p <parallel_jobs>] [-i <input_dir>] [-o <output_dir>]"
            echo ""
            echo "Options:"
            echo "  -m <model>         Specify the model to use (default: $default_model)."
            echo "                     Supported models: ${supported_models[*]}"
            echo "  -p <parallel_jobs> Number of parallel jobs to run (default: $parallel_jobs)."
            echo "  -i <input_dir>     Directory containing input .wav files (default: $input_dir)."
            echo "  -o <output_dir>    Directory to save transcriptions (default: $output_dir)."
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
    local txt_file="$output_dir/$(basename "$file").txt"

    # Check if the txt file already exists in the output directory
    if [ ! -f "$txt_file" ]; then
        # If not, convert the wav to txt
        echo "Processing: $file"
        ./"$binary_name" -m "$model_file" -f "$file" -otxt -p 1 -t 1 -mc 223

        # Set the timestamp of the txt file to be the same as the wav file
        touch -r "$file" "$txt_file"
        rm "$file"
    fi
}

export -f process_file
export output_dir
export binary_name
export model_file

# Check if the input directory exists
if [[ ! -d "$input_dir" ]]; then
    echo "Error: Input directory '$input_dir' does not exist."
    exit 1
fi

# Find all wav files in input_dir and process them in parallel
find "$input_dir" -name "*.wav" | xargs -n 1 -P "$parallel_jobs" -I {} bash -c 'process_file "$@"' _ {}
