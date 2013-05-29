zabbix-scripts
==============

Various utility scripts for use with Zabbix

usergroup-update
-----------------------

Synchronize Zabbix group membership with LDAP group membership.  A list of LDAP
groups is specified in the script along with connection details to both Zabbix
and your LDAP directory.  The list of users is fetched from LDAP and compared to
Zabbix.  If the group does not exist, it is created with the same name as the
LDAP group.  Members are then added/removed as necessary (and created if
necessary) to keep the Zabbix accounts in sync with LDAP.  Assumes LDAP
authentication is enabled for login.  Requires the Rubix gem and may require
tweaking to work with a given LDAP server.

dashboard-gen
-----------------------

Generates a static web dashboard by pulling useful data out of Zabbix. This
script is very specific to our use case, but may be useful to others looking
to build similar functionality.  A cron job runs the script every 30 minutes
to generate a pretty dashboard showing hosts and services.

Hosts in our environment serve a variety of applications. Zabbix discovery
rules are used to determine which application services are running on each
host in the cluster. This script iterates through a specified list of
hostgroups and collects a list of hosts into a hash. Then it iterates through
items in a specified application and collects data relevant to the dashboard,
injecting it into the hash.  The data is formatted and output via an ERB
template.
