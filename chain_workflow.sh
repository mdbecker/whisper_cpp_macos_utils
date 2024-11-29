#!/bin/bash

# Default values
QT_SRC_DIR="$HOME/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave Information/"
QT_DEST_DIR="$HOME/Documents/new_recordings"
M4A_INPUT_DIR="$QT_DEST_DIR"  # Input for m4a_to_wav.sh
M4A_OUTPUT_DIR="$HOME/git/whisper.cpp"  # Output WAV files
M4A_PROCESSED_DIR="$HOME/Documents/old_recordings"
WAV_INPUT_DIR="$M4A_OUTPUT_DIR"  # Input for wav_to_txt_p.sh
WAV_OUTPUT_DIR="$M4A_OUTPUT_DIR"  # Output TXT files
WHISPER_MODEL="large-v3-turbo-q5_0"
PARALLEL_JOBS=7

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --qt-src <path>         Source directory for QuickTime autosave files (default: $QT_SRC_DIR)"
    echo "  --qt-dest <path>        Destination directory for QuickTime files (default: $QT_DEST_DIR)"
    echo "  --m4a-output <path>     Directory to save WAV files and transcriptions (default: $M4A_OUTPUT_DIR)"
    echo "  --processed-dir <path>  Directory to move processed .m4a files (default: $M4A_PROCESSED_DIR)"
    echo "  --whisper-model <model> Whisper model to use (default: $WHISPER_MODEL)"
    echo "  --parallel-jobs <num>   Number of parallel jobs for transcription (default: $PARALLEL_JOBS)"
    echo "  -h, --help              Display this help message"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --qt-src) QT_SRC_DIR="$2"; shift ;;
        --qt-dest) QT_DEST_DIR="$2"; M4A_INPUT_DIR="$2"; shift ;;
        --m4a-output) M4A_OUTPUT_DIR="$2"; WAV_INPUT_DIR="$2"; WAV_OUTPUT_DIR="$2"; shift ;;
        --processed-dir) M4A_PROCESSED_DIR="$2"; shift ;;
        --whisper-model) WHISPER_MODEL="$2"; shift ;;
        --parallel-jobs) PARALLEL_JOBS="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Ensure directories are consistent
if [[ "$M4A_INPUT_DIR" != "$QT_DEST_DIR" ]]; then
    echo "Warning: M4A input directory does not match QuickTime destination directory."
    echo "Setting M4A input directory to QuickTime destination directory."
    M4A_INPUT_DIR="$QT_DEST_DIR"
fi

if [[ "$WAV_INPUT_DIR" != "$M4A_OUTPUT_DIR" ]]; then
    echo "Warning: WAV input directory does not match M4A output directory."
    echo "Setting WAV input directory to M4A output directory."
    WAV_INPUT_DIR="$M4A_OUTPUT_DIR"
    WAV_OUTPUT_DIR="$M4A_OUTPUT_DIR"
fi

# Run QuickTime fix
echo "Running quicktime_fix.sh..."
bash quicktime_fix.sh -s "$QT_SRC_DIR" -d "$QT_DEST_DIR"

# Convert m4a to wav
echo "Running m4a_to_wav.sh..."
bash m4a_to_wav.sh -i "$M4A_INPUT_DIR" -o "$M4A_OUTPUT_DIR" -p "$M4A_PROCESSED_DIR"

# Transcribe wav to text
echo "Running wav_to_txt_p.sh..."
bash wav_to_txt_p.sh -m "$WHISPER_MODEL" -p "$PARALLEL_JOBS" -i "$WAV_INPUT_DIR" -o "$WAV_OUTPUT_DIR"
