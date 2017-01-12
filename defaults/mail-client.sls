#!jinja|yaml|gpg
#### DEFAULTS.MAIL-CLIENT --- Postfix MTA client configs

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

{% if grains['os_family'] in [ 'Arch', 'Debian', 'Gentoo', 'FreeBSD', 'NetBSD', 'OpenBSD', 'RedHat', 'Solaris', 'Suse', ] %}

aliases:
  root: root@example.com

{% set prefix = '/usr/local' if grains['os_family'] == 'FreeBSD' else '' %}
postfix:
  main:
    - relayhost: '[mail.example.com]'
    ## disabled due to compatibility problems with Exchange
    # - relayhost: '[mail.example.com]:submission'
    # - smtp_sasl_auth_enable: yes
    # - smtp_sasl_password_maps: hash:{{ prefix }}/etc/postfix/sasl_passwd
    # - smtp_use_tls: yes
    - smtp_tls_mandatory_protocols:
        - '!SSLv2'
        - '!SSLv3'
    - smtp_tls_CAfile:
        {% if grains['os_family'] in [ 'Arch', 'Debian', ] %}
        /etc/ssl/certs/ca-certificates.crt
        {% elif grains['os_family'] == 'FreeBSD' %}
        /usr/local/share/certs/ca-root-nss.crt
        {% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'] > 4 %}
        /etc/pki/tls/certs/ca-bundle.crt
        {% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'] <= 4 %}
        /usr/share/ssl/certs/ca-bundle.crt
        {% elif grains['os_family'] == 'OpenBSD' %}
        /etc/ssl/cert.pem
        {% elif grains['os_family'] == 'MacOS' %}
        /System/Library/OpenSSL/certs/cert.pem
        {% else %}
        please refer to FIXME in {{ sls }}
        {% endif %}
    - smtp_tls_fingerprint_digest: sha1
    - smtp_tls_policy_maps: hash:{{ prefix }}/etc/postfix/tls_policy
  master:
    - '## NOTE: This transport was intended to force encryption with'
    - '## MTAs at a level compatible with Exchange 2003.  It is'
    - '## currently unused.'
    - '#exch unix - - n - - smtp -o smtp_tls_security_level=encrypt -o smtp_tls_ciphers=medium -o smtp_tls_mandatory_ciphers=medium -o tls_medium_cipherlist=aRSA+AES128:aRSA+AES256:RC4-SHA:@STRENGTH'
  maps:
    hash:
      sasl_passwd:
        - |
          -----BEGIN PGP MESSAGE-----
          Version: GnuPG v2

          ...
          -----END PGP MESSAGE-----

      tls_policy:
        - '## Windows Server 2003 does not support TLSv1.1 or newer, and'
        - '## it erroneously reports which versions of SSL/TLS it does'
        - '## support.  The following will force TLSv1 when communicating'
        - '## with Exchange Server 2003.'
        - '#[mail.example.com]:submission encrypt protocols=TLSv1'
        - '#[mail.example.com]            encrypt protocols=TLSv1'
        - ''
        - '## When communicating with message transport agents whose'
        - '## certificates cannot be verified, add their public key'
        - '## fingerprints to the list below to bypass the verification'
        - '## checks.  Generate the fingerprint using the following'
        - '## command (replacing hostname with the name or IP address of'
        - '## the MTA in question):'
        - '##'
        - '## echo QUIT \\'
        - '##  | openssl s_client -connect hostname:25 -starttls smtp -tls1 -status \\'
        - '##  | openssl x509 -fingerprint \\'
        - '##  | grep SHA1 | awk "{print $2}" | sed -e s/Fingerprint=//'
        - '#[exch01.example.net] fingerprint match=6A:73:DA:5E:F0:BA:22:26:AC:6E:35:78:68:1D:6C:C0:00:3E:E3:D0'

{% endif %}

#### DEFAULTS.MAIL-CLIENT ends here.
