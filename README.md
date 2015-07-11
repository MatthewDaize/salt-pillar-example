# IRTNOG Salt Pillar Examples

This repository contains example configuration data in the form of
Salt Pillar key-value pairs.  Aside from special directories such as
`environment` or `role`, pathnames take the form of the
fully-qualified domain names corresponding to the user interfaces of a
particular service level package.  For example, the directory
`minecraft/example/com` corresponds with a service publicly named
*minecraft.example.com*, and the directory `salt/example/com`
corresponds to *salt.example.com*.  This lets us use those services'
FQDNs in `top.sls` for targeting.

For more information plus several example targets, refer to the
comments in `top.sls`.
