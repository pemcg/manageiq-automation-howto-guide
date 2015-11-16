#!/usr/env ruby
#
# run_via_api
#
# Author:   Peter McGowan (pemcg@redhat.com)
#           Copyright 2015 Peter McGowan, Red Hat
#
# Revision History
#
require 'rest-client'
require 'json'
require 'optparse'

begin
  options = {
            :server     => nil,
            :username   => nil,
            :password   => nil,
            :domain     => nil,
            :namespace  => nil,
            :class      => nil,
            :instance   => nil,
            :parameters => []
            }
  parser = OptionParser.new do|opts|
    opts.banner = "Usage: run_via_api.rb [options]"
    opts.on('-s', '--server server', 'CloudForms server to connect to') do |server|
      options[:server] = server
    end
    opts.on('-u', '--username username', 'Username to connect as') do |username|
      options[:username] = username
    end
    opts.on('-p', '--password password', 'Password') do |password|
      options[:password] = password
    end
    opts.on('-d', '--domain ', 'Domain') do |domain|
      options[:domain] = domain
    end
    opts.on('-n', '--namespace ', 'Namespace') do |namespace|
      options[:namespace] = namespace
    end
    opts.on('-c', '--class ', 'Class') do |klass|
      options[:class] = klass
    end
    opts.on('-i', '--instance ', 'Instance') do |instance|
      options[:instance] = instance
    end
    opts.on('-P', '--parameter <key,value>', Array, 'Parameter (key => value pair) for the instance') do |parameters|
      unless parameters.length == 2
        puts "Parameter argument must be key,value list"
        exit!
      end
      options[:parameters].push parameters
    end
    opts.on('-h', '--help', 'Displays Help') do
      puts opts
      exit!
    end
  end
  parser.parse!
  
  if options[:password] && options[:prompt]
    puts "Ambiguous: specify either --password or --prompt but not both"
    exit!
  end
  if options[:server].nil?
    server = "cloudforms05.bit63.net"
  else
    server = options[:server]
  end
  if options[:username].nil?
    username = "admin"
  else
    username = options[:username]
  end
  if options[:password].nil?
    password = "smartvm"
  else
    password = options[:password]
  end
  if options[:domain].nil?
    puts "Domain must be specified"
    exit!
  end
  if options[:namespace].nil?
    puts "Namespace must be specified"
    exit!
  end
  if options[:class].nil?
    puts "Class must be specified"
    exit!
  end
  if options[:instance].nil?
    puts "Instance to run must be specified"
    exit!
  end

  url = "https://#{server}"
  #
  # Turn parameter list into hash
  #
  parameter_hash = {}
  options[:parameters].each do |parameter|
    parameter_hash[parameter[0]] = parameter[1]
  end
  
  message = "Running automation method "
  message += "#{options[:namespace]}/#{options[:class]}/#{options[:instance]}"
  message += " using parameters: "
  message += "#{parameter_hash.inspect}"
  puts message
  
  post_params = {
    :version => '1.1',
    :uri_parts => {
      :namespace => "#{options[:domain]}/#{options[:namespace]}",
      :class => options[:class],
      :instance => options[:instance]
    },
    :parameters => parameter_hash,
    :requester => {
      :auto_approve => false
      #:auto_approve => true
    }
  }.to_json
  query = "/api/automation_requests"
  #
  # Issue the automation request
  #
  rest_return = RestClient::Request.execute(method: :post,
                                            url: url + query,
                                            :user     => username,
                                            :password => password,
                                            :headers  => {:accept => :json},
                                            :payload  => post_params,
                                            verify_ssl: false)
  result = JSON.parse(rest_return)
  #
  # get the request ID
  #
  request_id = result['results'][0]['id']
  query = "/api/automation_requests/#{request_id}"
  #
  # Now we have to poll the automate engine to see when the request_state has changed to 'finished'
  #
  rest_return = RestClient::Request.execute(method: :get,
                                            url: url + query,
                                            :user     => username,
                                            :password => password,
                                            :headers  => {:accept => :json},
                                            verify_ssl: false)
  result = JSON.parse(rest_return)
  request_state = result['request_state']
  until request_state == "finished"
    puts "Checking completion state..."
    rest_return = RestClient::Request.execute(method: :get,
                                              url: url + query,
                                              :user     => username,
                                              :password => password,
                                              :headers  => {:accept => :json},
                                              verify_ssl: false)
    result = JSON.parse(rest_return)
    request_state = result['request_state']
    sleep 3
  end
  puts "Results: #{result['options']['return'].inspect}"
rescue => err
  puts "[#{err}]\n#{err.backtrace.join("\n")}"
  exit!
end
