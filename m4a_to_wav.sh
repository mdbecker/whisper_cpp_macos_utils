#!/bin/bash

# Default directories
DEFAULT_INPUT_DIR="$HOME/Documents/new_recordings"
DEFAULT_OUTPUT_DIR="$HOME/git/whisper.cpp"
DEFAULT_PROCESSED_DIR="$HOME/Documents/old_recordings"

# Function to display help message
usage() {
    echo "Usage: $0 [-i <input_dir>] [-o <output_dir>] [-p <processed_dir>]"
    echo ""
    echo "Options:"
    echo "  -i <input_dir>      Directory containing .m4a files to process (default: $DEFAULT_INPUT_DIR)"
    echo "  -o <output_dir>     Directory to save .wav files (default: $DEFAULT_OUTPUT_DIR)"
    echo "  -p <processed_dir>  Directory to move processed .m4a files (default: $DEFAULT_PROCESSED_DIR)"
    echo "  -h                  Display this help message"
    exit 1
}

# Parse command-line arguments
input_dir="$DEFAULT_INPUT_DIR"
output_dir="$DEFAULT_OUTPUT_DIR"
processed_dir="$DEFAULT_PROCESSED_DIR"

while getopts ":i:o:p:h" opt; do
    case $opt in
        i) input_dir="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        p) processed_dir="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Ensure directories exist
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' does not exist."
    exit 1
fi

if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory '$output_dir' does not exist. Creating it..."
    mkdir -p "$output_dir"
fi

if [ ! -d "$processed_dir" ]; then
    echo "Error: Processed directory '$processed_dir' does not exist. Creating it..."
    mkdir -p "$processed_dir"
fi

# Process .m4a files
for m4a_file in "$input_dir"/*.m4a; do
    # Skip if no .m4a files are found
    [ -e "$m4a_file" ] || { echo "No .m4a files found in '$input_dir'."; exit 0; }

    # Get base file name without extension
    base_name="${m4a_file%.*}"

    # Construct output .wav file path
    wav_file="$output_dir/$(basename "$base_name").wav"

    # Construct transcription file path
    wav_txt_file="$output_dir/$(basename "$base_name").wav.txt"

    # Check if output .wav or transcription file already exists
    if [ ! -f "$wav_file" ] && [ ! -f "$wav_txt_file" ]; then
        echo "Processing: $m4a_file"

        # Convert .m4a to .wav
        ffmpeg -i "$m4a_file" -ar 16000 -ac 1 -c:a pcm_s16le "$wav_file"

        # Preserve original timestamp on .wav file
        touch -r "$m4a_file" "$wav_file"

        # Move processed .m4a file to the processed directory
        mv "$m4a_file" "$processed_dir/$(basename "$m4a_file")"
    else
        echo "Skipping: $m4a_file (output or transcription already exists)"
    fi
done

echo "Processing completed."
