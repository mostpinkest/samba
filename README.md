[![logo](https://raw.githubusercontent.com/logicer16/samba/master/logo.jpg)](https://www.samba.org)

# Samba

Samba docker container

A drop-in replacement for [dperson/samba](https://github.com/dperson/samba) with optional support for [imker25/samba_exporter](https://github.com/imker25/samba_exporter/)

# What is Samba?

Since 1992, Samba has provided secure, stable and fast file and print services
for all clients using the SMB/CIFS protocol, such as all versions of DOS and
Windows, OS/2, Linux and many others.

# How to use this image

This image comes in two variants:
* `logicer16/samba:latest`: A modified version of [dperson/samba](https://github.com/dperson/samba), with additional support for a custom config.
* `logicer16/samba:exporter`: The same as `logicer16/samba:latest` with [imker25/samba_exporter](https://github.com/imker25/samba_exporter/) running alongside it on port `9922`.

> [!WARNING]  
> In its current state, `logicer16/samba:exporter` is considered unstable. Do not expect issues to be resolved within any reasonable timeframe. Suggestions and PRs are still welcomed and encouraged.

By default there are no shares configured, additional ones can be added.

## Hosting a Samba instance

    sudo docker run -it -p 139:139 -p 445:445 -d logicer16/samba -p

OR set local storage:

    sudo docker run -it --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d logicer16/samba -p

OR run with exporter:

    sudo docker run -it -p 139:139 -p 445:445 -p 9922:9922 -d \
                logicer16/samba:exporter -p

## Configuration

    sudo docker run -it --rm logicer16/samba -h
    Usage: samba.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -c "<from:to>" setup character mapping for file/directory names
                    required arg: "<from:to>" character mappings separated by ','
        -G "<section;parameter>" Provide generic section option for smb.conf
                    required arg: "<section>" - IE: "share"
                    required arg: "<parameter>" - IE: "log level = 2"
        -g "<parameter>" Provide global option for smb.conf
                    required arg: "<parameter>" - IE: "log level = 2"
        -i "<path>" Import smbpassword
                    required arg: "<path>" - full file path in container
        -n          Start the 'nmbd' daemon to advertise the shares
        -p          Set ownership and permissions on the shares
        -r          Disable recycle bin for shares
        -R "<group> <user> [...users]" Add user(s) to group
        -S          Disable SMB2 minimum version
        -s "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"
                    Configure a share
                    required arg: "<name>;</path>"
                    <name> is how it's called for clients
                    <path> path to share
                    NOTE: for the default values, just leave blank
                    [browsable] default:'yes' or 'no'
                    [readonly] default:'yes' or 'no'
                    [guest] allowed default:'yes' or 'no'
                    NOTE: for user lists below, usernames are separated by ','
                    [users] allowed default:'all' or list of allowed users
                    [admins] allowed default:'none' or list of admin users
                    [writelist] list of users that can write to a RO share
                    [comment] description of share
        -u "<username;password>[;ID;group;GID]"       Add a user
                    required arg: "<username>;<passwd>"
                    <username> for user
                    <password> for user
                    [ID] for user
                    [group] for user
                    [GID] for group
        -w "<workgroup>"       Configure the workgroup (domain) samba should use
                    required arg: "<workgroup>"
                    <workgroup> for samba
        -W          Allow access wide symbolic links
        -I          Add an include option at the end of the smb.conf
                    required arg: "<include file path>"
                    <include file path> in the container, e.g. a bind mount

    The 'command' (if provided and valid) will be run instead of samba

### Environment Variables

 * `CHARMAP` - As above, configure character mapping
 * `GENERIC` - As above, configure a generic section option (\*See tip below)
 * `GLOBAL` - As above, configure a global option (\*See tip below)
 * `IMPORT` - As above, import a smbpassword file
 * `NMBD` - As above, enable nmbd
 * `PERMISSIONS` - As above, set file permissions on all shares
 * `RECYCLE` - As above, disable recycle bin
 * `SHARE` - As above, setup a share (\*See tip below)
 * `SMB` - As above, disable SMB2 minimum version
 * `TZ` - Set a timezone, IE `EST5EDT`
 * `USER` - As above, setup a user (\*See tip below)
 * `WIDELINKS` - As above, allow access wide symbolic links
 * `WORKGROUP` - As above, set workgroup
 * `USERID` - Set the UID for the samba server's default user (smbuser)
 * `GROUPID` - Set the GID for the samba server's default user (smbuser)
 * `INCLUDE` - As above, add a smb.conf include
 * `SAMBA_SH_ARGS` - Additional arguments to be appended to those supplied by docker's command
 * `SAMBA_EXPORTER_STATUSD_ARGS` - [Options for `samba_statusd`](https://imker25.github.io/samba_exporter/manpages/samba_statusd.1.html#OPTIONS). Only available with the `exporter` tag.
 * `SAMBA_EXPORTER_ARGS` - [Options for `samba_exporter`](https://imker25.github.io/samba_exporter/manpages/samba_exporter.1.html#OPTIONS). Only available with the `exporter` tag.
 * `SMB_CONF_PATH` - See [`smb.conf`](#smbconf). Defaults to `/etc/docker-samba/smb.conf`

> [!NOTE]
> If you enable nmbd (via `-n` or the `NMBD` environment variable), you
will also want to expose port 137 and 138 with `-p 137:137/udp -p 138:138/udp`.

> [!NOTE]
> There are reports that `-n` and `NMBD` only work if you have the
container configured to use the hosts network stack.

> [!TIP]
> \*Optionally supports additional variables starting with the same name,
i.e. `SHARE` also will work for `SHARE2`, `SHARE3`... `SHAREx`, etc.

### `smb.conf`

If you wish you use a custom smb.conf file other than the default `smb.conf`, your're able to specfiy a custom `smb.conf` file binded to the path specified by `SMB_CONF_PATH`. Any additional configuration you provide through environment variables or CLI options will be automatically applied to the supplied configuration.

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it samba samba.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run -it -e TZ=EST5EDT -p 139:139 -p 445:445 -d logicer16/samba -p

### Start an instance creating users and shares:

    sudo docker run -it -p 139:139 -p 445:445 -v config/smb.conf:/etc/docker-samba/smb.conf -d logicer16/samba -p \
                -u "example1;badpass" \
                -u "example2;badpass" \
                -s "public;/share" \
                -s "users;/srv;no;no;no;example1,example2" \
                -s "example1 private share;/example1;no;no;no;example1" \
                -s "example2 private share;/example2;no;no;no;example2"

### Use a custom `smb.conf`

    sudo docker run -it -p 139:139 -p 445:445 -d logicer16/samba -p \
                -u "example1;badpass"

# User Feedback

## Troubleshooting

* You get the error `Access is denied` (or similar) on the client and/or see
`change_to_user_internal: chdir_current_service() failed!` in the container
logs.

Add the `-p` option to the end of your options to the container, or set the
`PERMISSIONS` environment variable.

    sudo docker run -it --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d logicer16/samba -p

If changing the permissions of your files is not possible in your setup you
can instead set the environment variables `USERID` and `GROUPID` to the
values of the owner of your files.

* High memory usage by samba. Multiple people have reported high memory usage
that's never freed by the samba processes. Recommended work around below:

Add the `-m 512m` option to docker run command, or `mem_limit:` in
docker_compose.yml files, IE:

    sudo docker run -it --name samba -m 512m -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d logicer16/samba -p

* Attempting to connect with the `smbclient` commandline tool. By default samba
still tries to use SMB1, which is depriciated and has security issues. This
container defaults to SMB2, which for no decernable reason even though it's
supported is disabled by default so run the command as `smbclient -m SMB3`, then
any other options you would specify.

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/logicer16/samba/issues).
