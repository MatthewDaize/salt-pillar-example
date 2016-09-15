### Assume RHEL/CentOS 7.

firewalld:
  zones:
    public:
      services:
        - mosh
        - ssh
        - dhcpv6-client
        - http
        - https

shibboleth:
  idp:
    hostname: login.example.com
    entity_id: https://login.example.com/idp/shibboleth
    scope: example.com
    cookie_secure: yes
    keystore_password: 'longalphanumericpassword'
    sealer_password: 'adifferentlongalphanumericpassword'

    ## Deploy Shibboleth IdP using the same service account as the
    ## desired Java servlet container (here, Apache Tomcat on CentOS
    ## 7).
    user: tomcat
    group: tomcat

    ## Include the Tomcat package when installing Shibboleth IdP, as
    ## this creates the above service account/group; otherwise, the
    ## shibboleth.idp (from this formula) and tomcat (from
    ## tomcat-formula) states can't be applied idempotently (again, as
    ## above, Apache Tomcat on CentOS 7).
    packages:
      - java-1.8.0-openjdk-devel
      - bash
      - tomcat

    ## Configure the LDAP client to use Active Directory Domain
    ## Services (AD DS).
    ldap_authenticator: bindSearchAuthenticator # or adAuthenticator?
    ldap_url: ldaps://example.net:636
    ldap_use_starttls: no
    ldap_use_ssl: yes
    ldap_ssl_config: jvmTrust
    ldap_base_dn: ou=MyBusiness,dc=example,dc=net
    ldap_subtree_search: True
    ldap_user_filter: (sAMAccountName={user})
    ldap_bind_dn: s-shib-idp@EXAMPLE.NET
    ldap_bind_credential: m0passwords,m0problems
    ldap_dn_format: '%s@EXAMPLE.NET'
    attribute_resolver_ldap_search_filter:
      (sAMAccountName=$requestContext.principalName)

    ## Trust the following sources of federation metadata.
    metadata_providers:
      ## TestShib
      - http://www.testshib.org/metadata/testshib-providers.xml
      ## Amazon Web Services
      - https://signin.aws.amazon.com/static/saml-metadata.xml
      - https://signin.amazonaws-us-gov.com/static/saml-metadata.xml
      ## InCommon Federation
      ## https://spaces.internet2.edu/display/InCFederation/Shibboleth+Metadata+Config
      ## https://spaces.internet2.edu/display/InCFederation/Metadata+Aggregates
      - url: http://md.incommon.org/InCommon/InCommon-metadata.xml
        min_refresh_delay: PT5M    # TODO
        max_refresh_delay: PT1H    # TODO
        refresh_delay_factor: 0.75 # TODO
        filters:
          - type: SignatureValidation
            require_signed_root: True
            ## https://spaces.internet2.edu/display/InCFederation/Metadata+Signing+Certificate
            ##
            ## WARNING: THIS IS THE PUBLIC KEY OF THAT CERTIFICATE,
            ## NOT THE CERTIFICATE ITSELF!  Export the public key
            ## using something like the following command:
            ##
            ## curl --silent https://ds.incommon.org/certs/inc-md-cert.pem | openssl x509 -pubkey -noout
            public_key: |
              -----BEGIN PUBLIC KEY-----
              MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Chdkrn+dG5Zj5L3UIw+
              xeWgNzm8ajw7/FyqRQ1SjD4Lfg2WCdlfjOrYGNnVZMCTfItoXTSpg4rXxHQsykeN
              iYRu2+02uMS+1pnBqWjzdPJE0od+q8EbdvE6ShimjyNn0yQfGyQKCNdYuc+75MIH
              saIOAEtDZUST9Sd4oeU1zRjV2sGvUd+JFHveUAhRc0b+JEZfIEuq/LIU9qxm/+gF
              aawlmojZPyOWZ1JlswbrrJYYyn10qgnJvjh9gZWXKjmPxqvHKJcATPhAh2gWGabW
              TXBJCckMe1hrHCl/vbDLCmz0/oYuoaSDzP6zE9YSA/xCplaHA0moC1Vs2H5MOQGl
              ewIDAQAB
              -----END PUBLIC KEY-----
          - type: RequiredValidUntil
            max_validity_period: P14D
          - type: EntityRoleWhiteList
            retained_roles:
              - md:SPSSODescriptor

    ## Define attributes generated for authenticated users.
    resolver_attribute_definitions:
      - id: eduPersonPrincipalName
        type: ad:Scoped
        scope: '%{idp.scope}'
        source_attribute_id: uid
        dependency: uid
        attribute_encoders:
          - type: enc:SAML1ScopedString
            name: urn:mace:dir:attribute-def:eduPersonPrincipalName
            encode_type: False
          - type: enc:SAML2ScopedString
            name: urn:oid:1.3.6.1.4.1.5923.1.1.1.6
            friendly_name: eduPersonPrincipalName
            encode_type: False
      - id: uid
        type: ad:PrincipalName
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:uid
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:0.9.2342.19200300.100.1.1
            friendly_name: uid
            encode_type: False
      - id: mail
        type: ad:Template
        dependency: uid
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:mail
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:0.9.2342.19200300.100.1.3
            friendly_name: mail
            encode_type: False
        template:
          ${uid}@example.com
        source_attribute: uid   # NB: different than source_attribute_id!
      - id: eduPersonScopedAffiliation
        type: ad:Scoped
        scope: '%{idp.scope}'
        source_attribute_id: affiliation
        dependency: staticAttributes # NB: data connector reference
        attribute_encoders:
          - type: enc:SAML1ScopedString
            name: urn:mace:dir:attribute-def:eduPersonScopedAffiliation
            encode_type: False
          - type: enc:SAML2ScopedString
            name: urn:oid:1.3.6.1.4.1.5923.1.1.1.9
            friendly_name: eduPersonScopedAffiliation
            encode_type: False
    resolver_data_connectors:
      - id: staticAttributes
        type: dc:Static
        attributes:
          - id: affiliation
            value: member

    ## Control which attributes get released to which service
    ## providers.
    attribute_filter_policies:
      ## Release eppn, epsa, and mail to all SPs.
      - policy_requirement: ANY
        attribute_rules:
          - attribute_id: eduPersonPrincipalName
            permit_value: ANY
          - attribute_id: eduPersonScopedAffiliation
            permit_value: ANY
          - attribute_id: mail
            permit_value: ANY

    ## IdP keying material (TODO: key rollover)
    ## This embeds the intermediate CA certificate in the backchannel
    ## certificate file (ordered leaf-to-node).
    backchannel_certificate: &backcert |
      -----BEGIN CERTIFICATE-----
      XoeaUnFuAXE73GlKja4LiBkXMyEe1QOMwqvQOP+dbUc7C4GVy11PFsR3srRC578l
      aXoemLSeo682V7rmZsC3FXwxDH5H9JhP42AdaMrQLKYviSzHiyHsyiacTgxxqjc1
      sQVQtbxq7vK5opjm66EUqqSnR4ZQOW6NG0uAonoAETaak1yM6ybF7kKvi4nIR0Xg
      zojBbXLAoOFfo6VZluJ2fq207DIzsK6+D9HY2VKst3xJ+k04j2H0dWAVBhm9og13
      L3vK8HRxaN+19ATrLoo1EUBEcLSOgi2O8dsaIETC+xGCbeVb2Kixd157VWodt9vR
      KBJTigpD0fDKiK4JZ4g6m2FlQDsV70TfBbsmV9AmGkTT6D+Oz0joIOBt9gcmP0oY
      88vCt7FBjBVnb/SfCHLV1WaWHiYyC6USXqeoOBhsMedmkexYABuotBFlQoOm/AFd
      FhrPh6jjlW1r0jzHmvXOoQlXRAbhK58VroTxTcqgRhMohxbyAWAjRmW648RkNWC+
      GRSS3JxgfO1QOFpp9sKApZZ0ti0fU//32dvCO1okD3rnP0qpNqgOFXCkMFzVubCv
      CEGVAIGa/5weMMeidWFcLC0HYREm3DM62vtI7fcQQwj0iXZi7/WQyUNPG+K57yPM
      k+VJRHuE/dxSubA7QyDFKS9udb9Qf2FK1puuqtr4QfY=
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      bm//SNpqlEY/zbmHNb1LXJAGG2CfLpm3Z/OkR7BOk8G34Yld8DZ0yejjDXv136IN
      ETyBwf7kZCXGP6n0z3Tnp+aZRh4ddVdLVdg29fT66Pnff7/7IT6tyf7xIqa4Ya9y
      EPTPYXj/YDR9zz6RBM0VuUCk+hl0wYrA41mrE2e5eyo0LCJQuX62Aw5ZefVCdPjw
      MRbfjip8huOtC+gqGuCxb+pE7i/qmjkjFpcldPQHEkvHt0nDHO6WKuXIGnrdeTK6
      y0tLnUsRYeqPnNZI6qxpyQ58uiq24FWhQ5F1eSTMtgtyIWCk79GCcEww0HqDXN7J
      dpDBbq9SQyrbsEm4wLnsjVv1MUqF7tKIX2YeeIgph3mH6SBbm0ecjuTQzH6NtQaA
      AIEuyeyUGnsELCAEbLHkd6JwvRdSm+LYn0olAlA3PP+v65v80m2c3zdTg6XIlS8z
      rqJDC0LkdRnsBg+WPwZW2MoNCNZvHFXm9z1M0LSkJ1lgS7MMwgybkSorbN3tvO+R
      p7eL5p0tgS1eqdwBWO75gQj0IVPjPeUHbGQUuQVpgWTDhgAUz6CcTwSfZa41tHdo
      fsTq4OQsFzw1sv/fuG0CKKkLRJcjFu3nqF4AaHm1P+NYao4f5nRDP3v4pA3wgT2b
      8JOoWUhH74topTSHaSCuNu2y7PpuvweUOLMdKIld3po=
      -----END CERTIFICATE-----
    backchannel_key: &backkey |
      -----BEGIN PRIVATE KEY-----
      ZNF17QTx4kfPEfRqI7AA4y3jJ7zXOzT1WBh7XJ8o5Tm/W+zVR5ngC7h5hLZaL4gl
      7nmtDqKWXvY695BByTaW9QB2gM+9y8z5tFNowPkQYsSRpWctjLyOiq6IeuBblJo9
      kJ03hhgdV3zJ1dhnq3p6LDiOw4HqcPkx2LzIPWKQgDGeIzzWPJnDVgD3DfcnuTVs
      zguDOFDpFdiFytQwWWoqHmn1wbrj1p0SHZoVfnDp5HSQ6WZ7kLLTySrYJ920ku8A
      DUlwy287Lwh/qO2hX80lXnqZYqPHXryPqxJK4PtERCCwCJdGRvrFi3CpAn99DhPz
      d4tFBjQu19Z0/rUELPEQuCfbCtscpJZ2q/lir5xjj44yJtiky8Go73uK8E/WslEZ
      kESPaq6LE/4MvlE5pquHkBgZA0u9VigNp+4D0RVbcWhmM5b+ZR2HRszsH+dfjA9f
      8ums30Dxf6TGrhdQLW39Be6fIz0pisVC+hARW/6RmLvQRCmgZTkSZcjQNBICkbLe
      v44pQ1XpbXGP8WpnGKKSyYTyXEV6GwFOzF5uWicUgpzpCJMk1RjXAyiybcg0o5fS
      2xsofsGmuWHyhKEarwEheFEyz1RtQ2h0uWEG3+l1Hi+rQAO1uxnEv1H3cfEu2bc6
      BkvGmo8EcpTkRvBU1aRVHhzGXp3kzR+SPV261qYYDBI=
      -----END PRIVATE KEY-----
    encryption_certificate: &idpcert |
      -----BEGIN CERTIFICATE-----
      XoeaUnFuAXE73GlKja4LiBkXMyEe1QOMwqvQOP+dbUc7C4GVy11PFsR3srRC578l
      aXoemLSeo682V7rmZsC3FXwxDH5H9JhP42AdaMrQLKYviSzHiyHsyiacTgxxqjc1
      sQVQtbxq7vK5opjm66EUqqSnR4ZQOW6NG0uAonoAETaak1yM6ybF7kKvi4nIR0Xg
      zojBbXLAoOFfo6VZluJ2fq207DIzsK6+D9HY2VKst3xJ+k04j2H0dWAVBhm9og13
      L3vK8HRxaN+19ATrLoo1EUBEcLSOgi2O8dsaIETC+xGCbeVb2Kixd157VWodt9vR
      KBJTigpD0fDKiK4JZ4g6m2FlQDsV70TfBbsmV9AmGkTT6D+Oz0joIOBt9gcmP0oY
      88vCt7FBjBVnb/SfCHLV1WaWHiYyC6USXqeoOBhsMedmkexYABuotBFlQoOm/AFd
      FhrPh6jjlW1r0jzHmvXOoQlXRAbhK58VroTxTcqgRhMohxbyAWAjRmW648RkNWC+
      GRSS3JxgfO1QOFpp9sKApZZ0ti0fU//32dvCO1okD3rnP0qpNqgOFXCkMFzVubCv
      CEGVAIGa/5weMMeidWFcLC0HYREm3DM62vtI7fcQQwj0iXZi7/WQyUNPG+K57yPM
      k+VJRHuE/dxSubA7QyDFKS9udb9Qf2FK1puuqtr4QfY=
      -----END CERTIFICATE-----
    encryption_key: &idpkey |
      -----BEGIN PRIVATE KEY-----
      ZNF17QTx4kfPEfRqI7AA4y3jJ7zXOzT1WBh7XJ8o5Tm/W+zVR5ngC7h5hLZaL4gl
      7nmtDqKWXvY695BByTaW9QB2gM+9y8z5tFNowPkQYsSRpWctjLyOiq6IeuBblJo9
      kJ03hhgdV3zJ1dhnq3p6LDiOw4HqcPkx2LzIPWKQgDGeIzzWPJnDVgD3DfcnuTVs
      zguDOFDpFdiFytQwWWoqHmn1wbrj1p0SHZoVfnDp5HSQ6WZ7kLLTySrYJ920ku8A
      DUlwy287Lwh/qO2hX80lXnqZYqPHXryPqxJK4PtERCCwCJdGRvrFi3CpAn99DhPz
      d4tFBjQu19Z0/rUELPEQuCfbCtscpJZ2q/lir5xjj44yJtiky8Go73uK8E/WslEZ
      kESPaq6LE/4MvlE5pquHkBgZA0u9VigNp+4D0RVbcWhmM5b+ZR2HRszsH+dfjA9f
      8ums30Dxf6TGrhdQLW39Be6fIz0pisVC+hARW/6RmLvQRCmgZTkSZcjQNBICkbLe
      v44pQ1XpbXGP8WpnGKKSyYTyXEV6GwFOzF5uWicUgpzpCJMk1RjXAyiybcg0o5fS
      2xsofsGmuWHyhKEarwEheFEyz1RtQ2h0uWEG3+l1Hi+rQAO1uxnEv1H3cfEu2bc6
      BkvGmo8EcpTkRvBU1aRVHhzGXp3kzR+SPV261qYYDBI=
      -----END PRIVATE KEY-----
    signing_certificate: *idpcert
    signing_key: *idpkey

