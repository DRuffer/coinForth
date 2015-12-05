#!/bin/bash

# Script for building emacs etags file

# Reference
# ---------
#
# Options to use with 'etags' binary:
#
#  -a : Append to existing TAG file
#  -o : Where to place the TAG file
#
# find . -wholename '.*/.svn' -prune -or -print : skips the svn directories

# Command line alternative
# find . | grep -iv "svn" | grep -iv "git" | grep -iv "bin" | grep -iv "xls" | grep -iv "elf" | grep -iv "pdf" | grep -iv "tdt" | grep -iv "exe" | grep -iv "sfx" | grep -iv "csv" | grep -iv "gif" | grep -iv "tags" | grep -iv "zip" | grep -iv "mcp" | etags -

# Remove any existing tag file
if [ -e "TAGS" ];
then
  echo Removing current tag-file TAGS
  rm -f TAGS
fi

find . -wholename '.*/.svn' -prune \
       -or -name '*.c' \
       -or -name '*.h' \
       -or -name '*.S' \
       -or -name '*.s' \
       -or -name '*.asm' \
       -or -name '*.inc' \
| while read I; do etags -a $I -o TAGS; done

# Isn't awk great for do clever formatting like this!
wc -l TAGS | awk '{ print $2 " has " $1 " tags" }'
