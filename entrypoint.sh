#! /bin/bash

SUPERVISORD_CONF_PATH=/etc/supervisor/conf.d/supervisord.conf

# Copy config file
cp $SMB_CONF_PATH /etc/samba/smb.conf

# Collect arguments from environment vaiables
SAMBA_SH_ARGS="$@ $SAMBA_SH_ARGS"

# Modify supervisord.conf
echo "$( awk "{sub(/<#\!SAMBA_SH_ARGS>/,\"$SAMBA_SH_ARGS\")}1" $SUPERVISORD_CONF_PATH )" > $SUPERVISORD_CONF_PATH

exec /usr/bin/supervisord -c $SUPERVISORD_CONF_PATH
