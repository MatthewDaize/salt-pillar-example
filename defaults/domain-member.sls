#!jinja|yaml|gpg
#### DEFAULTS.DOMAIN-MEMBER --- Kerberos/NIS/NTP/NFS client configs

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

kerberos5:
  libdefaults:
    ticket_lifetime: 24h
    renew_lifetime: 7d
    warn_pwexpire: 14d
    forwardable: True
    default_realm: EXAMPLE.NET
    dns_lookup_realm: True
    dns_lookup_kdc: True
  realms:
    EXAMPLE.NET: {}
  domain_realm:
    .example.net: EXAMPLE.NET
    example.net: EXAMPLE.NET

nis:
  ypdomain: example.net
  ypservers:
    - 192.0.2.100
    - 192.0.2.200

ntp:
  ng:
    settings:
      ntpd: True
      ntp_conf:
        restrict:
          - default ignore
          - -6 default ignore
          - 192.0.2.100 nomodify nopeer noquery notrap
          - 192.0.2.200 nomodify nopeer noquery notrap
        server:
          - 192.0.2.100 iburst
          - 192.0.2.200 iburst
        driftfile:
          {% if grains['os_family'] == 'FreeBSD' %}
          - /var/db/ntpd.drift
          {% else %}
          - /var/lib/ntp/drift
          {% endif %}

pam_mkhomedir:
  enable: True

symlinks:
  - name: /home/example
  {% if grains['os_family'] == 'FreeBSD' %}
    target: /host/nas01.example.net/home
  {% else %}
    target: /net/nas01.example.net/home
  {% endif %}

#### DEFAULTS.DOMAIN-MEMBER ends here.
