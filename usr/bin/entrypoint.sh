#! /bin/bash

SUPERVISORD_CONF_PATH=/etc/supervisor/conf.d/supervisord.conf

# Copy config file
cp $SMB_CONF_PATH /etc/samba/smb.conf

# Collect arguments for environment vaiables
SAMBA_SH_ARGS="$@ $SAMBA_SH_ARGS"

if [[ $IMAGE_TARGET == "exporter" ]]; then
  # Modify supervisord.conf and exporter-supervisord.conf
  MULTIPLE_AWK="\
sub(/<#@SAMBA_EXPORTER_STATUSD_ARGS>/,\"$SAMBA_EXPORTER_STATUSD_ARGS\");\
sub(/<#@SAMBA_EXPORTER_ARGS>/,\"$SAMBA_EXPORTER_ARGS\");"

  # Extract exporter config for healthcheck 
  [[ $SAMBA_EXPORTER_ARGS =~ -web\.listen-address(=|[[:space:]])([-\.[:alnum:]]*)(:([1-5][[:digit:]]{4}|[1-9][[:digit:]]{0,3}|6[0-4][[:digit:]]{3}|65[0-4][[:digit:]]{2}|655[0-2][[:digit:]]|6553[0-5]))? ]]
  ADDRESS="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
  ADDRESS=${ADDRESS:-:9922}
  
  [[ $SAMBA_EXPORTER_ARGS =~ -web\.telemetry-path(=|[[:space:]])(\/[-[:alnum:]@:%_\+.~#?&//=]*) ]]
  METRICS_PATH=${BASH_REMATCH[2]:-/metrics}

  echo "$ADDRESS$METRICS_PATH" > /tmp/exporter-healthcheck-url
fi
cat "/dist$SUPERVISORD_CONF_PATH" | \
awk "{sub(/<#@SAMBA_SH_ARGS>/,\"$SAMBA_SH_ARGS\")$MULTIPLE_AWK}1" > $SUPERVISORD_CONF_PATH

exec /usr/bin/supervisord -c $SUPERVISORD_CONF_PATH
