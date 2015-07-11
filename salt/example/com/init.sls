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
