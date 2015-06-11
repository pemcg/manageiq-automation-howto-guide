## Argument Passing and Handling




```ruby
update_provision_status(status => 'pre1',status_state => 'on_entry')

 # Get status from input field status
 status = $evm.inputs['status']

 # Get status_state ['on_entry', 'on_exit', 'on_error'] from input field
 status_state = $evm.inputs['status_state']
```