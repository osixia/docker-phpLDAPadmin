#!/bin/sh

# Usage
# sudo ./test.sh 
# add -v for verbose mode (or type whatever you like !) :p

. test/tools/run.sh

run_test tools/build-container.sh "Successfully built"
run_test simple.sh "Use the menu to the left to navigate"

. test/tools/end.sh

