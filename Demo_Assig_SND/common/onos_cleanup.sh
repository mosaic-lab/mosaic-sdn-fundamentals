#!/usr/bin/env bash

# Remove all stale devices from ONOS
echo "Removing all devices from ONOS..."

curl -s -u onos:rocks http://localhost:8181/onos/v1/devices | \
  python3 -c "import sys,json; [print(d['id']) for d in json.load(sys.stdin)['devices']]" | \
  xargs -I{} curl -s -u onos:rocks -X DELETE http://localhost:8181/onos/v1/devices/{}

echo "Done."
