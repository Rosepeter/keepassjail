# KeePassJail

## What is it?

KeePassJail is a small toy-project and tries to avoid the leakage of sensitive
information (i.e., the content of your password database) in case you fall
victim to a malicious copy of KeePass. This is mainly implemented by confining
the outbound network connections of KeePass by a corresponding configuration of
nftables. KeePassJail does not aim at preventing any kind of negative impact
that a malicious copy of KeePass could have on the host system itself.

Furthermore, the following use cases, are supported:

- Running KeePass as ssh-agent using the KeeAgent-plugin.
- Enabling browser-integration of KeePass via the KeePassRPC-plugin and
  e.g. KeeVault. This however poses the risk of leaking information via
  malicious copies of KeeVault.
- Reading KeePass-databases from remote hosts using the plugin SftpSync.
- The installation directory of KeePass can be an arbitrary directory on your
  system, allowing for easy update of KeePass.

## How does it work?

The basic idea is to run KeePass not as plain process in the user session but
inside a container. Within the container the nftables-firewall is configured, so
that only certain connections to and from KeePass are possible:

- outbound connections via SSH to a given host
- inbound connections via KeePassRPC
- in- and outbound connections to resolve hostnames via DNS

In order not to restrict user comfort to much

- `XAUTH` and `DISPLAY` environment variables and the X11-socket are passed to
  the container, so that the KeePass-window pops up as usual when starting
  KeePass from the command line.
- The home-directory of the user running KeePass is mapped to the home-directory
  of the user running keepass inside the container. The user thus could store
  the KeePass-database in the home-directory as usual. Furthermore, this also
  enables using KeePass as ssh-agent by simply creating the file socket
  (`SSH_AUTH_SOCK`) in the home-directory of the user.
- User- and group-id of the user calling keepass are mapped to user running
  keepass within the container, so that file-ownership and -permission do not
  conflict and are not messed up.

## How can I use it?

1. Build the container for KeePassJail, everything needed for this can be found in the subdirectory [container](container): `cd container && sudo podman build -t keepassjail .`

2. Put the script [start-keepass.sh](start-keepass.sh) to an appropriate
   location on your system (e.g. `/usr/local/bin`) and update the script
   [keepass](keepass) to call it using the full path of
   [start-keepass.sh](start-keepass.sh).

3. If you do not want to provide the sudo-password on each invocation of keepass,
   add [sudo-keepass-container](sudo-keepass-container) to your
   sudo-configuration. This however should be used with caution as
   [start-keepass.sh](start-keepass.sh) currently source a small bash-fragment
   as configuration-file. The fragment is not checked or verified further, it
   thus may contain arbitrary code that is executed with root-privileges.

4. Add the script [keepass](keepass) to your path.

5. Adapt [.keepassjail](.keepassjail) according to your needs and put it into
   your home-directory.

6. Invoke the script [keepass](keepass)

## Disclaimer

This is a small toy-project, this is not a serious security tool.
