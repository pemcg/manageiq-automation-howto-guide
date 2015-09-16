## Calling Automation from the RESTful API

We can call any Automation Instance from the RESTful API, by issuing a _POST_ call to /api/automation_requests, and enclosing a JSON-encoded parameter hash such as the following...

```ruby
post_params = {
  :version => '1.1',
  :uri_parts => {
    :namespace => 'ACME/General',
    :class => 'Methods',
    :instance => 'HelloWorld'
  },
  :requester => {
    :auto_approve => true
  }
}.to_json
```

We can call the RESTful API from an external Ruby script by using the rest-client gem...

```ruby
url = 'https://cloudforms_server'
query = '/api/automation_requests'
rest_return = RestClient::Request.execute(method: :post, url: url + query, :user => username, \
                :password => password, :headers => {:accept => :json}, :payload => post_params, \
                verify_ssl: false)
result = JSON.parse(rest_return)
```

The request ID is returned to us in the result from the initial call...

```ruby
request_id = result['results'][0]['id']
```

...and we call poll this to check on status...

```ruby
query = "/api/automation_requests/#{request_id}"
rest_return = RestClient::Request.execute(method: :get, url: url + query, :user => username, \
                :password => password, :headers => {:accept => :json}, verify_ssl: false)
result = JSON.parse(rest_return)
request_state = result['request_state']
until request_state == "finished"
  puts "Checking completion state..."
  rest_return = RestClient::Request.execute(method: :get, url: url + query, :user => username, \
                  :password => password, :headers => {:accept => :json}, verify_ssl: false)
  result = JSON.parse(rest_return)
  request_state = result['request_state']
  sleep 3
end
```

#### Returning Results to the Caller

The _request_ task's options hash is included in the return from the RestClient::Request call, and we can use this to our advantage, by using set_option to add return data in the form of key/value pairs to the options hash from our called Automation method. 

For example from the _called_ (Automate) method...

```ruby
automation_request = $evm.root['automation_task'].automation_request
automation_request.set_option(:return, JSON.generate({:status => 'success', :return => some_data}))
```

...and from the _calling_ (external) method...

```ruby
puts "Results: #{result['options']['return'].inspect}"
```

Using this technique we can write our own pseudo-API calls for CloudForms to handle anything that the standard RESTful API doesn't support. We implement the "API" using a standard Automate method, call it using the RESTful automate call, and we can pass parameters to, and retrieve result back from the called method.

#### Authentication and _auto\_approve_

When we make a RESTful call, we must authenticate using a valid username and password. This user must be an admin or equivalent however if we wish to specify _:auto\_approve => true_ in our calling arguments (only admins can auto-approve Automation requests).

If we try making a RESTful call as a non-admin user, the Automation request will be blocked pending approval (as expected). There seems to be no way however for an admin user to approve such a request through the WebUI (BZ #1229818), so currently if we want to submit an automation request as a non-admin user, we would need to write our own approval code.

### Generic run\_via\_api Script Example

The following is a generic _run\_via\_api_ script that can be used to call any Automation method, using arguments to pass server name, credentials, and URI parameters to the Instance to be called...

```
Usage: run_via_api.rb [options]
    -s, --server server              CloudForms server to connect to
    -u, --username username          Username to connect as
    -p, --password password          Password
    -d, --domain                     Domain
    -n, --namespace                  Namespace
    -c, --class                      Class
    -i, --instance                   Instance
    -P, --parameter <key,value>      Parameter (key => value pair) for the instance
    -h, --help  
```

```ruby
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
            :server => nil,
            :username => nil,
            :password => nil,
            :domain => nil,
            :namespace => nil,
            :class => nil,
            :instance => nil,
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
    opts.on('-P', '--parameter <key,value>', Array, 'Parameter (key,value pair) for the instance') do |parameters|
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
    server = "cloudforms_server"
  else
    server = options[:server]
  end
  if options[:username].nil?
    username = "rest_user"
  else
    username = options[:username]
  end
  if options[:password].nil?
    password = "secure"
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
      :auto_approve => true
    }
  }.to_json
  query = "/api/automation_requests"
  #
  # Issue the automation request
  #
  rest_return = RestClient::Request.execute(method: :post, url: url + query, :user => username, \
                :password => password, :headers => {:accept => :json}, :payload => post_params, \
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
  rest_return = RestClient::Request.execute(method: :get, url: url + query, :user => username, \
                :password => password, :headers => {:accept => :json}, verify_ssl: false)
  result = JSON.parse(rest_return)
  request_state = result['request_state']
  until request_state == "finished"
    puts "Checking completion state..."
    rest_return = RestClient::Request.execute(method: :get, url: url + query, :user => username, \
                  :password => password, :headers => {:accept => :json}, verify_ssl: false)
    result = JSON.parse(rest_return)
    request_state = result['request_state']
    sleep 3
  end
  puts "Results: #{result['options']['return'].inspect}"
rescue => err
  puts "[#{err}]\n#{err.backtrace.join("\n")}"
  exit!
end
```

Edit the default values for server, username and password if required. Run the script as...

```
./run_via_api.rb -s 192.168.1.1 -u cfadmin -p password -d ACME -n General \
-c Methods -i AddNIC2VM -P vm_id,1000000000195 -P nic_name,nic1 -P nic_network,vlan_712
```
