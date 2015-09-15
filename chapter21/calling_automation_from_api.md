## Calling Automation from the RESTful API

We can call any Automation Instance from the RESTful API, but issuing a _put_ call to /api/automation_requests, and enclosing a JSON-encoded parameter hash such as the following...

```ruby
post_params = {
  :version => '1.1',
  :uri_parts => {
    :namespace => ACME/General',
    :class => 'Methods',
    :instance => 'HelloWorld'
  },
  :requester => {
    :auto_approve => true
  }
}.to_json
```

We can call Automate from an external Ruby script by using the rest-client gem...

```ruby
url = 'https://cloudforms_server'
query = '/api/automation_requests'
rest_return = RestClient::Request.execute(method: :post, url: url + query, :user => username, \
                :password => password, :headers => {:accept => :json}, :payload => post_params, \
                verify_ssl: false)
result = JSON.parse(rest_return)
```

The request ID is passed to us in the result from the initial call...

```ruby
request_id = result['results'][0]['id']
query = "/api/automation_requests/#{request_id}"
```

...and we call poll this to check on status...

```ruby
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
The _request_ task's options hash is included in the return from the RestClient::Request call, and we can use this to our advantage, by using set_option to add return data in the form of key/value pairs to the options hash from our called Automation method. 

From the _called_ (Automate) method...

```ruby
automation_request = $evm.root['automation_task'].automation_request
automation_request.set_option(:return, JSON.generate({:status => 'success', :return => some_data}))
```

From the _calling_ (external) method...

```ruby
puts "Results: #{result['options']['return'].inspect}"
```

