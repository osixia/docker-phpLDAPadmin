#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

. test/config
. test/tools/run.sh

run_test tools/build-container.sh "Successfully built"
run_test simple.sh "Use the menu to the left to navigate"
run_test link.sh "Logged in as:"

. test/tools/end.sh