tomcat:
  java_opts:
    -XX:+UseG1GC -Xmx1500m -XX:MaxPermSize=128m
  contexts:
    - name: idp
      hostname: localhost
      engine: Catalina
      docBase: /opt/shibboleth-idp/war/idp.war
      privileged: True
      antiResourceLocking: False
      swallowOutput: True


apache:
  modules:
    proxy: {}
    proxy_ajp: {}
    ssl:
      ## re-enable TLSv1 (interop with Windows Server 2008 R2)
      SSLProtocol: all -SSLv2 -SSLv3

  sites:
    login.example.com:
      VirtualHost *:80:
        ServerName: login.example.com
        ServerAdmin: webmaster@example.com
        IfModule redirect_module:
          Redirect permanent /: https://login.example.com:443/

      IfModule ssl_module:
        VirtualHost *:443:
          ServerName: login.example.com
          ServerAdmin: webmaster@example.com
          SSLEngine: on
          SSLCertificateFile:
            /etc/httpd/certs/login.example.com.cert
          SSLCertificateChainFile:
            /etc/httpd/certs/login.example.com.1.cert
          SSLCertificateKeyFile:
            /etc/httpd/keys/login.example.com.key
          ## HPKP currently disabled pending the results of further testing
          ## (https://developer.mozilla.org/en-US/docs/Web/Security/Public_Key_Pinning)
          # Header always set Public-Key-Pins:
          #   '"pin-sha256=CHANGEME; max-age=5184000"'

          ## relay SAML requests to the Shibboleth IdP
          IfModule proxy_ajp_module:
            ProxyPass "/idp": "ajp://localhost:8009/idp"
            ProxyPassReverse "/idp": "https://login.example.com/idp"

  keypairs:
    login.example.com:
      certificate:
        - *backcert
        ## RHEL 7 includes httpd 2.4.6, which doesn't support
        ## embedding intermediate CA certs in the server certificate
        ## file.
        - |
          -----BEGIN CERTIFICATE-----
          bm//SNpqlEY/zbmHNb1LXJAGG2CfLpm3Z/OkR7BOk8G34Yld8DZ0yejjDXv136IN
          ETyBwf7kZCXGP6n0z3Tnp+aZRh4ddVdLVdg29fT66Pnff7/7IT6tyf7xIqa4Ya9y
          EPTPYXj/YDR9zz6RBM0VuUCk+hl0wYrA41mrE2e5eyo0LCJQuX62Aw5ZefVCdPjw
          MRbfjip8huOtC+gqGuCxb+pE7i/qmjkjFpcldPQHEkvHt0nDHO6WKuXIGnrdeTK6
          y0tLnUsRYeqPnNZI6qxpyQ58uiq24FWhQ5F1eSTMtgtyIWCk79GCcEww0HqDXN7J
          dpDBbq9SQyrbsEm4wLnsjVv1MUqF7tKIX2YeeIgph3mH6SBbm0ecjuTQzH6NtQaA
          AIEuyeyUGnsELCAEbLHkd6JwvRdSm+LYn0olAlA3PP+v65v80m2c3zdTg6XIlS8z
          rqJDC0LkdRnsBg+WPwZW2MoNCNZvHFXm9z1M0LSkJ1lgS7MMwgybkSorbN3tvO+R
          p7eL5p0tgS1eqdwBWO75gQj0IVPjPeUHbGQUuQVpgWTDhgAUz6CcTwSfZa41tHdo
          fsTq4OQsFzw1sv/fuG0CKKkLRJcjFu3nqF4AaHm1P+NYao4f5nRDP3v4pA3wgT2b
          8JOoWUhH74topTSHaSCuNu2y7PpuvweUOLMdKIld3po=
          -----END CERTIFICATE-----
      key: *backkey
