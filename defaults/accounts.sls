#!jinja|yaml|gpg
#### DEFAULTS.ACCOUNTS --- Local accounts created on all minions

### For more information about the format of this file, see
### http://docs.saltstack.com/en/latest/topics/pillar/index.html.  For
### more information about change management procedures, see TODO.
### The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
### NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
### in this document are to be interpreted as described in RFC 2119,
### https://tools.ietf.org/html/rfc2119.  The key words "MUST (BUT WE
### KNOW YOU WON'T)", "SHOULD CONSIDER", "REALLY SHOULD NOT", "OUGHT
### TO", "WOULD PROBABLY", "MAY WISH TO", "COULD", "POSSIBLE", and
### "MIGHT" in this document are to be interpreted as described in RFC
### 6919, https://tools.ietf.org/html/rfc6919.  The keywords "DANGER",
### "WARNING", and "CAUTION" in this document are to be interpreted as
### described in OSHA 1910.145,
### https://www.osha.gov/pls/oshaweb/owadisp.show_document?p_table=standards&p_id=9794.

defaults:
  root:
    password: &rootpass |
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v2

      ...
      -----END PGP MESSAGE-----
    password_hash: &rootpasshash |
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v2

      ...
      -----END PGP MESSAGE-----
    ssh_auth: &rootsshauthkeys
      - |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----
  sudo:
    rules:
      - &sudorule1 |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----
      - &sudorule2 |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----

{%- if grains.os_family == 'Windows' %}

users:
  Administrator:
    password:
      *rootpass
    prime_group:
      name:
        Administrators
    createhome:
      False
    home:
      'C:\Users\Administrator'
    shell:
      False

  critical:
    password:
      *rootpass
    prime_group:
      name:
        Administrators
    createhome:
      False
    home:
      'C:\Users\critical'
    shell:
      False

{%- else %}

users:
  root:
    home:
      /root
    password:
      *rootpasshash
    ssh_auth:
      *rootsshauthkeys
{%-   if grains.os_family in [
        'FreeBSD',
        'NetBSD',
        'OpenBSD',
      ]
%}
    prime_group:
      name:
        wheel
      gid:
        0
{%-   endif %}

  critical:
    password:
      *rootpasshash
    ssh_auth:
      *rootsshauthkeys
    sudouser:
      True
    sudo_rules:
      - *sudorule1

{%- endif %}

sudoers:
  aliases:
    commands:
      REBOOT:
        - /sbin/halt
        - /sbin/reboot
        - /sbin/poweroff
  defaults:
    generic:
      ## enable command input logging (potentially insecure -
      ## currently disabled)
      # - log_input
      ## enable command output logging
      - log_output
      ## email root upon sudo login failures
      - mail_badpass
      ## reset the executable search path
      - secure_path="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
    command_list:
      ## don't log output of following commands
      /usr/sbin/sudoreplay:
        '!log_output'
      /usr/local/sbin/sudoreplay:
        '!log_output'
      REBOOT:
        '!log_output'
  users:
    root:
      - *sudorule2
  groups:
    'Domain\ Admins':
      - *sudorule1
    'Unix\ Admins':
      - *sudorule1

mysql:
  server:
    root_password:
      *rootpass

#### DEFAULTS.ACCOUNTS ends here.
