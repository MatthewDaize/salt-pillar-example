#### SALT/EXAMPLE/COM/INIT.SLS --- Production Salt master configuration example

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
#### USERS-FORMULA SETTINGS
####

### The following is used by GitPython to access GitHub as a service
### account named (hypothetically) @example-production-salt-master,
### making use of the SSH configuration management capabilities of
### https://github.com/saltstack-formulas/users-formula.  Note the use
### of an RFC 2142 (http://www.rfc-editor.org/rfc/rfc2142.txt) mailbox
### name in the service account's email address.

users:
  root:            # or whatever user the Salt master service runs as
    ## push the GitHub account's SSH keys to the master
    ssh_keys_pillar:
      example-production-salt-master-2015-07-15: users_root_ssh_keys
    ## configure the SSH client
    ssh_config:
      github:
        hostname: github.com
        options:
          - IdentityFile ~/.ssh/example-production-salt-master-2015-07-15
          - StrictHostKeyChecking no

  saltapi:                      # apache/wsgi privilege separation
    home: /var/empty
    createhome: no
    password: '*'

  saltpad:                      # apache/wsgi privilege separation
    home: /var/empty
    createhome: no
    password: '*'

users_root_ssh_keys:
  ## example keymat (These keys---they do nothing!)
  example-production-salt-master-2015-07-15:
    pubkey: |
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpSlXcYFaHeOs0hTfjxSaTWl8gJQt+ZFBQlVFn2ak/w EXAMPLE Production Salt Master <noc@example.com>
    privkey: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACAqUpV3GBWh3jrNIU348Umk1pfICULfmRQUJVRZ9mpP8AAAAKjFbACyxWwA
      sgAAAAtzc2gtZWQyNTUxOQAAACAqUpV3GBWh3jrNIU348Umk1pfICULfmRQUJVRZ9mpP8A
      AAAEBaLWu9qOMS+CrKuoTOZGZs6E03wpG2GTcrEqWMUUvOpypSlXcYFaHeOs0hTfjxSaTW
      l8gJQt+ZFBQlVFn2ak/wAAAAI3hlbm9waG9uQHV4ZXByZGJzZHNhbHQwMS5pcnRub2cubm
      V0AQI=
      -----END OPENSSH PRIVATE KEY-----

####
#### APACHE SLS SETTINGS
####

### The Apache HTTP Server hosts the SaltStack REST API, the SaltPad
### web UI to the Salt master, the Poudriere build server web UI, and
### a Poudriere-managed FreeBSD package repository.

apache:
  packages:
    - apache24
    - ap24-mod_security
    - ap24-mod_wsgi3
    - py27-cherrypy
  modules:
    wsgi: {}
  envvars:
    ## point rest_cherrypy at the salt-master config
    SALT_MASTER_CONFIG: /usr/local/etc/salt/master.d/f_defaults.conf
  sites:
    salt.example.com:
      VirtualHost *:80:
        ServerName: salt.example.com
        ServerAdmin: webmaster@example.com
        IfModule redirect_module:
          Redirect permanent /: http://salt.example.com:443/
      IfModule ssl_module:
        VirtualHost *:443:
          ServerName: salt.example.com
          ServerAdmin: webmaster@example.com
          SSLEngine: on
          SSLCertificateFile: /usr/local/etc/apache24/certs/salt.example.com.cert
          SSLCertificateKeyFile: /usr/local/etc/apache24/keys/salt.example.com.key
          IfModule alias_module:
            Alias /poudriere: /usr/local/share/poudriere/html
            Alias /poudriere/data: /var/poudriere/data/logs/bulk
            Alias /packages: /var/poudriere/data/packages
          Directory /usr/local/share/poudriere/html:
            Require all: granted
          Directory /var/poudriere/data:
            Require all: granted
            Options: Indexes
          Directory /var/poudriere/data/packages:
            Options: FollowSymLinks
          IfModule wsgi_module:
            ## saltstack (Salt REST API via CherryPy)
            WSGIDaemonProcess saltstack: processes=2 threads=5
            WSGIScriptAlias /saltstack: /usr/local/lib/python2.7/site-packages/salt/netapi/rest_cherrypy/wsgi.py
            Directory /usr/local/lib/python2.7/site-packages/salt/netapi/rest_cherrypy/:
              WSGIProcessGroup: saltstack
              Require all: granted
            ## saltpad (SaltStack web UI via Flask)
            WSGIDaemonProcess saltpad: processes=2 threads=5
            WSGIScriptAlias /saltpad: /opt/saltpad/saltpad.wsgi
            Directory /opt/saltpad:
              WSGIProcessGroup: saltpad
              Require all: granted
  keypairs:
    salt.example.com:
      ## list the server certificate first followed by intermediate
      ## (chain) certificates, in leaf-to-root order
      certificate: |
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
      key: |
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

####
#### POUDRIERE SLS SETTINGS
####

poudriere:
  url_base: https://salt.example.com/poudriere/
  git_url: git@github.com:example/freebsd-ports
  pkglist:                      # just a short example
    - editors/emacs
    - www/w3m
    - x11/xorg
    - x11-fonts/xorg-fonts
    - x11-wm/xfce4
  repo:
    secret: |
      -----BEGIN RSA PRIVATE KEY-----
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
      -----END RSA PRIVATE KEY-----

