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
    echo "  $0 -m large-v2,large-v2-q5_1,large-v2-q8_0,large-v3-turbo-q8_0 -t 8"
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

# Build Whisper.cpp with METAL support using CMake
binary_name="whisper_metal"
echo "Building whisper.cpp with Metal support..."
rm -rf build   # Remove old build directory
cmake -B build -DGGML_METAL=1
cmake --build build --config Release -j"$threads"

# Move compiled binary to expected location
mv build/bin/whisper-cli "$binary_name"

# Fetch available models from the downloader script
available_models=$(bash ./models/download-ggml-model.sh 2>&1 | grep -Eo 'large-[^ ]+')

# Process each model
for model in "${model_array[@]}"; do
    echo "Processing model: $model"

    model_file="models/ggml-$model.bin"

    # Check if the model is already available
    if [[ -f "$model_file" ]]; then
        echo "Model '$model' already exists. Skipping download and quantization."
    else
        # Check if the model is directly downloadable
        if echo "$available_models" | grep -qw "$model"; then
            echo "Model '$model' is available for download."
            echo "Downloading model: $model"
            bash ./models/download-ggml-model.sh "$model"
        else
            echo "Model '$model' is not available for direct download. Attempting manual quantization."

            # Extract base model name and quantization type
            base_model="${model%-q*}"   # Extract base model (e.g., "large-v2" from "large-v2-q5_1")
            quant_type="${model##*-}"   # Extract quant type (e.g., "q5_1" from "large-v2-q5_1")
            base_model_file="models/ggml-$base_model.bin"
            quantized_model_file="models/ggml-$model.bin"

            echo "Extracted base model: $base_model"
            echo "Extracted quantization type: $quant_type"

            # Ensure the base model exists before quantizing
            if [[ ! -f "$base_model_file" ]]; then
                echo "Base model '$base_model' not found. Downloading..."
                bash ./models/download-ggml-model.sh "$base_model"

                # Verify base model was successfully downloaded
                if [[ ! -f "$base_model_file" ]]; then
                    echo "Error: Base model '$base_model' failed to download."
                    exit 1
                fi
            fi

            # Perform quantization
            echo "Quantizing $base_model to $model ($quant_type)..."
            ./build/bin/quantize "$base_model_file" "$quantized_model_file" "$quant_type"

            # Ensure quantization was successful
            if [[ ! -f "$quantized_model_file" ]]; then
                echo "Error: Quantization failed. Model file '$quantized_model_file' not found."
                exit 1
            fi
        fi
    fi

    # Verify model file exists before testing
    if [[ ! -f "$model_file" ]]; then
        echo "Error: Model file '$model_file' not found."
        exit 1
    fi

    # Test the binary with the model
    echo "Testing model: $model"
    time ./$binary_name -m "$model_file" -f "$sample_file"
    echo ""
done

echo "All models downloaded, quantized (if necessary), and tested successfully."
