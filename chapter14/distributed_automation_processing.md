## Distributed Automation Processing

The Automate functionality of CloudForms/ManageIQ has been designed to be scalable, by supporting distributed worker appliances that each run the **Automation Engine** role. 

### Non-Distributed Automation Operations
Not all Automation operations need to have a distributed capability. Some Automation operations interact with a user through the WebUI, and these require an Instance/Method to be run directly on the WebUI node that the user is logged-in to. Such operations include:

- Running an Automation Instance from simulation
- Automation Instances that are run to populate dynamic dialog elements

Some other Automation operations need to be executed synchronously and in a specific order, and these are also run on a single appliance to guarantee execution order. An example of this is running a Control Policy _Synchronous_ Action type of **Invoke a Custom Automation**.

The **Automation Engine** role does not need to be enabled for these non-distributed Automation operations to run.

### Distributed Automation Operations

Most Automation operations benefit from being scalable and distributed, and capable of running on any appliance in our zone with the **Automation Engine** role set. These include:

- Running an Automation Instance from a custom button
- A Control Policy _Asynchronous_ Action type of **Invoke a Custom Automation**
- Any Automation operations that involve separated Requests and Tasks (See [Requests and Tasks](../chapter14/requests_and_tasks.md))

Distributed Automation tasks are passed to the Automation Engine using the standard message passing mechanism by which all workers communicate. This is via a queue, modelled in the database as the **miq\_queue** table. Generic Workers running on appliances with the **Automation Engine** role set, monitor this queue for messages with a **queue_name** field of _generic_ and a **role** field of _automate_. If such a message is found, it is dequeued and processed.

### Tracing Queueing/Dequeueing Operations

We can examine `evm.log` to see the inter-worker message queueing/dequeueing activity when a custom button is clicked that launches an Automation task (here the lines have been wrapped for clarity). The first activity that we see is the ResourceAction message (button activities are run as _Resource Actions_):

```
MIQ(ResourceAction#deliver_to_automate_from_dialog) \
        Queuing <ResourceAction:1000000000066> for <CustomButton:1000000000001>
```