####
#### SALT-FORMULA SETTINGS
####

### Remember to periodically re-run the salt.formulas SLS on the
### master to refresh its copies of the listed Git repositories.  Best
### practice is to fork the desired formulas, so that changes are
### under control of the system operator instead of a third party.

salt_formulas:
  git_opts:
    default:
      baseurl: git@github.com:example
      basedir: /usr/local/etc/salt/formulas
      update: True
  basedir_opts:
    makedirs: True
    user: root
    group: wheel
    mode: 755
  list:
    development:
      - epel-formula
      - fail2ban-formula
      - git-formula
      - jenkins-formula
      - mysql-formula
      - ntp-formula
      - nux-formula
      - openstack-formula
      - openssh-formula
      - os-hardening-formula
      - owncloud-formula
      - postgres-formula
      - rabbitmq-formula
      - salt-formula
      - snmp-formula
      - spigotmc-formula
      - sudoers-formula
      - twgs-formula
      - users-formula
    testing:
      - epel-formula
      - fail2ban-formula
      - git-formula
      - jenkins-formula
      - mysql-formula
      - ntp-formula
      - nux-formula
      - openstack-formula
      - openssh-formula
      - os-hardening-formula
      - owncloud-formula
      - postgres-formula
      - rabbitmq-formula
      - salt-formula
      - snmp-formula
      - spigotmc-formula
      - sudoers-formula
      - twgs-formula
      - users-formula
    staging:
      - epel-formula
      - fail2ban-formula
      - git-formula
      - jenkins-formula
      - mysql-formula
      - ntp-formula
      - nux-formula
      - openstack-formula
      - openssh-formula
      - os-hardening-formula
      - owncloud-formula
      - postgres-formula
      - rabbitmq-formula
      - salt-formula
      - snmp-formula
      - spigotmc-formula
      - sudoers-formula
      - twgs-formula
      - users-formula
    production:
      - epel-formula
      - fail2ban-formula
      - git-formula
      - jenkins-formula
      - mysql-formula
      - ntp-formula
      - nux-formula
      - openstack-formula
      - openssh-formula
      - os-hardening-formula
      - owncloud-formula
      - postgres-formula
      - rabbitmq-formula
      - salt-formula
      - snmp-formula
      - spigotmc-formula
      - sudoers-formula
      - twgs-formula
      - users-formula

salt:
  ## Here's how the Salt master gets configured by Salt, via
  ## salt-formula.  Bootstrapping requires checking out copies of the
  ## relevant formulas/pillars to the master's base environment and
  ## running them manually using state.sls, e.g., "salt-call state.sls
  ## users,salt.formulas,salt.master".  Once done these local copies
  ## should be deleted.
  master:
    fileserver_backend:
      - git
      - roots
    file_roots:
      base:
        - /usr/local/etc/salt/states
      development:
        - /usr/local/etc/salt/devstates
    gitfs_provider: GitPython
    gitfs_remotes:
      - git@github.com:example/salt-states.git
    ext_pillar:
      - git: master git@github.com:example/salt-pillars.git
    win_gitrepos:
      - git@github.com:example/salt-winrepo.git # fork of saltstack/salt-winrepo.git
      - git@github.com:example/salt-winrepo-private.git
    ## This is required by the current version of SaltPad.  (Public
    ## access to the master via the REST API should go through the
    ## WSGI-hosted service endpoint that's protected by ModSecurity.)
    rest_cherrypy:
      port: 8000
      ssl_crt: /usr/local/etc/apache24/certs/salt.example.com.cert
      ssl_key: /usr/local/etc/apache24/keys/salt.example.com.key
    external_auth:              # required by salt-api
      pam:
        someuser:
          - .*
          - '@runner'
          - '@wheel'

  ## These settings control salt-cloud.  Note that salt-formula does
  ## not provide templates for the contents of
  ## cloud.{maps,profiles,providers}.d/*.conf; instead, refer to the
  ## files named after the corresponding provider in the
  ## irtnog/salt-states.git repository, under salt/files/ in one of
  ## the four branches (development, testing, staging, or production).
  cloud:
    master: salt.example.com
    folders:
      - cloud.providers.d/key
      - cloud.profiles.d
      - cloud.maps.d
    providers:
      - example-ec2
    example-ec2-key-id: AKIAIOSFODNN7EXAMPLE
    example-ec2-secret: wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY

####
#### SALTPAD SLS SETTINGS
####

### SaltPad is a web UI for Salt.  It requires salt-api, which in this
### configuration is hosted by mod_wsgi.

saltpad:
  ## The current version only works with the salt-api service.
  api_url: https://salt.example.com:8000

  ## Generate a random key with the following shell command:
  ## python -c 'import os, pprint; pprint.pprint(os.urandom(24))'
  secret_key: ' \xcf9\x02\xc5p\xbd)\x96H5\x1f\xd2\xc8f\xe2\xfa(\x018\x0c\x1b)h'

#### SALT/EXAMPLE/COM/INIT.SLS ends here.
