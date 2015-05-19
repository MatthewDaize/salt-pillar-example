base:
  '*':
    - defaults

  ## Make environment assignments based on the hostname 'env' field.
  '???dev*.irtnog.net':
    - environment.development
  '???tst*.irtnog.net':
    - environment.testing
  '???stg*.irtnog.net':
    - environment.staging
  '???prd*.irtnog.net':
    - environment.production

  ## Make role assignments based on the hostname 'role' field.
  '*mx??.irtnog.net':
    - role.mail-relay
  '*lnxvirt??.irtnog.net':
    - role.openstack
  '*salt??.irtnog.net':
    - role.salt-master

  ## Host-specific Pillars
  'uxeprdlnxmine01.irtnog.net':
    - minecraft.irtnog.org
