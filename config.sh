#! /bin/bash

cp $SMB_CONF_PATH /etc/samba/smb.conf

exec /sbin/tini -- /usr/bin/samba.sh "$@"
