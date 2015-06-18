### NOTE REGARDING MINION NAMING CONVENTIONS: All minions have
### hostnames of the form "locenvosfuncid":
###   - loc: the UN/LOCODE location of the minion (sans country code)
###   - env: the minion's assigned environment (e.g., production)
###   - os: 2-4 letter abbreviation of the O/S or hardware vendor
###         (e.g., nt, lnx, bsd, csco)
###   - func: 2-5 letter abbreviation of the role (e.g., mx, salt)
###   - id: two-digit identifier to make names unique
### Hostnames must be at most 15 characters long to comply with
### Microsoft NetBIOS name limits.
###
### "example.net" is the private (internal) administrative realm.
### "example.com" is the public (external) domain.

base:
  '*':
    - defaults

  ## Make environment assignments based on the hostname 'env' field.
  '???dev*.example.net':
    - environment.development
  '???tst*.example.net':
    - environment.testing
  '???stg*.example.net':
    - environment.staging
  '???prd*.example.net':
    - environment.production

  ## Make role assignments based on the hostname 'func' field.
  '*mx??.example.net':
    - role.mail-relay
  '*lnxvirt??.example.net':
    - role.openstack
  '*salt??.example.net':
    - role.salt-master
  '*mine??.example.net':
    - role.minecraft

  ## Host-specific Pillars
  'uxeprdlnxmine01.example.net':
    - minecraft.example.com
  'uxeprdbsdsalt01.example.net':
    - salt.example.com
