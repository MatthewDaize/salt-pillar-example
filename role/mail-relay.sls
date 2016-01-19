role: {{ sls.split('.')[1] }}

postfix:
  packages:
    - postfix
    - ca_root_nss
  main:
    - mydomain: example.com
    - myorigin: $mydomain
    - mynetworks: cidr:/usr/local/etc/postfix/network_table
    - smtpd_banner: $myhostname ESMTP
    - relay_domains: /usr/local/etc/postfix/relay_domains
    - relay_recipient_maps:
      - hash:/usr/local/etc/postfix/relay_recipients
      - ldap:/usr/local/etc/postfix/example_exchange
    - transport_maps: hash:/usr/local/etc/postfix/transport
    - virtual_alias_maps: hash:/usr/local/etc/postfix/virtual
    - smtpd_helo_required: yes
    - strict_rfc821_envelopes: yes
    - recipient_delimiter: +
    - smtpd_proxy_filter: localhost:10024
    - smtpd_client_connection_count_limit: 2
    - smtpd_proxy_options: speed_adjust
    - smtpd_client_restrictions:
      - permit_mynetworks
      - permit_sasl_authenticated
      - check_client_access hash:/usr/local/etc/postfix/access_client
      - check_client_access cidr:/usr/local/etc/postfix/network_table
      - reject_rbl_client zen.spamhaus.org
      - reject_rbl_client bl.spamcop.net
      - reject_rbl_client b.barracudacentral.org
    - smtpd_helo_restrictions:
      - permit_mynetworks
      - reject_invalid_helo_hostname
      - reject_non_fqdn_helo_hostname
    - smtpd_sender_restrictions:
      - permit_mynetworks
      - check_sender_access hash:/usr/local/etc/postfix/access_sender
      - reject_non_fqdn_sender
      - reject_rhsbl_sender dbl.spamhaus.org
      - reject_unknown_sender_domain
    - smtpd_recipient_restrictions:
      - permit_mynetworks
      - check_recipient_access hash:/usr/local/etc/postfix/access_recipient
      - reject_unauth_destination
      - reject_non_fqdn_recipient
    - smtpd_etrn_restrictions: reject
    - smtpd_tls_security_level: may
    - smtpd_tls_session_cache_database: btree:/var/spool/postfix/private/smtpd_scache
    - smtpd_tls_cert_file: /usr/local/etc/postfix/ssl.crt
    - smtpd_tls_key_file: /usr/local/etc/postfix/ssl.key
    - message_size_limit: 262144000
    - smtp_sasl_password_maps: hash:/usr/local/etc/postfix/sasl_passwd
    - smtp_tls_mandatory_protocols:
      - '!SSLv2'
      - '!SSLv3'
    - smtp_tls_CAfile: /usr/local/share/certs/ca-root-nss.crt
    - smtp_tls_fingerprint_digest: sha1
    - smtp_tls_policy_maps: hash:/usr/local/etc/postfix/tls_policy
  master:
    - 10025     inet  n       -       n       -        -      smtpd -o mynetworks=127.0.0.0/8,[::1]/128 -o smtpd_proxy_filter= -o smtpd_client_connection_count_limit=50 -o smtpd_proxy_options= -o smtpd_authorized_xforward_hosts=$mynetworks -o smtpd_client_restrictions= -o smtpd_helo_restrictions= -o smtpd_sender_restrictions= -o smtpd_relay_restrictions= -o smtpd_recipient_restrictions=permit_mynetworks,reject -o smtpd_data_restrictions= -o receive_override_options=no_unknown_recipient_checks 
  maps:
    cidr:
      network_table:
        - '## EXAMPLE WAN'
        - '10.0.0.0/8 OK'
        - '172.16.0.0/12 OK'
        - '192.168.0.0/16 OK'
        - '[fc00::]/7 OK'
    file:
      relay_domains: |
        example.com
        example.net
        example.org
    hash:
      access_client:
        - google.com OK
        - microsoft.com OK
        - yahoo.com OK
      access_sender:
        - support@protectnetwork.org OK
      access_recipient: []
      relay_recipients:
        - '#@example.com OK'
      transport:
        - example.com smtp:[mail.example.net]
        - example.net smtp:[mail.example.net]
        - example.org smtp:[mail.example.net]
      virtual:
        - '## Allow mail addressed to "postmaster@[IP address]".'
        - postmaster postmaster@example.com
        - abuse abuse@example.com
    ldap:
      example_exchange:
        - server_host: ldaps://dc01.example.net
        - search_base: dc=example,dc=net
        - query_filter: (proxyAddresses=smtp:%s)
        - result_attribute: ""
        - leaf_result_attribute: cn
        - bind_dn: s-listrecipients@EXAMPLE.NET
        - bind_pw: 'P@55w0rd!!'
        - chase_referrals: "no" # NOTE: string, not a boolean!
        - version: 3
        - tls_ca_cert_file: /usr/local/share/certs/ca-root-nss.crt
