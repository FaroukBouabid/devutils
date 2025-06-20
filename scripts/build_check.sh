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

# This script is used to validate commits for the current branch diff against
# upstream/main --> Useful to check if each commit builds.

set -e

# !!!   IMPORTANT   !!!
# Validation executable is to be provided as argument 1.
# Validation executable should store output/log to its 1st argument (provided by this script)
# Script assumes upstream/main as the default base branch

validation_script=$1

sigint_handler() {
  if $rebase_in_progress ; then
    git rebase --abort
  fi
  exit 0
}

# Handle Ctrl-C keyboard interrupt
trap sigint_handler SIGINT

# Create logfile
echo "###   Error Summary   ###" > /tmp/buildall.log

# Handle errors
set +e

rebase_in_progress=true

# Execute validation script for each commit
git rebase $(git rev-parse upstream/main)~ --autostash \
  --exec "$validation_script /tmp/buildall.log"

# Exit on errors
set -e

if [ $? -eq 0 ]; then
  # Rebase succeeded
  rebase_in_progress=false
  cat /tmp/buildall.log
  echo "#########################"
  # Cleanup
  rm -rf buildall.log
  exit 0
fi

# Rebase failed
exit 1
