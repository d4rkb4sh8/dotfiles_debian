#!/bin/bash

# Define the input directory (change this to your target directory)
input_dir="$HOME/html"
output_dir="$HOME/markdown"

# Ensure output directory exists
mkdir -p "$output_dir"

# Iterate over all HTML files in the input directory
for file in "$input_dir"/*.html; do
  # Get the filename without extension
  base=$(basename "$file" .html)
  
  # Convert HTML to Markdown using Pandoc
  pandoc -s "$file" -o "${output_dir}/${base}.md"
done
