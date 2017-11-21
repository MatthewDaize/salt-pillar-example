#!jinja|yaml|gpg
#### LOGIN.EXAMPLE.COM --- Production Shibboleth IdP 3.x

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

{#- Shibboleth Identity Provider settings #}
{%- import_text "login/example/com/idp_keystore_password.gpg" as idp_keystore_password %}
{%- import_text "login/example/com/idp_sealer_password.gpg" as idp_sealer_password %}
{%- import_text "login/example/com/idp_cert.pem" as idp_cert %}
{%- import_text "login/example/com/idp_privkey.pem.gpg" as idp_privkey %}
{%- import_text "login/example/com/idp_ldap_bind_dn.gpg" as idp_ldap_bind_dn %}
{%- import_text "login/example/com/idp_ldap_bind_cred.gpg" as idp_ldap_bind_cred %}
{%- import_text "login/example/com/idp_persistent_id_salt.gpg" as idp_persistent_id_salt %}
{%- import_text "login/example/com/mdq_beta_cert.pub" as mdq_beta_cert_pubkey %}
{%- import_text "md/example/com/mda_signing_cert.pub" as mda_signing_cert_pubkey %}

####
#### SHIBBOLETH-FORMULA SETTINGS
####

shibboleth:
  idp:
    hostname: login.example.com
    entity_id: https://login.example.com/idp/shibboleth
    scope: example.com
    cookie_secure: yes
    session_timeout: PT8H
    authn_default_lifetime: PT8H

    ## UI customization
    message_idp_title: Example Web Login Service
    # TODO: message_idp_logo
    message_idp_logo_alt_text: Example
    message_idp_url_password_reset: https://password.example.com/
    message_idp_url_helpdesk: mailto:support@example.com

    ## IdP keying material
    keystore_password: {{ idp_keystore_password|yaml_encode }}
    sealer_password: {{ idp_sealer_password|yaml_encode }}
    encryption_certificate: &idpcert {{ idp_cert|yaml_encode }}
    encryption_key: &idpkey {{ idp_privkey|yaml_encode }}
    signing_certificate: *idpcert
    signing_key: *idpkey

    ## This specifies the X.509 key-pair for the IdP back-channel, a
    ## SOAP endpoint used for attribute query, SAML artifacts, and
    ## back-channel logout.  In general this should be the same as the
    ## signing key-pair.
    backchannel_certificate: *idpcert
    backchannel_key: *idpkey

    ## Deploy Shibboleth IdP using the same service account as the
    ## desired Java servlet container (here, Apache Tomcat).
{%- if grains['os_family'] == 'Debian' %}
    user: tomcat8
    group: tomcat8
{%- elif grains['os_family'] == 'FreeBSD' %}
    user: www
    group: www
{%- elif grains['os_family'] == 'RedHat' %}
    user: tomcat
    group: tomcat
{%- endif %}

    # ## Include the Tomcat package when installing Shibboleth IdP, as
    # ## this creates the above service account/group; otherwise, the
    # ## shib.idp and tomcat states can't be applied idempotently.
    # packages:
    #   - java-1.8.0-openjdk-devel
    #   - bash
    #   - tomcat

    ## Configure the LDAP client to use Active Directory Domain
    ## Services (AD DS).
    ldap_authenticator: bindSearchAuthenticator # or adAuthenticator?
    ldap_url: &idpldapurl ldaps://example.net:636
    ldap_use_starttls: no
    ldap_use_ssl: yes
    ldap_ssl_config: jvmTrust
    ldap_base_dn: &idpldapbasedn ou=MyBusiness,dc=example,dc=net
    ldap_subtree_search: True
    ldap_user_filter: (sAMAccountName={user})
    ldap_bind_dn: &idpldapbinddn {{ idp_ldap_bind_dn|yaml_encode }}
    ldap_bind_credential: &idpldapbindcred {{ idp_ldap_bind_cred|yaml_encode }}
    ldap_dn_format: '%s@EXAMPLE.NET'

    ## Trust the following sources of federation metadata.
    metadata_providers:
      - https://signin.aws.amazon.com/static/saml-metadata.xml
      - url: http://mdq-beta.incommon.org/global
        type: DynamicHTTPMetadataProvider
        filters:
          - type: SignatureValidation
            require_signed_root: yes
            ## https://ds.incommon.org/certs/mdq-beta-cert.pem
            public_key: {{ mdq_beta_cert_pubkey|yaml_encode }}
          - type: RequiredValidUntil
            max_validity_period: P14D
          - type: EntityRoleWhiteList
            retained_roles:
              - md:SPSSODescriptor
      - url: http://md.example.com/example-metadata.xml
        min_refresh_delay: PT5M
        max_refresh_delay: PT1H
        refresh_delay_factor: 0.75
        filters:
          - type: SignatureValidation
            require_signed_root: yes
            public_key: {{ mda_signing_cert_pubkey|yaml_encode }}
          - type: RequiredValidUntil
            max_validity_period: P14D
          - type: EntityRoleWhiteList
            retained_roles:
              - md:SPSSODescriptor

    ## Define attributes generated for authenticated users.
    resolver_attribute_definitions:
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
      - id: cn
        type: ad:Simple
        source_attribute_id: displayName
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:cn
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:2.5.4.3
            encode_type: False
      - id: upn
        type: ad:Simple
        source_attribute_id: userPrincipalName
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML2String
            name: http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn
            encode_type: False
      ## https://www.incommon.org/federation/attributesummary.html
      ## https://refeds.org/category/research-and-scholarship
      - id: eduPersonScopedAffiliation
        type: ad:Scoped
        scope: '%{idp.scope}'
        source_attribute_id: affiliation
        dependencies:           # NB: references data connector
          - staticAttributes
        attribute_encoders:
          - type: enc:SAML1ScopedString
            name: urn:mace:dir:attribute-def:eduPersonScopedAffiliation
            encode_type: False
          - type: enc:SAML2ScopedString
            name: urn:oid:1.3.6.1.4.1.5923.1.1.1.9
            friendly_name: eduPersonScopedAffiliation
            encode_type: False
      - id: eduPersonPrincipalName
        type: ad:Scoped
        scope: '%{idp.scope}'
        source_attribute_id: uid
        dependencies:           # NB: references another attribute
          - uid
        attribute_encoders:
          - type: enc:SAML1ScopedString
            name: urn:mace:dir:attribute-def:eduPersonPrincipalName
            encode_type: False
          - type: enc:SAML2ScopedString
            name: urn:oid:1.3.6.1.4.1.5923.1.1.1.6
            friendly_name: eduPersonPrincipalName
            encode_type: False
      - id: sn
        type: ad:Simple
        source_attribute_id: sn
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:sn
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:2.5.4.4
            encode_type: False
      - id: givenName
        type: ad:Simple
        source_attribute_id: givenName
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:givenName
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:2.5.4.42
            encode_type: False
      - id: displayName
        type: ad:Simple
        source_attribute_id: displayName
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:displayName
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:2.16.840.1.113730.3.1.241
            encode_type: False
      - id: mail
        type: ad:Simple
        source_attribute_id: mail
        dependencies:
          - ActiveDirectory
        attribute_encoders:
          - type: enc:SAML1String
            name: urn:mace:dir:attribute-def:mail
            encode_type: False
          - type: enc:SAML2String
            name: urn:oid:0.9.2342.19200300.100.1.3
            friendly_name: mail
            encode_type: False
      ## https://get.slack.help/hc/en-us/articles/205168057
      - id: User.Email
        type: ad:Simple
        source_attribute_id: mail
        dependencies:
          - mail
        attribute_encoders:
          - type: enc:SAML2String
            name: User.Email
            encode_type: False
      - id: User.Username
        type: ad:Simple
        source_attribute_id: uid
        dependencies:
          - uid
        attribute_encoders:
          - type: enc:SAML2String
            name: User.Username
            encode_type: False
      ## https://documentation.meraki.com/zGeneral_Administration/Managing_Dashboard_Access/Configuring_SAML_Single_Sign-on_for_Dashboard
      - id: MerakiDashboardUsername
        type: ad:Simple
        source_attribute_id: uid
        dependencies:
          - uid
        attribute_encoders:
          - type: enc:SAML2String
            name: https://dashboard.meraki.com/saml/attributes/username
            encode_type: False
      - id: MerakiDashboardRole
        type: ad:Simple
        source_attribute_id: meraki_role
        dependencies:
          - staticAttributes
        attribute_encoders:
          - type: enc:SAML2String
            name: https://dashboard.meraki.com/saml/attributes/role
            encode_type: False
      ## http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_saml_assertions.html
      - id: AmazonWebServicesIAMRole
        type: ad:Simple
        source_attribute_id: aws_role
        dependencies:
          - staticAttributes
        attribute_encoders:
          - type: enc:SAML2String
            name: https://aws.amazon.com/SAML/Attributes/Role
            encode_type: False
      - id: AmazonWebServicesIAMRoleSessionName
        type: ad:Simple
        source_attribute_id: uid
        dependencies:
          - uid
        attribute_encoders:
          - type: enc:SAML2String
            name: https://aws.amazon.com/SAML/Attributes/RoleSessionName
            encode_type: False
      - id: AmazonWebServicesIAMSessionDuration
        type: ad:Simple
        source_attribute_id: aws_session_duration
        dependencies:
          - staticAttributes
        attribute_encoders:
          - type: enc:SAML2String
            name: https://aws.amazon.com/SAML/Attributes/SessionDuration
            encode_type: False

    resolver_data_connectors:
      - id: staticAttributes
        type: dc:Static
        attributes:
          - id: affiliation
            value: member
          - id: meraki_role     # FIXME: totally insecure
            value: Organization Admins
          - id: aws_role        # TODO: multi-valued attributes
            value: arn:aws:iam::123456789012:role/FederatedUserRole,arn:aws:iam::123456789012:saml-provider/MyIdentityProvider
          - id: aws_session_duration
            value: 43200        # 12 hours (specified in seconds)
      - id: ActiveDirectory
        type: dc:LDAPDirectory
        url: *idpldapurl
        base_dn: *idpldapbasedn
        bind_dn: *idpldapbinddn
        bind_credential: *idpldapbindcred
        filter_template:
          (sAMAccountName=$requestContext.principalName)
        return_attributes:
          - objectGUID
          - userPrincipalName
          - givenName
          - sn
          - displayName
          - mail
          - distinguishedName
        ldap_properties:
          - property:
              java.naming.ldap.attributes.binary
            value:
              objectGUID

    ## Control which attributes get released to which service
    ## providers.
    attribute_filter_policies:
      ## Release common attributes to all SPs.
      - if: ANY
        then:
{%- for attribute in [
      'uid',
      'cn',
      'upn',
    ] %}
          - release: {{ attribute }}
            permit: ANY
{%- endfor %}
      ## Release the REFEDS R&S attribute bundle to all SPs.
      - if: ANY
        then:
{%- for attribute in [
      'eduPersonScopedAffiliation',
      'eduPersonPrincipalName',
      'sn',
      'givenName',
      'displayName',
      'mail'
    ] %}
          - release: {{ attribute }}
            permit: ANY
{%- endfor %}
      ## Only release the requested email address and username
      ## attributes to the Slack SP.
      - if:
          Requester: https://slack.com/
        then:
{%- for attribute in [
      'uid',
      'cn',
      'upn',
      'eduPersonScopedAffiliation',
      'eduPersonPrincipalName',
      'sn',
      'givenName',
      'displayName',
      'mail'
    ] %}
          - release: {{ attribute }}
            deny: ANY
{%- endfor %}
          - release: User.Email
            permit: ANY
          - release: User.Username
            permit: ANY
      ## Release only username and role to the Meraki Dashboard SP.
      - if:
          Requester: https://dashboard.meraki.com/
        then:
{%- for attribute in [
      'uid',
      'cn',
      'upn',
      'eduPersonScopedAffiliation',
      'eduPersonPrincipalName',
      'sn',
      'givenName',
      'displayName',
      'mail'
    ] %}
          - release: {{ attribute }}
            deny: ANY
{%- endfor %}
          - release: MerakiDashboardUsername
            permit: ANY
          - release: MerakiDashboardRole
            permit: ANY
      ## In addition to the customary attributes, release the AWS IAM
      ## Role, Role Session Name, and Session Duration to the AWS SP.
      - if:
          Requester: urn:amazon:webservices
        then:
{%- for attribute in [
      'AmazonWebServicesIAMRole',
      'AmazonWebServicesIAMRoleSessionName',
      'AmazonWebServicesIAMSessionDuration',
    ] %}
          - release: {{ attribute }}
            permit: ANY
{%- endfor %}

    ## Override the default relying party configuration for selected
    ## service providers.
    rp_profile_overrides:
      - relying_parties:
          - https://dashboard.meraki.com/
          - urn:amazon:webservices
        profiles:
          - parent: SAML2.SSO
            encrypt_assertions: False

    ## Configure persistent NameID generation.
    persistent_id_source_attribute: uid
    persistent_id_salt: {{ idp_persistent_id_salt|yaml_encode }}

####
#### TOMCAT-FORMULA SETTINGS
####

tomcat:
  java_home: /usr/lib/jvm/java
  java_opts:
    - 'XX:+UseG1GC'
    - 'Xmx2048m'
    - 'XX:MaxPermSize=128m'
    - 'classpath /usr/share/java/mysql-connector-java.jar'
  connectors:
    ajp:
      port: 8009
      protocol: AJP/1.3

####
#### APACHE-FORMULA
####

apache:
  sites:
    80-login.example.com: &httpsredirect
      enabled: True
      template_file: salt://apache/vhosts/https-redirect.tmpl
      ServerName: login.example.com
      ServerAlias: False
      ServerAdmin: webmaster@example.com
      LogLevel: False
      ErrorLog: False
      LogFormat: False
      CustomLog: False
      DocumentRoot: /opt/rh/httpd24/root/var/www/html

    443-login.example.com: &standardsite
      enabled: True
      template_file: salt://apache/vhosts/standard.tmpl
      port: '443'
      ServerName: login.example.com
      ServerAlias: False
      ServerAdmin: webmaster@example.com
      LogLevel: False
      ErrorLog: False
      LogFormat: False
      CustomLog: False
      SSLCertificateFile: /etc/letsencrypt/live/login.example.com/cert.pem
      SSLCertificateChainFile: /etc/letsencrypt/live/login.example.com/chain.pem
      SSLCertificateKeyFile: /etc/letsencrypt/live/login.example.com/privkey.pem
      DocumentRoot: /opt/rh/httpd24/root/var/www/443-login.example.com
      Formula_Append: |
        ProxyPass /idp ajp://localhost:8009/idp
        ProxyPassReverse /idp https://login.example.com/idp
        Redirect /amazon https://login.example.com/idp/profile/SAML2/Unsolicited/SSO?providerId=urn:amazon:webservices
        Redirect /aws https://login.example.com/idp/profile/SAML2/Unsolicited/SSO?providerId=urn:amazon:webservices
        Redirect /meraki https://login.example.com/idp/profile/SAML2/Unsolicited/SSO?providerId=https%3A%2F%2Fdashboard.meraki.com%2F

  envvars:
    - export OPENSSL_NO_DEFAULT_ZLIB=1

#### LOGIN.EXAMPLE.COM ends here.
