base:
  '*':
    - defaults

  'uxedevlnxsalt01.irtnog.net':
    - environment.development
    - role.salt-master
    - salt-dev.irtnog.org

  'uxeprdlnxmine01.irtnog.net':
    - environment.production
    - role.minecraft
    - minecraft.irtnog.org
