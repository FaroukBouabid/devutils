#!/bin/bash

# The MIT License (MIT)

# Copyright (c) 2025 Farouk Bouabid

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This script is used to validate commits for the current branch HEAD against
# a given base commit --> Useful to check if each commit builds for example.

set -e

function help_menu () {
  echo "Usage: `basename $0` -b base_commit_hash -x \"validation_command\""
}

# Reset in case getopts has been used previously in the shell.
OPTIND=1

while getopts ":hb:x:" opt; do
   case $opt in
      h) help_menu
         exit 0;;
      b) base=$OPTARG ;;
      x) validation_cmd=$OPTARG ;;
      :) printf "Missing argument for -%s\n" "$OPTARG"
         help_menu
         exit 1;;
     \?) echo "Illegal option -$OPTARG !"
         help_menu
         exit 1;;
   esac
done

shift $((OPTIND-1))

if [ -z "$base" ] ; then
  echo "Missing base commit !"
  help_menu
  exit 1
fi

if [ -z "$validation_cmd" ] ; then
  echo "Missing validation command !"
  help_menu
  exit 1
fi

set +e

git rebase --autostash $base --exec "$validation_cmd"
result=$?

set -e

if [ $result -eq 0 ] ; then
  echo "+-------------------------+"
  echo "All commits have no errors"
  echo "+-------------------------+"
elif [ $result -eq 1 ] ; then
  err_commit=$(git rev-parse --short HEAD)
  echo "+------------------------+"
  echo "Commit $err_commit has errors"
  echo "+------------------------+"
  git --no-pager show --stat $err_commit
  git rebase --abort
fi

exit $result
