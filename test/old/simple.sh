#!/bin/sh

dir=$(dirname $0)
. $dir/tools/run-container.sh

echo "curl --insecure https://$IP"
curl --insecure https://$IP

$dir/tools/delete-container.sh
