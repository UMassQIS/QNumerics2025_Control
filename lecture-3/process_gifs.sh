#!/bin/env bash

find . -name "*.gif" ! -name "*_processed*" | while read -r gif; do
    dir=$(dirname "$gif")
    base=$(basename "$gif" .gif)
    output="$dir/${base}_processed.gif"
    echo "Processing: $gif -> $output"
    convert "$gif" \( +clone -set delay 300 \) -swap -2,-1 +delete "$output"
done
