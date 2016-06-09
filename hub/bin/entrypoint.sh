#!/bin/bash

build-koji.sh
setup.sh

IP=$(find-ip.py)

echo "Starting ssh on ${IP}"
/etc/init.d/sshd start
echo "Starting HTTPd on ${IP}"
httpd -D FOREGROUND
