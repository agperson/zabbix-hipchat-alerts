#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'

alert_script = File.dirname(__FILE__) + "/hipchat/notify.rb"
url = "https://zabbix.example.com/zabbix"

YAML.load(ARGV[2]).each { |k, v| instance_variable_set("@" + k, v) }

if @status == "PROBLEM" then
	case @severity
		when "Warning":  color = "yellow"
		when "Average":  color = "purple"
		when "High":     color = "red"
		when "Disaster": color = "red"
		else            color = "gray"
	end
	message = "<strong>#{@status}: #{@name}</strong> (#{@severity})<br />host #{@hostname} [ <a href='#{url}/events.php?triggerid=#{@id}\'>Events</a> | <a href='#{url}/acknow.php?eventid=#{@event_id}'>Acknowledge</a> ]"
else
	color = "green"
	message = "<strong>#{@status}: #{@name}</strong> (#{@severity})<br />host #{@hostname}"
end

exec("#{alert_script} --color #{color} --notify --message \"#{message}\"")
