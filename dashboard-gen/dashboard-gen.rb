#!/usr/bin/env ruby

require 'rubygems'
require 'rubix'
require 'erb'
require 'yaml'

# Load Zabbix connection details from config file and connect
config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yaml'))
zabbix = Rubix.connect(config['host'], config['user'], config['pass'])

# HTML template file
template = File.join(File.dirname(__FILE__), 'dashboard.html.erb')

# Delcare some variables
html = ""
total_hosts = 0
total_services = 0

# Method to print lozenge HTML
def lozenge(host, service, port, processes)
  status = (processes > 0) ? "running" : "stopped"
  return <<-EOL
        <a href="http://#{host}:#{port}/">
          <div class="lozenge #{status}">
            <div class="status #{status}">#{processes}</div>
            <div class="service">#{service}</div>
          </div>
        </a>
  EOL
end

# Iterate through each group
config['hostgroups'].each do |hostgroup|
  # Reset variables on each run
  hosts = {}
  counter = 0

  # Determine the group ID
  response = zabbix.request('hostgroup.get', 'filter' => { 'name' => "#{hostgroup}" })
  hostgroupid = response.result[0]['groupid'].to_i
  #puts "#{hostgroup} (#{hostgroupid})"

  # Find the list of hosts in the host group
  response = zabbix.request('host.get', 'groupids' => hostgroupid, 'output' => ['hostid', 'name', 'host'])
  response.result.each do |host|
    #puts host['name']

    hostid = host['hostid']
    hosts[hostid] = { 'name' => host['name'], 'fqdn' => host['host'], 'items' => [] }
  end

  # Grab all the application items that belong to the given hostids
  response = zabbix.request('item.get', 'hostids' => hosts.keys, 'application' => config['application'], 'output' => ['key_', 'name', 'lastvalue'])

  items = response.result

  # Link up each item with its host
  items.each do |i|
    item = {
      # Data is pulled from check description and key, these values need to be
      # customized to your environment
      'service' => i['name'].match(/^Service ([^:]+)/)[1],
      'port'    => i['key_'].match(/,(.*)\]$/)[1],
      'value'   => i['lastvalue'],
    }
    hosts[i['hostid']]['items'] << item
  end

  # Pop and sort the hosts alphabetically
  hosts = hosts.values
  hosts.sort! { |x, y| x['name'] <=> y['name'] }

  # Now loop through each host and generate the HTML to display
  html << "    <div class=\"hostgroup\">\n"
  html << "      <h2>#{hostgroup}</h2>\n"
  hosts.each do |host|
    shader = (counter % 2) == 0 ? "even" : "odd"
    html << "      <div class=\"host #{shader}\">\n"
    html << "        <h3>#{host['name']}</h3>\n"
    host['items'].each do |item|
      loz = lozenge host['name'], item['service'], item['port'], item['value'].to_i
      html << loz
      total_services += 1
    end
    html << "      </div>\n"
    counter += 1
    total_hosts += 1
  end
  html << "    </div>"
end

# Generate the final HTML file
puts ERB.new(File.read(template)).result
