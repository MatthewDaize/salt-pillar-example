#!jinja|yaml|gpg
#### DEFAULTS.SLS --- Common configuration for Salt minions managed by this master

### For more information about the format of this file, see
### http://docs.saltstack.com/en/latest/topics/pillar/index.html.  For
### more information about change management procedures, see TODO.
### The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
### NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
### in this document are to be interpreted as described in RFC 2119,
### http://www.rfc-editor.org/rfc/rfc2119.txt.  The keywords "DANGER",
### "WARNING", and "CAUTION" in this document are to be interpreted as
### described in OSHA 1910.145,
### https://www.osha.gov/pls/oshaweb/owadisp.show_document?p_table=standards&p_id=9794.

####
#### COMMON PILLARS
####

### This data gets sent to all minions regardless of their operating
### system.

## Salt minion configuration
salt:
  minion:
    master: salt.example.com

## example encrypted value
secret:
  -----BEGIN PGP MESSAGE-----
  Version: GnuPG v2

  hQEMAweRHKaPCfNeAQf9GLTN16hCfXAbPwU6BbBK0unOc7i9/etGuVc5CyU9Q6um
  QuetdvQVLFO/HkrC4lgeNQdM6D9E8PKonMlgJPyUvC8ggxhj0/IPFEKmrsnv2k6+
  cnEfmVexS7o/U1VOVjoyUeliMCJlAz/30RXaME49Cpi6No2+vKD8a4q4nZN1UZcG
  RhkhC0S22zNxOXQ38TBkmtJcqxnqT6YWKTUsjVubW3bVC+u2HGqJHu79wmwuN8tz
  m4wBkfCAd8Eyo2jEnWQcM4TcXiF01XPL4z4g1/9AAxh+Q4d8RIRP4fbw7ct4nCJv
  Gr9v2DTF7HNigIMl4ivMIn9fp+EZurJNiQskLgNbktJGAeEKYkqX5iCuB1b693hJ
  FKlwHiJt5yA8X2dDtfk8/Ph1Jx2TwGS+lGjlZaNqp3R1xuAZzXzZMLyZDe5+i3RJ
  skqmFTbOiA==
  =Eqsm
  -----END PGP MESSAGE-----

####
#### WINDOWS-SPECIFIC PILLARS
####

{% if salt.grains.get('kernel') in ['Windows'] %}

## user accounts
users:
  Administrator:
    password: '...'

{% endif #}

####
#### UNIX-SPECIFIC PILLARS
####

{% if salt.grains.get('kernel') in ['FreeBSD', 'Linux', 'Solaris'] %}

## user accounts
users:
  root:
    password: '...'
    home: /root
    {% if salt.grains.get('os_family') == 'FreeBSD' %}
    prime_group:
      name: wheel
      gid: 0
    {% endif %}
    ssh_auth:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpSlXcYFaHeOs0hTfjxSaTWl8gJQt+ZFBQlVFn2ak/w EXAMPLE Production Salt Master <noc@example.com>
    sudouser: True
    sudo_rules:
      - 'ALL=(ALL) ALL'

## email aliases
aliases:
  root: noc@example.com

## postfix mua

postfix:
  main:
    - relayhost: '[smtp.example.com]:submission'
    - smtp_sasl_auth_enable: yes
    - smtp_sasl_password_maps:
      {% if salt['grains.get']('os_family') == 'FreeBSD' %}
        hash:/usr/local/etc/postfix/sasl_passwd
      {% else %}
        hash:/etc/postfix/sasl_passwd
      {% endif %}
    - smtp_use_tls: yes
    - smtp_tls_mandatory_protocols:
      - '!SSLv2'
      - '!SSLv3'
    - smtp_tls_CAfile:
      {% if salt['grains.get']('os_family') == 'FreeBSD' %}
        /usr/local/share/certs/ca-root-nss.crt
      {% elif salt['grains.get']('os_family') == 'RedHat' %}
        /etc/pki/tls/certs/ca-bundle.crt
      {% else %}
      ""
      {% endif %}
    - smtp_tls_fingerprint_digest: sha1
    - smtp_tls_policy_maps:
      {% if salt['grains.get']('os_family') == 'FreeBSD' %}
        hash:/usr/local/etc/postfix/tls_policy
      {% else %}
        hash:/etc/postfix/tls_policy
      {% endif %}
  maps:
    hash:
      sasl_passwd:
        - "[smtp.example.com]:submission s-smmsp:P@55w0rd!!"
      tls_policy:
        []

## time synchronization
ntp:
  ng:
    settings:
      ntpd: True
      ntp_conf:
        restrict:
          - default ignore
          - -6 default ignore
          - 192.0.2.50 nomodify nopeer noquery notrap
          - 192.0.2.100 nomodify nopeer noquery notrap
          - 192.0.2.200 nomodify nopeer noquery notrap
        server:
          - 192.0.2.50 iburst
          - 192.0.2.100 iburst
          - 192.0.2.200 iburst
        driftfile:
          {% if salt.grains.get('os_family') == 'FreeBSD' %}
          - /var/db/ntpd.drift
          {% else %} {# FIXME #}
          - /var/lib/ntp/drift
          {% endif %}

## Kerberos client
kerberos5:
  config:
    libdefaults:
      default_realm: EXAMPLE.NET
      dns_lookup_realm: True
      dns_lookup_kdc: True
      warn_pwexpire: 14 days
    realms:
      EXAMPLE.NET: {}
    domain_realm:
      .example.net: EXAMPLE.NET
      example.net: EXAMPLE.NET

## NIS client
ypbind:
  domain: example.com
  servers:
    - 192.0.2.50
    - 192.0.2.100
    - 192.0.2.200

pam_mkhomedir:
  enable: True

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
      - 'ALL=(ALL) ALL'
  groups:
    'Domain\ Admins':
      - 'ALL=(ALL) ALL'
    'Unix\ Admins':
      - 'ALL=(ALL) ALL'

snmp:
  conf:
    location: 'Somewhere, OZ'
    syscontact: 'EXAMPLE Sysadmin <admin@example.com>'
    logconnects: True
    # vacm views (map mib trees to views)
    views:
      - name: all
        type: included
        oid: '.1'
        #optional mask
        mask: 80
    # v3 users for read-only
    rousers:
      - username: 'example'
        passphrase: 'P@55w0rd!!'
        view: all
        authproto: 'SHA'
        privproto: 'AES'
    # misc snmpd.conf settings
    settings:
      # agentAddress: 'udp:161,udp6:[::1]:161'
      sysServices: 72
      master: ['agentx']

{% endif %}

####
#### FREEBSD-SPECIFIC PILLARS
####

{% if salt.grains.get('kernel') == 'FreeBSD' %}
git:
  lookup:
    git: git   # workaround missing support for FreeBSD in git-formula

mounts:
  - path: /dev/fd
    device: fdescfs
    fstype: fdescfs
  - path: /proc
    device: procfs
    fstype: procfs

sysctl:
  security.bsd.see_other_uids: 0
{% endif %}

#### DEFAULTS.SLS ends here.
