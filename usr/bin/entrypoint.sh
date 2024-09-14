#! /bin/bash

# escape special characters (including: " to \", \ to \\)
escape_special() {
  echo $@ | awk '{gsub(/\\/,"\\\\");gsub(/"/,"\\\"")}1'
}

supervisord_conf_path=/etc/supervisor/conf.d/supervisord.conf

# Copy config file
cp $SMB_CONF_PATH /etc/samba/smb.conf

# Readd quotes to each argument, which had previously been removed when parsed by bash, and escape special characters.
# This esnures arguments are interpreted as is, without special characters affecting behaviour.
CLI_ARGS=""
for arg in "${@}"; do CLI_ARGS="$CLI_ARGS \"$( escape_special $arg )\""; done

# Collect arguments for environment vaiables
# Escaped here to allow awk to processs as is.
SAMBA_SH_ARGS="$(escape_special "$CLI_ARGS $SAMBA_SH_ARGS")"

if [[ $IMAGE_TARGET == "exporter" ]]; then
  # Modify supervisord.conf and exporter-supervisord.conf
  multiple_awk="\
sub(/<#@SAMBA_EXPORTER_STATUSD_ARGS>/,\"$SAMBA_EXPORTER_STATUSD_ARGS\");\
sub(/<#@SAMBA_EXPORTER_ARGS>/,\"$SAMBA_EXPORTER_ARGS\");"

  # Extract exporter config for healthcheck 
  [[ $SAMBA_EXPORTER_ARGS =~ [[:space:]^]-web\.listen-address[=[:space:]]([-\.[:alnum:]]+)(:([1-5][[:digit:]]{4}|[1-9][[:digit:]]{0,3}|6[0-4][[:digit:]]{3}|65[0-4][[:digit:]]{2}|655[0-2][[:digit:]]|6553[0-5]))?[[:space:]$] ]]
  address="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
  address=${address:-:9922}
  
  [[ $SAMBA_EXPORTER_ARGS =~ [[:space:]^]-web\.telemetry-path[=[:space:]](\/[-[:alnum:]@:%_\+.~#?&//=]*)[[:space:]$] ]]
  metrics_path=${BASH_REMATCH[1]:-/metrics}

  echo "$address$metrics_path" > /tmp/exporter-healthcheck-url
fi

cat "/dist$supervisord_conf_path" | \
awk "{sub(/<#@SAMBA_SH_ARGS>/,\"$SAMBA_SH_ARGS\")$multiple_awk}1" > $supervisord_conf_path

exec /usr/bin/supervisord -c $supervisord_conf_path
