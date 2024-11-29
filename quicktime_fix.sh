#!/bin/bash

# Set the source and destination directories
SRC_DIR=~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Autosave\ Information/
DEST_DIR=~/Documents/new_recordings

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Function to format the modification date and time
format_date() {
    local filepath="$1"
    date -r "$filepath" +"%Y-%m-%d_%H-%M"
}

# Function to get the parent directory
get_parent_dir() {
    local filepath="$1"
    dirname "$filepath"
}

# Find and copy all audio and video files from the source to the destination directory
find "$SRC_DIR" -type f \( -name "*.m4a" -o -name "*.mov" -o -name "*.mp4" \) | while read -r file; do
    # Get the modification date and time
    mod_date=$(format_date "$file")
    
    # Get the file extension
    extension="${file##*.}"
    
    # Construct the new filename
    new_filename="${mod_date}_Unknown.${extension}"
    
    # Copy the file to the destination directory with the new filename, preserving attributes
    cp -p "$file" "$DEST_DIR/$new_filename"
    
    # Verify the file was copied correctly
    if cmp -s "$file" "$DEST_DIR/$new_filename"; then
        echo "Copied and verified: \"$file\" to \"$DEST_DIR/$new_filename\""
        
        # Get the parent directory of the original file
        parent_dir=$(get_parent_dir "$file")
        
        # Forcefully delete the parent directory and its contents
        if [ -d "$parent_dir" ]; then
            rm -rf "$parent_dir"
            echo "Deleted directory and its contents: \"$parent_dir\""
        fi
    else
        echo "Failed to verify: \"$file\""
    fi
done

echo "All audio and video files have been copied, verified, and original directories deleted."