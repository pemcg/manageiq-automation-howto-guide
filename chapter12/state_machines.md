## State Machines

One of the types of schema field is a _State_, and we can construct a Class Schema definition comprising a sequences of _States_. This then becomes a _State Machine_.

State Machines are a really useful way of performing a sequence of operations; they can ensure the successful completion of a prior step before the next step is run, permit steps to be retried, and allow us to set a timeout value on the successful completion of the State.

If we look at all of the attributes that we can add for a schema field, in addition to the familar _Name_, _Description_, and _Value_ headings, we see a number of column headings that we haven't used so far...

| Name | Description | Value | ... | On Entry | On Exit | On Error | Max Retries | Max Time |
|:----:|:-----------:|:-----:|:---:|:--------:|:-------:|:--------:|:-----------:|:--------:|

The last five columns in the schema field are specifically used when we define State Machines.

#### On Entry
We can optionally define an _On Entry_ method to be run before the "main" method (the _Value_ entry) is run. We can use this to setup or test for pre-conditions to the State, for example if the "main" method adds a tag to an object, the _On Entry_ method might check that the category and tag exist.

Note - some State Machines use _On Entry_ instead of _Value_ to specifiy the name of the "main" method of the State.

#### On Exit
We can optionally define an _On Exit_ method to be run if the "main" method (the _Value_ entry) returns ```$evm.root['ae_result'] = 'ok'```

#### On Error
We can optionally define an _On Error_ method to be run if the "main" method (the _Value_ entry) returns ```$evm.root['ae_result'] = 'error'```


#### Max Retries
We can optionally define a maximum number of retries that a State's "main" method is allowed to attempt. Defining this in the State rather than the method itself simplifies the method coding, and makes it easier to write generic methods that can be re-used in a number of State Machines.

#### Max Time
We can optionally define a maximum time (in seconds) that the State will be permitted to run for, before being terminated.

### State Variables

#### $evm.root['ae\_result']

A Method run within the context of a State Machine can return a completion status back to the Automate Engine, which can then decide which next action to perform (such as whether to advance to the next  step).

We do this by setting one of three values in the ```ae_result``` hash key...

```ruby
# Signal an error
$evm.root['ae_result'] = 'error'
$evm.root['ae_reason'] = "Failed to do something"

# Signal that the step should be retried after a time interval
$evm.root['ae_result'] = 'retry'
$evm.root['ae_retry_interval'] = '1.minute'

# Signal that the step completed successfully
$evm.root['ae_result'] = 'ok'
```

#### $evm.root['ae\_state\_retries']

We can find out whether we're in a step that's being retried by querying the ```ae_state_retries``` key

```ruby
state_retries = $evm.root['ae_state_retries'] || 0
```

#### Getting the State Machine Name

We can find the name of the State Machine that we're running in...

```ruby
state_machine = $evm.current_object.class_name
```

#### Getting the Current Step in the State Machine

We can find out which step in the State Machine we're executing in (useful if we have a generic error handling method)...

```
step = $evm.root['ae_state']
```

#### Getting the on\_entry, on\_exit, on\_error Stage Within the Current Step

```ruby
if $evm.root['ae_status_state'] == "on_entry"
  ...
```


### Saving Variables Between State Retries

When a step is retried in a State Machine, what actually happens is that the entire State Machine is re-instantiated, starting from the step to be retried. This can make life difficult if we want to store and retrieve variables between steps in a State Machine (something we frequently want to do). Fortunately there are three $evm methods that we can use to test the presence of, save, and read variables between re-instantiations of our State Machine...

```ruby
$evm.set_state_var(:server_name, "myserver")
if $evm.state_var_exist?(:server_name)
  server_name = $evm.get_state_var(:server_name)
end

```