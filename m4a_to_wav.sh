#!/bin/bash

# Directory containing m4a files
dir_one="/Users/mbecker/Documents/new_recordings"

# Directory containing wav files
dir_two="/Users/mbecker/git/whisper.cpp"

# Directory to move processed m4a files
dir_old="/Users/mbecker/Documents/old_recordings"

# Loop through all m4a files in dir_one
for file in "$dir_one"/*.m4a; do
    # Get the base name of the file without extension
    base_name="${file%.*}"

    # Construct the name of the corresponding wav file in dir_two
    wav_file="$dir_two/$(basename "$base_name").wav"

    # Construct the name of the corresponding wav.txt file in dir_two
    wav_txt_file="$dir_two/$(basename "$base_name").wav.txt"

    # Check if the wav file or wav.txt file already exists in dir_two
    if [ ! -f "$wav_file" ] && [ ! -f "$wav_txt_file" ]; then
        # If neither file exists, convert the m4a file to wav and save it in dir_two
        echo "$file"
        ffmpeg -i "$file" -ar 16000 -ac 1 -c:a pcm_s16le "$wav_file"

        # Set the timestamp of the wav file to be the same as the m4a file
        touch -r "$file" "$wav_file"

        # Move the processed m4a file to the old_recordings directory
        mv "$file" "$dir_old/$(basename "$file")"
    fi
done
