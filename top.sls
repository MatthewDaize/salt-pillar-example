### NOTE REGARDING MINION NAMING CONVENTIONS: All minions have
### hostnames of the form "locenvosfuncid":
###   - loc: the UN/LOCODE location of the minion (sans country code)
###   - env: the minion's assigned environment (e.g., production)
###   - os: 2-4 letter abbreviation of the O/S or hardware vendor
###         (e.g., nt, lnx, bsd, csco)
###   - func: 2-4 letter abbreviation of the role (e.g., mx, salt)
###   - id: two-digit identifier to make names unique
### Hostnames must be at most 15 characters long to comply with
### Microsoft NetBIOS name limits.

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
