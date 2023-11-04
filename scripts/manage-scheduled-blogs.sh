#!/bin/bash

# Get today's date in the format used in the .md files
today=$(date +"%Y-%m-%d")

# Initialize result to "false"
result="false"

# Loop over all .md files in the ./content/** directory
for file in $(find ./content -type f -name "*.md")
do
    # Check if file contains "draft = false" and the publish date that equals today's date
    if grep -q "date = \"$today\"" $file && grep -q "draft = false" $file
    then
      # If both conditions are met, set result to "true" and break the loop
      result="true"
      echo "Found blog posts to publish - triggering deploy..."
      curl -X POST -d {} https://api.netlify.com/build_hooks/6544a6c087c66f60dc7858e9
      break
    fi
done

# If not all the conditions are met, skip deployment
if [ "$result" = "false" ]
then
  echo "Nothing to publish..skipping.."
fi

echo "Done!"