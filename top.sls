#### TOP.SLS ---Apply listed SLS modules to the targetd Salt minions

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

### NOTE REGARDING PCRE: Minion IDs may not be consistenly lower
### cased, so this uses case-insensitive regular expressions to match
### minion IDs.

base:
  '*':
    - defaults

  ## Make environment assignments based on the hostname 'env' field.
  '(?i)...dev.*\.example\..net':
    - match: pcre
    - environment.development
  '(?i)...tst.*\.example\.net':
    - match: pcre
    - environment.testing
  '(?i)...prd.*\.example\.net':
    - match: pcre
    - environment.production

  ## Make role assignments based on the hostname 'func' field.
  '(?i).*lnxvirt[0-9a-f]{2}\.example\.net':
    - match: pcre
    - role.openstack
  '(?i).*mine[0-9a-f]{2}\.example\.net':
    - match: pcre
    - role.minecraft
  '(?i).*mx[0-9a-f]{2}\.example\.net':
    - match: pcre
    - role.mail-relay
  '(?i).*salt[0-9a-f]{2}\.example\.net':
    - match: pcre
    - role.salt-master
  '(?i).*idp[0-9a-f]{2}\.example\.net':
    - match: pcre
    - role.shibboleth-idp

  ## Desktops and laptops use a different naming convention because
  ## there are many more of them (relative to servers).
  '(?i)d[0-9]{8}\.example\.net':
    - match: pcre
    - environment.production
    - role.desktop
  '(?i)l[0-9]{8}\.example\.net':
    - match: pcre
    - environment.production
    - role.laptop

  ## Manually assign service-specific Pillar SLSes.  The Pillar SLS
  ## name follows the FQDN of the public service endpoint (e.g.,
  ## several web servers might host "www.example.com", so they're
  ## assigned that Pillar SLS, with the Pillar data stored in the file
  ## www/example/com/init.sls).
  '(?i)uxeprdlnxmine01\.example\.net':
    - match: pcre
    - minecraft.example.com
  '(?i)uxeprdbsdmx01\.example\.net':
    - match: pcre
    - mx1.example.com
  '(?i)uxeprdbsdmx02\.example\.net':
    - match: pcre
    - mx2.example.com
  '(?i)uxeprdbsdsalt01\.example\.net':
    - match: pcre
    - salt.example.com
  '(?i)uxeprdbsdweb0[1-2]\.example\.net':
    - match: pcre
    - www.example.com
  '(?i)uxeprdlnxidp0[1-2]\.example\.net':
    - match: pcre
    - login.example.com

  ## Finally, assign an optional host-specific Pillar SLS.
  {{ grains.id|yaml_encode }}:
    - ignore_missing: True
    - {{ grains.id|lower|yaml_encode }}

#### TOP.SLS ends here.
