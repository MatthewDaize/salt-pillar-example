base:
  '*':
    - defaults

  'uxedevlnxsalt01.irtnog.net':
    - environment.development
    - role.salt-master
    - salt-dev.irtnog.org

  'uxeprd*mine*.irtnog.net':
    - environment.production
    - role.minecraft

  'uxeprdlnxmine01.irtnog.net':
    - minecraft.irtnog.org
