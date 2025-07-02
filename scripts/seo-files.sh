#!/bin/bash

# URL-safe file and folder name converter
# Usage: ./seo-files.sh <directory_path>

set -e

# Function to convert a string to URL-safe format
url_safe_name() {
    local name="$1"

    # Convert to lowercase
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    # Replace spaces with hyphens
    name=$(echo "$name" | sed 's/ /-/g')

    # Replace underscores with hyphens (optional, comment out if you want to keep underscores)
    name=$(echo "$name" | sed 's/_/-/g')

    # Remove or replace special characters, keep only alphanumeric, hyphens, dots, and underscores
    name=$(echo "$name" | sed 's/[^a-z0-9\.\-]//g')

    # Remove multiple consecutive hyphens
    name=$(echo "$name" | sed 's/-\+/-/g')

    # Remove leading and trailing hyphens
    name=$(echo "$name" | sed 's/^-\+\|-\+$//g')

    echo "$name"
}

# Function to rename files and directories recursively
rename_files_recursive() {
    local dir="$1"

    # Process files first (to avoid issues with directory renames)
    find "$dir" -type f -print0 | while IFS= read -r -d '' file; do
        local dirname=$(dirname "$file")
        local basename=$(basename "$file")
        local extension=""
        local filename_without_ext="$basename"

        # Extract extension if present
        if [[ "$basename" == *.* ]]; then
            extension=".${basename##*.}"
            filename_without_ext="${basename%.*}"
        fi

        # Convert filename to URL-safe
        local new_filename=$(url_safe_name "$filename_without_ext")
        local new_basename="${new_filename}${extension}"
        local new_path="${dirname}/${new_basename}"

        # Only rename if the name has changed
        if [[ "$basename" != "$new_basename" ]]; then
            # Handle conflicts by adding a number suffix
            local counter=1
            local temp_new_path="$new_path"
            while [[ -e "$temp_new_path" ]]; do
                if [[ -n "$extension" ]]; then
                    temp_new_path="${dirname}/${new_filename}-${counter}${extension}"
                else
                    temp_new_path="${dirname}/${new_filename}-${counter}"
                fi
                counter=$((counter + 1))
            done
            new_path="$temp_new_path"
            new_basename=$(basename "$new_path")

            echo "Renaming file: '$basename' -> '$new_basename'"
            mv "$file" "$new_path"
        fi
    done

    # Process directories (deepest first to avoid path issues)
    find "$dir" -type d -depth | while IFS= read -r directory; do
        # Skip the root directory
        if [[ "$directory" == "$dir" ]]; then
            continue
        fi

        local parent_dir=$(dirname "$directory")
        local dir_basename=$(basename "$directory")
        local new_dirname=$(url_safe_name "$dir_basename")
        local new_dir_path="${parent_dir}/${new_dirname}"

        # Only rename if the name has changed
        if [[ "$dir_basename" != "$new_dirname" ]]; then
            # Handle conflicts by adding a number suffix
            local counter=1
            local temp_new_dir_path="$new_dir_path"
            while [[ -e "$temp_new_dir_path" ]]; do
                temp_new_dir_path="${parent_dir}/${new_dirname}-${counter}"
                counter=$((counter + 1))
            done
            new_dir_path="$temp_new_dir_path"
            new_dirname=$(basename "$new_dir_path")

            echo "Renaming directory: '$dir_basename' -> '$new_dirname'"
            mv "$directory" "$new_dir_path"
        fi
    done
}

# Main script
main() {
    # Check if directory argument is provided
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <directory_path>"
        echo "Example: $0 /path/to/your/folder"
        exit 1
    fi

    local target_dir="$1"

    # Check if the directory exists
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' does not exist."
        exit 1
    fi

    # Convert to absolute path
    target_dir=$(cd "$target_dir" && pwd)

    echo "Converting files and folders in: $target_dir"
    echo "This will recursively rename all files and folders to be URL-safe."
    echo "Press Ctrl+C to cancel, or Enter to continue..."
    read -r

    # Start the recursive renaming process
    rename_files_recursive "$target_dir"

    echo "Done! All files and folders have been converted to URL-safe names."
}

# Run the main function with all arguments
main "$@"
