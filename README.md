zabbix-scripts
==============

Various utility scripts for use with Zabbix

zbx-usergroup-update.rb
-----------------------

Synchronize Zabbix group membership with LDAP group membership.  A list of LDAP
groups is specified in the script along with connection details to both Zabbix
and your LDAP directory.  The list of users is fetched from LDAP and compared to
Zabbix.  If the group does not exist, it is created with the same name as the
LDAP group.  Members are then added/removed as necessary (and created if
necessary) to keep the Zabbix accounts in sync with LDAP.  Assumes LDAP
authentication is enabled for login.  Requires the Rubix gem and may require
tweaking to work with a given LDAP server.
