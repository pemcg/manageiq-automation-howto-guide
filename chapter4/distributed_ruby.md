## Distributed Ruby

The Automation Engine runs in a CloudForms _worker_ thread, and it launches an Automation Method by spawning it as a child Ruby process. We can see this from the command line using **`ps`** to check the PID of the worker processes and its children:


```
\_ /var/www/miq/vmdb/lib/workers/bin/worker.rb
|   \_ /opt/rh/rh-ruby22/root/usr/bin/ruby  <-- automation method running
```

The spawned Automation script must access the Service Model (MiqAeService*) objects that reside in the Automation Engine process, and it does this using Distributed Ruby.

Distributed Ruby (dRuby) is a distributed client-server object system for Ruby. It uses a form of Remote Method Invocation to allow a client Ruby process to call methods on a Ruby object located in another (server) Ruby process, even on another machine. The object in the remote dRuby server process is locally represented in the dRuby client by an instance of a _DRb::DRbObject_ object. In the case of an Automation script, this object is our `$evm` variable.

When the Automation Engine spawns an Automate Method it sets up the dRuby session automatically, and we access everything seamlesssly via `$evm` in our script. Behind the scenes however the dRuby libraries are shipping our calls over to the Automation Engine worker to handle the requests.

Although this is mostly transparent to us, it can occasionally produce unexpected results. Perhaps we are hoping to find some useful user-related method that we can call on our user object, which we normally access as `$evm.root['user']`. We might try to call a standard Ruby method such as `$evm.root['user'].instance_methods`, but if so we actually get a list of the instance methods for the local _DRb::DRbObject_ object, rather than the remote MiqAeServiceUser service model (not what we want).

When we get more adventurous in our scripting, we also occasionally get a _DRb::DRbUnknown_ object returned to us, indicating that our dRuby client doesn't know about the class definition for a distributed object.

### Examining CloudForms Workers

We can use `rake` to see which workers are running on a CloudForms appliance, along with their status and Process IDs:

```
vmdb
bin/rake evm:status

...
 Worker Type                                                       | Status  |
-------------------------------------------------------------------+---------+
 ManageIQ::Providers::Redhat::InfraManager::EventCatcher           | started |
 ManageIQ::Providers::Redhat::InfraManager::MetricsCollectorWorker | started |
 ManageIQ::Providers::Redhat::InfraManager::MetricsCollectorWorker | started |
 ManageIQ::Providers::Redhat::InfraManager::RefreshWorker          | started |
 MiqEmsMetricsProcessorWorker                                      | started |
 MiqEmsMetricsProcessorWorker                                      | started |
 MiqEventHandler                                                   | started |
 MiqGenericWorker                                                  | started |
 MiqGenericWorker                                                  | started |
 MiqPriorityWorker                                                 | started |
 MiqPriorityWorker                                                 | started |
 MiqReportingWorker                                                | started |
 MiqReportingWorker                                                | started |
 MiqScheduleWorker                                                 | started |
 MiqSmartProxyWorker                                               | started |
 MiqSmartProxyWorker                                               | started |
 MiqUiWorker                                                       | started |
 MiqWebServiceWorker                                               | started |
```