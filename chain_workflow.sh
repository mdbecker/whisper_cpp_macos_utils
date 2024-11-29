#!/bin/bash

# Run QuickTime fix
echo "Running quicktime_fix.sh..."
bash quicktime_fix.sh

# Convert m4a to wav
echo "Running m4a_to_wav.sh..."
bash m4a_to_wav.sh

# Transcribe wav to text
echo "Running wav_to_txt_p.sh..."
bash wav_to_txt_p.sh
