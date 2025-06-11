#!/bin/bash
echo "=== Python Packages ==="
pip list || echo "pip error"

echo -e "\n=== PHP Extensions ==="
php -m || echo "php error"

echo -e "\n=== Go Tools (GOPATH/bin) ==="
ls $GOPATH/bin || echo "GOPATH not set or empty"

echo -e "\n=== Node Modules ==="
npm list -g --depth=0 || echo "npm error"

echo -e "\n=== C/Dev Libraries (partial check) ==="
dpkg -l | grep -E 'lib(curl|ssl|magic|jpeg|png|freetype|zlib)' || echo "no C libs matched"