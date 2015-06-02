## Hello, World!

Our first Automation method is very simple, we'll write an entry to the _automation.log_ file.

First we need to create an instance from our class. In the _Instances_ tab of the new _Methods_ class, select _Configuration -> Add a New Instance_.

![Screenshot](images/screenshot11.png)

We'll call the instance _HelloWorld_, and it'll run (execute) a method _hello\_world_

![Screenshot](images/screenshot12.png)

Click the Add button.

In the _Methods_ tab of the new _Methods_ class, select _Configuration -> Add a New Method_.

![Screenshot](images/screenshot13.png)

Name the method _hello\_world_, and paste the following code into the Data window:

```ruby
$evm.log(:info, "Hello, World!")
exit MIQ_OK
```

![Screenshot](images/screenshot14.png)

Click the _Validate_ button, and then the _Add_ button.

### Running the Instance

We'll run our new instance using the simulation functionality of Automation, but before that, ssh into the CloudForms appliance as _root_, and tail the automation.log file:

```
[root@cloudforms ~]# tail -f /var/www/miq/vmdb/log/automation.log
```

In the simulation we actually run an instance called _Call\_Instance_ in the _/System/Request/_ namespace of the _ManageIQ_ domain, and this calls our instance via a relationship (see section xxx) using the _namespace_, _class_ and _instance_ argument/attribute pairs that we pass to it (Also see section xxx for the six ways of entering automation).

![Screenshot](images/screenshot23.png)

From the _Automation -> Simulation_ menu, complete the details in the _Options_ sidebar as shown, then click _Submit_

![Screenshot](images/screenshot15.png)

If all went well, we should see our "Hello, World!" message appear in the automation.log file.


```
[----] I, [2015-06-02T09:39:46.876482 #2690:ee3004]  INFO -- : Following Relationship [miqaedb:/Tutorial/General/Methods/HelloWorld#create]
[----] I, [2015-06-02T09:39:46.895429 #2690:ee3004]  INFO -- : Updated namespace [General/Methods/hello_world  Tutorial/General]
[----] I, [2015-06-02T09:39:46.899028 #2690:ee3004]  INFO -- : Invoking [inline] method [Tutorial/General/Methods/hello_world] with inputs [{}]
[----] I, [2015-06-02T09:39:46.899511 #2690:ee3004]  INFO -- : <AEMethod [Tutorial/General/Methods/hello_world]> Starting
[----] I, [2015-06-02T09:39:47.214856 #2690:628bc88]  INFO -- : <AEMethod hello_world> Hello, World!
[----] I, [2015-06-02T09:39:47.224799 #2690:ee3004]  INFO -- : <AEMethod [Tutorial/General/Methods/hello_world]> Ending
[----] I, [2015-06-02T09:39:47.224860 #2690:ee3004]  INFO -- : Method exited with rc=MIQ_OK
[----] I, [2015-06-02T09:39:47.225125 #2690:ee3004]  INFO -- : Followed  Relationship [miqaedb:/Tutorial/General/Methods/HelloWorld#create]
```