This is immediately followed by the insertion of a new message (#1000000158789) into the queue, containing the task details. The _Role: [automate]_ parameter signifies that the message is intended for the Automation Engine.

```
MIQ(MiqQueue.put) Message id: [1000000158789], \
        id: [], \
        Zone: [default], \
        Role: [automate], \
        Server: [], \
        Ident: [generic], \
        Target id: [], \
        Instance id: [], \
        Task id: [resource_action_1000000000066], \
        Command: [MiqAeEngine.deliver], \
        Timeout: [3600], \
        Priority: [20], \
        State: [ready], \
        Deliver On: [], \
        Data: [], \
        Args: [{:namespace=>"SYSTEM", \
                :class_name=>"PROCESS", \
                :instance_name=>"Request", \
                :automate_message=>nil, \
                :attrs=>{"class"=>"methods", \
                         "instance"=>"objectwalker", \
                         "namespace"=>"stuff", \
                         "request"=>"call_instance", \
                         "dialog_walk_association_whitelist"=>""}, \
                :object_type=>"VmOrTemplate", \
                :object_id=>1000000000024, \
                :user_id=>1000000000001, \
                :miq_group_id=>1000000000002, \
                :tenant_id=>1000000000001}] \
```

The next log line that mentions `Message id: [1000000158789]` shows it being dequeued by an MiqPriorityWorker thread:


```
MIQ(MiqPriorityWorker::Runner#get_message_via_drb) Message id: [1000000158789], \
        MiqWorker id: [1000000000504], \
        Zone: [default], \
        Role: [automate], \
        Server: [], \
        Ident: [generic], \
        Target id: [], \
        Instance id: [], \
        Task id: [resource_action_1000000000066], \
        Command: [MiqAeEngine.deliver], \
        Timeout: [3600], Priority: [20], \
        State: [dequeue], \
        Deliver On: [], \
        Data: [], Args: [{:namespace=>"SYSTEM", \
                          :class_name=>"PROCESS", \
                          :instance_name=>"Request", \
                          :automate_message=>nil, \
                          :attrs=>{"class"=>"methods", \
                                   "instance"=>"objectwalker", \
                                   "namespace"=>"stuff", \
                                   "request"=>"call_instance", \
                                   "dialog_walk_association_whitelist"=>""}, \
                          :object_type=>"VmOrTemplate", \
                          :object_id=>1000000000024, \
                          :user_id=>1000000000001, \
                          :miq_group_id=>1000000000002, \
                          :tenant_id=>1000000000001}], Dequeued in: [3.494673879] seconds
```

From here we see the message payload being delivered to the Automation Engine. Notice that in the log file the task action is now prefixed by **Q-task_id**, followed by the Task id in the message:

```
Q-task_id([resource_action_1000000000066]) MIQ(MiqQueue#deliver) Message id: [1000000158789], Delivering...
Q-task_id([resource_action_1000000000066]) MIQ(MiqAeEngine.deliver) Delivering \
		{"class"=>"methods", \
		"instance"=>"objectwalker", \
		"namespace"=>"stuff", \
		"request"=>"call_instance", \
		"dialog_walk_association_whitelist"=>""}  \
		for object [VmOrTemplate.1000000000024] with state [] to Automate 
```

We see the string **Q-task_id** many times in `evm.log`. This is an indication that the log line was generated by a task that was created as a result of a dequeued message, and that the message contained a valid Task id. 

Finally the target Instance itself is run by the Automation Engine:

```
Q-task_id([resource_action_1000000000066]) <AutomationEngine> Instantiating [/SYSTEM/PROCESS/Request? \
        MiqServer%3A%3Amiq_server=1000000000001& \
        User%3A%3Auser=1000000000001& \
        VmOrTemplate%3A%3Avm=1000000000024& \
        class=methods& \
        dialog_walk_association_whitelist=& \
        instance=objectwalker& \
        namespace=stuff& \
        object_name=Request& \
        request=call_instance& \
        vmdb_object_type=vm]
```
### Detailed Queue Analysis

At any time, the **miq_queue** table in the PostgreSQL database contains several messages:

```
 vmdb_production=# select id,priority,method_name,state,queue_name,class_name,zone,
 vmdb_production=# role,msg_timeout from miq_queue;
      id       | priority |     method_name      |  state  |      queue_name       |                   class_name                    |  zone   |         role          | msg_timeout
---------------+----------+----------------------+---------+-----------------------+-------------------------------------------------+---------+-----------------------+-------------
 1000000160709 |      100 | create_request_tasks | dequeue | generic               | AutomationRequest                               | default | automate              |        3600
 1000000160668 |      100 | perf_rollup          | ready   | ems_metrics_processor | ManageIQ::Providers::Redhat::InfraManager::Host | default | ems_metrics_processor |        1800
 1000000160710 |       20 | deliver              | ready   | generic               | MiqAeEngine                                     | default | automate              |        3600
 1000000160673 |      100 | perf_rollup          | ready   | ems_metrics_processor | EmsCluster                                      | default | ems_metrics_processor |        1800
 1000000126295 |      100 | refresh              | ready   | ems_1000000000004     | EmsRefresh                                      | default | ems_inventory         |        7200
 1000000160711 |       20 | deliver              | ready   | generic               | MiqAeEngine                                     | default | automate              |        3600
 1000000153572 |      100 | perf_rollup          | ready   | ems_metrics_processor | Storage                                         | default | ems_metrics_processor |        1800
 1000000154220 |      100 | perf_rollup          | ready   | ems_metrics_processor | MiqRegion                                       | default | ems_metrics_processor |        1800
...
```
Each worker type queries the **miq_queue** table to see if there is any work to be done for its respective role. The workers search for messages with a specific **queue\_name** field; for Automation-related messages this is `generic`.

When work is claimed by a worker, the message status is changed from “ready” to “dequeue” and the worker starts processing the message. 

#### Monitoring the Queue During an Automation Operation

We can monitor the **miq\_queue** table during an Automation operation initiated from a RESTful call. The following SQL query enables us to see the relevant messages:

```
vmdb_production=# select id,priority,method_name,state,queue_name,
vmdb_production-# class_name,zone,role,msg_timeout from miq_queue where
vmdb_production-# class_name like '%Automation%' or class_name like '%MiqAe%';
```
Searching for specific **class_name** fields in this way enables us to also see automate_event messages, which aren't handled by the Automation Engine, but are still relevant to an Automation operation.

We see several messages created and dispatched over a short time period:

```
      id       | priority |     method_name      | state | queue_name |    class_name     |  zone   |   role   | msg_timeout
---------------+----------+----------------------+-------+------------+-------------------+---------+----------+-------------
 1000000161068 |      100 | call_automate_event  | ready | generic    | AutomationRequest | default |          |        3600
 1000000161069 |      100 | call_automate_event  | ready | generic    | AutomationRequest | default |          |        3600
 1000000161070 |      100 | create_request_tasks | ready | generic    | AutomationRequest | default | automate |        3600
(3 rows)
```
```

      id       | priority |     method_name      |  state  | queue_name |    class_name     |  zone   |   role   | msg_timeout
---------------+----------+----------------------+---------+------------+-------------------+---------+----------+-------------
 1000000161071 |       20 | deliver              | ready   | generic    | MiqAeEngine       | default | automate |        3600
 1000000161070 |      100 | create_request_tasks | ready   | generic    | AutomationRequest | default | automate |        3600
 1000000161069 |      100 | call_automate_event  | dequeue | generic    | AutomationRequest | default |          |        3600
(3 rows)
```
```

      id       | priority |     method_name      |  state  | queue_name |    class_name     |  zone   |   role   | msg_timeout
---------------+----------+----------------------+---------+------------+-------------------+---------+----------+-------------
 1000000161071 |       20 | deliver              | ready   | generic    | MiqAeEngine       | default | automate |        3600
 1000000161072 |       20 | deliver              | ready   | generic    | MiqAeEngine       | default | automate |        3600
 1000000161070 |      100 | create_request_tasks | dequeue | generic    | AutomationRequest | default | automate |        3600
(3 rows)
```
```

      id       | priority | method_name | state | queue_name |   class_name   |  zone   |   role   | msg_timeout
---------------+----------+-------------+-------+------------+----------------+---------+----------+-------------
 1000000161071 |       20 | deliver     | ready | generic    | MiqAeEngine    | default | automate |        3600
 1000000161072 |       20 | deliver     | ready | generic    | MiqAeEngine    | default | automate |        3600
 1000000161073 |      100 | execute     | ready | generic    | AutomationTask | default | automate |         600
(3 rows)
```
```

      id       | priority | method_name |  state  | queue_name |   class_name   |  zone   |   role   | msg_timeout
---------------+----------+-------------+---------+------------+----------------+---------+----------+-------------
 1000000161071 |       20 | deliver     | dequeue | generic    | MiqAeEngine    | default | automate |        3600
 1000000161073 |      100 | execute     | dequeue | generic    | AutomationTask | default | automate |         600
(2 rows)
```
```

      id       | priority | method_name |  state  | queue_name |   class_name   |  zone   |   role   | msg_timeout
---------------+----------+-------------+---------+------------+----------------+---------+----------+-------------
 1000000161073 |      100 | execute     | dequeue | generic    | AutomationTask | default | automate |         600
(1 row)
```
```

 id | priority | method_name | state | queue_name | class_name | zone | role | msg_timeout
----+----------+-------------+-------+------------+------------+------+------+-------------
(0 rows)
```

We can search for any of these message IDs in `evm.log` and expand them to examine the message content. For example searching for Message id: 1000000161070 reveals:

```
MIQ(MiqQueue.put) Message id: [1000000161070], \
        id: [], \
        Zone: [default], \
        Role: [automate], \
        Server: [], \
        Ident: [generic], \
        Target id: [], \
        Instance id: [1000000000016], \
        Task id: [automation_request_1000000000016], \
        Command: [AutomationRequest.create_request_tasks], \
        Timeout: [3600], \
        Priority: [100], \
        State: [ready], \
        Deliver On: [], \
        Data: [], \
        Args: []
```
```
MIQ(MiqGenericWorker::Runner#get_message_via_drb) Message id: [1000000161070], \
        MiqWorker id: [1000000000503], \
        Zone: [default], \
        Role: [automate], \
        Server: [], \
        Ident: [generic], \
        Target id: [], \
        Instance id: [1000000000016], \
        Task id: [automation_request_1000000000016], \
        Command: [AutomationRequest.create_request_tasks], \
        Timeout: [3600], \
        Priority: [100], \
        State: [dequeue], \
        Deliver On: [], \
        Data: [], \
        Args: [], \
        Dequeued in: [5.622553094] seconds
```
```
Q-task_id([automation_request_1000000000016]) MIQ(MiqQueue#deliver) \
Message id: [1000000161070], Delivering...
```
```
Q-task_id([automation_request_1000000000016]) MIQ(MiqQueue#delivered) \
Message id: [1000000161070], State: [ok], Delivered in [1.866825831] seconds
```

This corresponds to the message queueing activity generated by the `.execute` method in `vmdb/app/models/miq_request.rb`

```ruby
  def execute
    task_check_on_execute

    deliver_on = nil
    if get_option(:schedule_type) == "schedule"
      deliver_on = get_option(:schedule_time).utc rescue nil
    end

    # self.create_request_tasks
    MiqQueue.put(
      :class_name  => self.class.name,
      :instance_id => id,
      :method_name => "create_request_tasks",
      :zone        => options.fetch(:miq_zone, my_zone),
      :role        => my_role,
      :task_id     => "#{self.class.name.underscore}_#{id}",
      :msg_timeout => 3600,
      :deliver_on  => deliver_on
    )
  end
```

If we search the sources for `MiqQueue.put` we see the extent to which the distributed nature of CloudForms/ManageIQ is used.

### Troubleshooting

As (by design) queued Automation operations can be dequeued and run by any appliance in a zone with the **Automation Engine** role set, we cannot necessarily predict which appliance will run our code. This can make troubleshooting `$evm.log` output more challenging, as we may need to search `automation.log` on several appliances to find our Method's log output. When tracing message passing, the enqueue `MiqQueue.put` and corresponding dequeue `Worker::Runner#get_message_via_drb` calls might even be on different appliances as well.

If Automate tasks are not being run in a distributed CloudForms/ManageIQ installation, it is often worth examining the contents of the **miq_queue** table to see whether Automate messages are accumulating, and which zone the messages are targetted for (the **Zone: []** field). If messages are not being dequeued as expected, then check that the **Automation Engine** role is set on at least one appliance in the zone.

This is often seen when separating appliances into various role-specific zones, such as a **WebUI** zone and a **Worker Appliance** zone. Automation calls made using the RESTful API to an appliance in the **WebUI** zone will fail to run if the **Automation Engine** role is not enabled on any of the **WebUI** zone appliances, or the RESTful call does not specify an alternative zone to run in.

