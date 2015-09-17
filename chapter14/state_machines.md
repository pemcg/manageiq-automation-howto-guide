## State Machines

One of the types of schema field is a _State_, and we can construct a Class Schema definition comprising a sequences of _States_. This then becomes a _State Machine_.

State Machines are a really useful way of performing a sequence of operations; they can ensure the successful completion of a prior step before the next step is run, permit steps to be retried, and allow us to set a timeout value on the successful completion of the State.

If we look at all of the attributes that we can add for a schema field, in addition to the familar _Name_, _Description_, and _Value_ headings, we see a number of column headings that we haven't used so far...


![screenshot](images/screenshot2.png)

### Columns
The schema columns for a State Machine are the same as in any other class schema, but we use more of them.

#### Value (Instance)/Default Value (Schema)
As in any other class schema, this is a _relationship_ to an _instance_ to be run to perform the main processing of the State/Stage. Surprising as it may seem, we don't necessarily need a value specified here for a State Machine (see _On Entry_ below).

#### On Entry
We can optionally define an **On Entry** _method_ to be run before the "main" method (the _Value_ entry) is run. We can use this to setup or test for pre-conditions to the State, for example if the "main" method adds a tag to an object, the _On Entry_ method might check that the category and tag exist.

The method name can be a relative path (i.e. just the method name), or namespace/class/method syntax.

Note - some State Machines use an **On Entry** _method_ instead of a **Value** _relationship_ to perform the main work of the State. This is useful when we wish to create self-contained State Machines with the State Machine instance and its associated methods all in one class.

#### On Exit
We can optionally define an **On Exit** _method_ to be run if the "main" method (the _Value_ relationship/instance or _On Entry_ method) returns ```$evm.root['ae_result'] = 'ok'```

#### On Error
We can optionally define an **On Error** _method_ to be run if the "main" method (the _Value_ relationship/instance or _On Entry_ method) returns ```$evm.root['ae_result'] = 'error'```


#### Max Retries
We can optionally define a maximum number of retries that the Stage/State is allowed to attempt. Defining this in the State rather than the method itself simplifies the method coding, and makes it easier to write generic methods that can be re-used in a number of State Machines.

#### Max Time
We can optionally define a maximum time (in seconds) that the State will be permitted to run for, before being terminated.

#### Example
We can look at the out-of-the-box _/Infrastructure/VM/Provisoning/StateMachines/ProvisionRequestApproval/Default_ State Machine Instance as an example, and see that it defines an attribute _max\_vms_, and has just two Stages/States; _ValidateRequest_ and _ApproveRequest_. 

There is no _Value_ relationship specified for either State/Stage; each of these States runs a locally defined method (in the same _/Infrastructure/VM/Provisoning/StateMachines/ProvisionRequestApproval/_ class) to perform the state-related processing.

The greyed-out values for _on\_entry_ and _on\_error_ are defaults defined in the Class schema rather than the Instance.
<br> <br>

![screenshot](images/screenshot1.png)

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

We can find out whether we're in a step that's being retried by querying the ```ae_state_retries``` key...

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
