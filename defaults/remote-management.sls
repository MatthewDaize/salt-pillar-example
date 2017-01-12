#!jinja|yaml|gpg
#### DEFAULTS.REMOTE-MANAGEMENT --- Sysadmin remote access/monitoring

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

# fail2ban:
#   lookup:
#     jails:
#       ssh:
#         action:
#           {% if salt['grains.get']('kernel') == 'FreeBSD' %}
#           {# FIXME #}
#           {% elif salt['grains.get']('kernel') == 'Linux' %}
#           - iptables[name=SSH, port=ssh, protocol=tcp]
#           {% elif salt['grains.get']('kernel') == 'Solaris' %}
#           {# FIXME #}
#           {% endif %}
#         enabled: 'true'
#         filter: sshd
#         logpath: /var/log/auth.log
#         maxretry: 5
#         port: ssh
#       ssh_ddos:
#         action:
#           {% if salt['grains.get']('kernel') == 'FreeBSD' %}
#           {# FIXME #}
#           {% elif salt['grains.get']('kernel') == 'Linux' %}
#           - iptables[name=SSH, port=ssh, protocol=tcp]
#           {% elif salt['grains.get']('kernel') == 'Solaris' %}
#           {# FIXME #}
#           {% endif %}
#         enabled: 'true'
#         filter: sshd-ddos
#         logpath: /var/log/auth.log
#         port: ssh

snmp:
  conf:
    location: 'New York, NY'
    syscontact: 'noc@example.com'
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
      - username: |
          -----BEGIN PGP MESSAGE-----
          Version: GnuPG v2

          ...
          -----END PGP MESSAGE-----
        passphrase: |
          -----BEGIN PGP MESSAGE-----
          Version: GnuPG v2

          ...
          -----END PGP MESSAGE-----
        view: all
        authproto: 'SHA'
        privproto: 'AES'
    # misc snmpd.conf settings
    settings:
      # agentAddress: 'udp:161,udp6:[::1]:161'
      sysServices: 72
      master: ['agentx']

ssh:
  Host *:
    VisualHostKey: yes
    RekeyLimit: 1G 1h
    VerifyHostKeyDNS: ask

sshd:
  UseDNS: no
  Banner: /etc/issue

#### DEFAULTS.REMOTE-MANAGEMENT ends here.
