My Gentoo Customizations
==========================

Using Layman
--------------
### To add this unofficial repo
```
layman -o https://raw.githubusercontent.com/mobalt/gentoo-mods/master/repositories.xml -f -a mobalt
```
### Syncing
Just this repo
```
layman -s mobalt
```

All repos at once
```
layman -S
```

Using just Portage
--------------------
To enable overlay:
1. verify version - Portage (>= 2.2.14)
2. create `/etc/portage/repos.conf/mobalt.conf` with contents:

```
[mobalt]
location = /usr/local/portage/mobalt
sync-type = git
sync-uri = https://github.com/mobalt/gentoo-mods.git
priority=9999
```
