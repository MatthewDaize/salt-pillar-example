#!jinja|yaml|gpg
#### DEFAULTS.FIREWALL --- Common (local) firewall configuration

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

####
#### DEBIAN/UBUNTU
####

ufw:
  enabled:
    {% if salt['grains.get']('biosversion').endswith('amazon') %}
    False
    {% else %}
    True
    {% endif %}
  applications:
    - mosh
    - OpenSSH

####
#### RHEL/CENTOS
####

firewalld:
  enabled:
    {% if salt['grains.get']('biosversion').endswith('amazon') %}
    False
    {% else %}
    True
    {% endif %}
  default_zone: public
  services:
    mosh:
      description:
        Remote terminal application that allows roaming, supports
        intermittent connectivity, and provides intelligent local echo
        and line editing of user keystrokes.  Mosh is a replacement
        for SSH.  It\'s more robust and responsive, especially over
        Wi-Fi, cellular, and long-distance links.
      ports:
        udp:
          - 60000-61000
  zones:
    public:
      short: Public
      description:
        For use in public areas.  You do not trust the other computers
        on networks to not harm your computer.  Only selected incoming
        connections are accepted.
      services:
        - mosh
        - ssh
        - dhcpv6-client

#### DEFAULTS.FIREWALL ends here.
