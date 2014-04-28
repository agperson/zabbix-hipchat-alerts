#!/usr/bin/env ruby

require 'rubygems'
require 'micro-optparse'
require 'net/https'
require 'uri'
require 'json'
require 'yaml'

# Load configuration
config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yaml'))

endpoint = config['endpoint'] || 'api.hipchat.com'
room     = config['room']
token    = config['token']

options = Parser.new do |p|
  p.option :verbose, "verbose output", :default => false
  p.option :color,   "background color", :default => 'random', :value_in_set => [ 'yellow', 'red', 'green', 'purple', 'gray', 'random' ]
  p.option :message, "message plaintext or escaped html", :default => "No message specified"
  p.option :notify,  "notify people in room", :default => false
  p.option :format,  "message format", :default => 'html', :value_in_set => [ 'html', 'text' ]
end.process!

p options

puts "Sending message to #{endpoint} room #{room}" if options[:verbose]

uri = URI.parse("https://#{endpoint}/v2/room/#{room}/notification?auth_token=#{token}")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri)
request.body = {
  "color"          => options[:color],
  "message"        => options[:message],
  "message_format" => options[:format],
  "notify"         => options[:notify],
}.to_json
request['Content-Type'] = 'application/json'
http.request(request)
