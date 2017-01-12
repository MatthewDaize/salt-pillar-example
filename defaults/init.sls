#!jinja|yaml|gpg
#### DEFAULTS.INIT --- Pillar data common to all minions

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

## FIXME: can't use relative includes here?
include:
  - defaults.salt-minion
  - defaults.accounts
  - defaults.domain-member
  - defaults.firewall
  - defaults.remote-management
  - defaults.mail-client

{% if salt['grains.get']('kernel') == 'FreeBSD' %}
cvs:
  packages:
    - cvs-devel

mounts:
  - path: /dev/fd
    device: fdescfs
    fstype: fdescfs
  - path: /proc
    device: procfs
    fstype: procfs

poudriere:
  make_conf:
    - LICENSES_ACCEPTED+=DCC
    - HISTORICAL_MAKE_WORLD=yes
    - FORCE_PACKAGE=yes
    - FORCE_PKG_REGISTER=yes
    - EXPLICIT_PACKAGE_DEPENDS=yes
    - WITH_PKGNG=yes
    - SU_CMD=sudo -E sh -c
    - DEFAULT_VERSIONS=perl5=5.18 apache=2.4
    - JAVA_VERSION=1.8
    - WANT_OPENLDAP_SASL=yes
    - OVERRIDE_LINUX_BASE_PORT=c6
    - WITH_OPENSSL_PORT=yes
    - XORG_COMPLETE=yes
    - security_ca_root_nss_SET=ETCSYMLINK
    - ftp_curl_SET=CA_BUNDLE COOKIES DOCS EXAMPLES HTTP2 IDN IPV6 LDAP LDAPS LIBSSH2 PROXY RTMP TLS_SRP GSSAPI_HEIMDAL THREADED_RESOLVER OPENSSL
    - ftp_curl_UNSET=CURL_DEBUG DEBUG GSSAPI_BASE GSSAPI_MIT GSSAPI_NONE CARES NSS POLARSSL WOLFSSL
    - sysutils_moreutils_UNSET=MANPAGES
    - net_openldap24-server_SET=FETCH GSSAPI SASL
    - net_openldap24-client_SET=FETCH GSSAPI SASL
    - mail_postfix_SET=BDB LDAP LDAP_SASL SASL SPF TLS
    - devel_ccache_SET=CLANGLINK COLORS LLVMLINK
    - CCACHE_CPP2=1
    - security_amavisd-new_SET=ALTERMIME ARJ LDAP NOMARCH P0F PGSQL SASL SNMP TNEF
    - security_amavisd-new_UNSET=ARC
    - mail_spamassassin_SET=PGSQL DKIM PYZOR RAZOR RELAY_COUNTRY SPF_QUERY
    - mail_dcc-dccd_SET=ALT_HOME
    - mail_dcc-dccd_UNSET=DCCM
    - mail_spamass-rules_SET=AIRMAX BACKHAIR CHICKENPOX CHINESE EVILNUMBERS MANGLED 
    - security_clamav_SET=EXPERIMENTAL ICONV LDAP MILTER
    - net-mgmt_net-snmp_SET=MFD_REWRITES PYTHON TKMIB
    - x11_kde_SET=KDEBINDINGS
    - editors_libreoffice_SET=GNOME GTK3 JAVA KDE4 MMEDIA PGSQL SDK SYSTRAY WEBDAV
    - ports-mgmt_poudriere-devel_SET=QEMU ZSH
    - ports-mgmt_poudriere_SET=QEMU ZSH
    - www_plone_SET=LDAP
    - net-mgmt_zabbix3-server_SET=IPMI JAVAGW LDAP LIBXML2 NMAP
    - security_p5-GSSAPI_SET=GSSAPI_HEIMDAL
    - security_p5-GSSAPI_UNSET=GSSAPI_BASE
    - emulators_open-vm-tools_SET=UNITY
    - dns_bind-tools_SET=FILTER_AAAA GEOIP LARGE_FILE PYTHON DLZ_POSTGRESQL GSSAPI_HEIMDAL
    - dns_bind-tools_UNSET=GSSAPI_NONE
    - dns_bind910_SET=FILTER_AAAA GEOIP LARGE_FILE PYTHON DLZ_POSTGRESQL GSSAPI_HEIMDAL
    - dns_bind910_UNSET=GSSAPI_NONE

sysctl:
  security.bsd.see_other_uids: 0

{% elif salt['grains.get']('os_family') == 'RedHat' %}
nux:
  misc_disabled: False
  
{% endif %}

#### DEFAULTS.INIT ends here.
