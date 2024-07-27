#!/bin/bash

# Ensure exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <archive-file>"
    exit 1
fi

archive_file=$1
file_ext="${archive_file##*.}"
output_dir="temp_workspace"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Functions for encoding
encode_to_base64() {
    echo -n "$1" | base64
}

encode_to_base32() {
    echo -n "$1" | base32
}

encode_to_hex() {
    echo -n "$1" | xxd -p
}

# Fetch the input string from the first file in the output directory
input_text=$(head -n 1 "$output_dir"/* 2>/dev/null)
if [ -z "$input_text" ]; then
    echo "No input string found in $output_dir."
    exit 1
fi

echo "$input_text" >> safekeeping/Passwords
base64_text=$(encode_to_base64 "$input_text")
base32_text=$(encode_to_base32 "$input_text")
hex_text=$(encode_to_hex "$input_text")

# Clean the output directory
rm -rf "$output_dir"/*

# Attempt to unzip the file using different encodings
if [ "$file_ext" == "7z" ]; then
    7z x "$archive_file" -p"$input_text" -o"$output_dir" 2>/dev/null
    7z x "$archive_file" -p"$hex_text" -o"$output_dir" 2>/dev/null
    7z x "$archive_file" -p"$base32_text" -o"$output_dir" 2>/dev/null
    7z x "$archive_file" -p"$base64_text" -o"$output_dir" 2>/dev/null
elif [ "$file_ext" == "zip" ]; then
    unzip -P "$input_text" "$archive_file" -d "$output_dir" 2>/dev/null
    unzip -P "$hex_text" "$archive_file" -d "$output_dir" 2>/dev/null
    unzip -P "$base32_text" "$archive_file" -d "$output_dir" 2>/dev/null
    unzip -P "$base64_text" "$archive_file" -d "$output_dir" 2>/dev/null
else
    echo "Unsupported file format: $file_ext"
    exit 1
fi

# Remove the original archive file
rm "$archive_file"

# Move the extracted file and execute script.sh
extracted_file=$(basename $(ls "$output_dir"/*.{zip,7z} 2>/dev/null))
if [ -z "$extracted_file" ]; then
    echo "No files extracted to $output_dir."
    exit 1
fi

mv "$output_dir/$extracted_file" ./
echo "Executing script.sh with $extracted_file"
sleep 2
bash script.sh "$extracted_file"
