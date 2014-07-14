#!/bin/bash

# Build the jekyll site.
jekyll build > /dev/null 2>&1
if [ $? = 0 ]
then
  echo "Jekyll build successful"
else
  echo "Jekyll build failed"
  exit 1
fi

# Get the latest commit SHA in 'source'
last_SHA=( $(git log -n 1 --pretty=oneline) )

# Commit the changes to the gh-pages branch
message="Updated built site from 'source' - $last_SHA"
git add -A .
git commit -m "$message" > /dev/null 2>&1

# Push the source to the server
git push origin master > /dev/null 2>&1
if [ $? = 0 ]
then
  echo "Source push successful"
else
  echo "Source push failed"
  exit 1
fi

# Copy the contents of the '_site' folder in the
# working directory to a temporary folder.
# The name of the temporary folder will be the
# last commit SHA, to prevent possible conflicts
# with other folder names.
tmp_dir="temp_$last_SHA"
mkdir ~/$tmp_dir
cp -rf ./_site/* ~/$tmp_dir

# Remove the current contents of the built branch and
# replace them with the contents of the temp folder
git checkout gh-pages > /dev/null 2>&1
current_dir=${PWD}
rm -r $current_dir/*
git rm -r --cached * > /dev/null 2>&1
cp -r ~/$tmp_dir/* $current_dir

# Commit the changes to the gh-pages branch
message="Updated built site from 'source' - $last_SHA"
git add .
git commit -m "$message" > /dev/null 2>&1

# Delete the temporary folder
rm -r ~/$tmp_dir

# Push new site to server
git push origin gh-pages > /dev/null 2>&1
if [ $? = 0 ]
then
  echo "Site push successful"
else
  echo "Site push failed"
  exit 1
fi

# Switch back to source
git checkout master > /dev/null 2>&1
