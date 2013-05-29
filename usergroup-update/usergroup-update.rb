#!/usr/bin/env ruby

require 'rubygems'
require 'rubix'
require 'ldap'

# List of LDAP groups to synchronize
groups = [
  "group1",
  "group2"
]

# Zabbix login credentials
api_dest = "https://zabbix.mycompany.com/zabbix/api_jsonrpc.php"
api_user = "admin"
api_pass = "password"

# LDAP query parameters
ldap_host   = "ldap.mycompany.com"
ldap_base   = "ou=People,dc=mycompany,dc=com"
ldap_scope  = LDAP::LDAP_SCOPE_SUBTREE

# Connect to LDAP
ldap = LDAP::Conn.new(ldap_host, 389)

# Login to Zabbix server
zabbix = Rubix.connect(api_dest, api_user, api_pass)

# Iterate through each group
groups.each do |group|
  # Find the group in Zabbix.  If it does not exist, create it.
  response = zabbix.request('usergroup.get', 'filter' => { 'name' => group } )

  if response.empty?
    response = zabbix.request('usergroup.create', 'name' => group)
    grpid    = response["usrgrpids"][0].to_i
    puts "Created #{group} with ID #{grpid}."
  else
    grpid    = response.result[0]['usrgrpid'].to_i
  end

  # Determine LDAP group membership
  filter = "(&(objectclass=posixGroup)(cn=#{group}))"
  attrs  = "memberUid"
  ldap_membership = []

  begin
    ldap.search(ldap_base, ldap_scope, filter, attrs) do |entry|
      ldap_members = entry.vals('memberUid')

      # Remove DN results and keep just short username results
      ldap_members.delete_if { |u| u =~ /^uid=/ }

      ldap_members.each do |user|
        filter = "(&(objectclass=posixAccount)(uid=#{user}))"
        attrs  = [ "uid", "givenName", "sn", "mail" ] 
        begin
          ldap.search(ldap_base, ldap_scope, filter, attrs) do |entry|
            ldap_membership << entry.to_hash
          end
        rescue LDAP::ResultError
          ldap.perror("search")
          next
        end
      end
    end
  rescue LDAP::ResultError
    ldap.perror("search")
    next
  end

  # Find each user in Zabbix. If they do not exist, create them.
  userids = []
  ldap_membership.each do |user|
    uid = user["uid"].to_s
    response = zabbix.request('user.get', 'filter' => { 'alias' => uid } )
    if response.empty?
      response = zabbix.request('user.create',
        "alias"          => uid,
        "name"           => user["givenName"].to_s,
        "surname"        => user["sn"].to_s,
        "passwd"         => rand(36**12).to_s(36),
        "url"            => "/zabbix/dashboard.php",
        "lang"           => "en_GB",
        "autologin"      => 0,
        "autologout"     => 900,
        "refresh"        => 300,
        "rows_per_page"  => 50,
        "theme"          => "originalblue",
        "type"           => 1,
        "usrgrps"        => [{ "usrgrpid" => 20 }] # Generic "Users" group
      )
      userids << response["userids"][0].to_i
      puts "Created user #{uid} with ID #{response["userids"][0].to_i}."
    else
      userids << response[0]["userid"].to_i
    end
  end

  # Mass update Zabbix group membership (Zabbix will automatically add/remove
  # users to achieve this result).
  puts "Mass updating group #{group}."
  response = zabbix.request('usergroup.massupdate',
    "usrgrpids" => grpid,
    "userids"   => userids
  )
end

ldap.unbind
exit
