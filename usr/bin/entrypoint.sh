#! /bin/bash

SUPERVISORD_CONF_PATH=/etc/supervisor/conf.d/supervisord.conf

# Copy config file
cp $SMB_CONF_PATH /etc/samba/smb.conf

# Collect arguments for environment vaiables
SAMBA_SH_ARGS="$@ $SAMBA_SH_ARGS"

# Modify supervisord.conf and exporter-supervisord.conf
MULTIPLE_AWK=$([[ $IMAGE_TARGET == "exporter" ]] && echo "\
sub(/<#@SAMBA_EXPORTER_STATUSD_ARGS>/,\"$SAMBA_EXPORTER_STATUSD_ARGS\");\
sub(/<#@SAMBA_EXPORTER_ARGS>/,\"$SAMBA_EXPORTER_ARGS\");")
cat "/dist$SUPERVISORD_CONF_PATH" | \
awk "{sub(/<#@SAMBA_SH_ARGS>/,\"$SAMBA_SH_ARGS\")$MULTIPLE_AWK}1" > $SUPERVISORD_CONF_PATH

exec /usr/bin/supervisord -c $SUPERVISORD_CONF_PATH
