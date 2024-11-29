#!/bin/bash

# Exit on error
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 -m <models> [-t <threads>]"
    echo ""
    echo "Arguments:"
    echo "  -m <models>          Comma-separated list of Whisper models to download and test (e.g., large-v2,large-v3-turbo)"
    echo "  -t <threads>         Number of threads for compilation (default: auto-detect)"
    echo ""
    echo "Example:"
    echo "  $0 -m large-v2,large-v3-turbo,large-v3-turbo-q5_0 -t 8"
    exit 1
}

# Default values
threads=$(sysctl -n hw.ncpu) # Detect the number of available threads
models=""

# Parse command-line arguments
while getopts ":m:t:" opt; do
    case ${opt} in
        m) models="$OPTARG" ;;
        t) threads="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if models argument is provided
if [[ -z "$models" ]]; then
    echo "Error: At least one model is required."
    usage
fi

# Convert models into an array
IFS=',' read -r -a model_array <<< "$models"

# Ensure the sample file exists
sample_file="samples/jfk.wav"
if [[ ! -f "$sample_file" ]]; then
    echo "Sample file '$sample_file' not found. Downloading sample audio..."
    mkdir -p samples
    curl -o "$sample_file" -L "https://github.com/ggerganov/whisper.cpp/raw/master/samples/jfk.wav"
fi

# Clean and build the binary with Metal support (only once)
echo "Building whisper.cpp with Metal support..."
make clean
GGML_METAL=1 make -j"$threads"

# Rename the binary
binary_name="whisper_metal"
mv main "$binary_name"

# Download and test each model
for model in "${model_array[@]}"; do
    echo "Processing model: $model"

    # Check if the model is available
    if ! bash ./models/download-ggml-model.sh | grep -qw "$model"; then
        echo "Error: Model '$model' is not available."
        exit 1
    fi

    # Download the model
    echo "Downloading model: $model"
    bash ./models/download-ggml-model.sh "$model"

    # Test the binary with the model
    model_file="models/ggml-$model.bin"
    if [[ ! -f "$model_file" ]]; then
        echo "Error: Model file '$model_file' not found."
        exit 1
    fi
    echo "Testing model: $model"
    time ./"$binary_name" -m "$model_file" -f "$sample_file"
    echo ""
done

echo "All models built and tested successfully."
