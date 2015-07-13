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
#### SALT-FORMULA SETTINGS
####

### Remember to periodically re-run the salt.formulas SLS on the
### master to refresh its copies of the listed Git repositories.

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

### Finally, here's how the Salt master gets configured by Salt, via
### salt-formula.  Bootstrapping requires checking out copies of the
### relevant formulas/pillars to the master's base environment and
### running them manually using state.sls, e.g., "salt-call state.sls
### users,salt.formulas,salt.master".  Once done these local copies
### should be deleted.

salt:
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
      - git@github.com:saltstack/salt-winrepo.git
      - git@github.com:example/salt-winrepo-private.git

#### SALT/EXAMPLE/COM/INIT.SLS ends here.
