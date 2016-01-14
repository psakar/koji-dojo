#!/bin/bash

set -x

if [ -d /opt/koji/noarch ]; then
	yum -y localinstall /opt/koji/noarch/koji-1*.rpm
else
	echo "No koji RPM to install!"
	echo "(TODO: install from EPEL)"
	exit 1
fi

mkdir /root/{.koji,bin}
echo "Generating user-specific koji client links and configs"
for userdir in $(ls -d /opt/koji-clients/*); do
	user=$(basename $userdir)
	echo "Adding: ${user} (${userdir})"

	cat <<EOF >> /root/.koji/config
[koji-${user}]
server = https://koji-hub/kojihub
authtype = ssl
cert = ${userdir}/client.crt
ca = ${userdir}/clientca.crt
serverca = ${userdir}/serverca.crt

EOF

	echo "Linking koji to: /root/bin/koji-${user}"
	ln -s /usr/bin/koji /root/bin/koji-${user}
done

echo "Generated configs are:"
cat /root/.koji/config

echo "Available user-specific koji commands are:"
ls -1 /root/bin/koji-*

ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key

IP=$(find-ip.py)

echo "SSHd listening on: ${IP}:22"
/usr/sbin/sshd -D