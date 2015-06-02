##$evm and the Workspace


When we program in the CloudForms Automation Engine, we access everything through a single _$evm_ variable. This variable is actually an instance of an _MiqAeService_ object (defined in _/var/www/miq/vmdb/lib/miq\_automation\_engine/engine/miq\_ae\_service.rb_ on the appliance), which contains over forty methods. In practice we generally only use a few of these methods, most commonly:

```
$evm.root
$evm.object
$evm.current (this is equivalent to calling $evm.object(nil))
$evm.log
$evm.vmdb
$evm.execute
$evm.instantiate
```

In addition, when we work with State Machines (see section xxx) we often use ```$evm.set_state_var```, ```$evm.get_state_var``` and ```$evm.state_var_exist?``` to save variables between retries of a stage in a State Machine.


