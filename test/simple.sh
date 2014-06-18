#!/bin/sh

dir=$(dirname $0)
. $dir/tools/config.prop

. $dir/tools/run-container.sh

echo "curl $IP"
curl $IP

$dir/tools/delete-container.sh
