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

users:
  critical:
    {% if grains['os_family'] == 'Windows' %}
    password: &rootpass |
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v2

      ...
      -----END PGP MESSAGE-----
    {% else %}
    password: &rootpasshash |
      -----BEGIN PGP MESSAGE-----
      Version: GnuPG v2

      ...
      -----END PGP MESSAGE-----
    {% endif %}
    ssh_auth:
      - &rootsshauthkey1 |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----
    sudouser: True
    sudo_rules:
      - &sudorule1 |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----

  {% if grains['os_family'] in [ 'Windows', ] %}
  Administrator:
    prime_group:
      name: Administrators
    password: *rootpass

  {% elif grains['os_family'] in [ 'Arch', 'Debian', 'Gentoo', 'FreeBSD', 'NetBSD', 'OpenBSD', 'RedHat', 'Solaris', 'Suse', ] %}
  root:
    home: /root
    {% if grains['os_family'] in [ 'FreeBSD', 'NetBSD', 'OpenBSD', ] %}
    prime_group:
      name: wheel
      gid: 0
    {% endif %}
    password: *rootpasshash
    ssh_auth:
      - *rootsshauthkey1
  {% endif %}

sudoers:
  aliases:
    commands:
      REBOOT:
        - /sbin/halt
        - /sbin/reboot
        - /sbin/poweroff
  defaults:
    generic:
      # - log_input             # enable command input logging (potentially insecure)
      - log_output              # enable command output logging
      - mail_badpass            # email root upon sudo login failures
      ## reset the executable search path
      - secure_path="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
    command_list:
      ## don't log output of following commands
      /usr/sbin/sudoreplay: '!log_output'
      /usr/local/sbin/sudoreplay: '!log_output'
      REBOOT: '!log_output'
  users:
    root:
      - &sudorule2 |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v2

        ...
        -----END PGP MESSAGE-----
  groups:
    'Domain\ Admins':
      - *sudorule1
    'Unix\ Admins':
      - *sudorule1

#### DEFAULTS.ACCOUNTS ends here.
