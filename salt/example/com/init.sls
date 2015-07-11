## The following is used by GitPython to access GitHub as a service
## account named (hypothetically) @example-production-salt-master,
## making use of the SSH configuration management capabilities of
## https://github.com/saltstack-formulas/users-formula.

users:
  root:
    ssh_keys_pillar:
      example-production-salt-master-2015-07-15: users_root_ssh_keys
    ssh_config:
      github:
        hostname: github.com
        options:
          - IdentityFile ~/.ssh/example-production-salt-master-2015-07-15
          - StrictHostKeyChecking no

users_root_ssh_keys:
  example-production-salt-master-2015-07-15:
    ## example keymat
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

## Here's how the Salt master gets configured by Salt, via
## salt-formula.  Bootstrapping requires checking out copies of the
## relevant formulas/pillars to the master's base environment and
## running them manually using state.sls, e.g., "salt-call state.sls
## users,salt.formulas,salt.master".  Once done these local copies
## should be deleted.

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

## Remember to periodically re-run the salt.formulas SLS on the master
## to refresh its copies of the listed Git repositories.

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
