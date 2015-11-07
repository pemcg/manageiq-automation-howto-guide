require 'yaml'
require 'tempfile'

begin
  servername   = $evm.object['servername']
  organization = $evm.object['organization']
  
  prov = $evm.root['miq_provision']
  template = prov.source
  vm = prov.destination
  #
  # Only register if the provisioning template is linux
  #
  if template.platform == "linux"
    #
    # Pick an activation key based on the operating system being provisioned
    #
    if vm.operating_system.product_name == 'Red Hat Enterprise Linux 6 (64-bit)'
      activationkey = 'RHEL6-Generic'
    elsif vm.operating_system.product_name == 'Red Hat Enterprise Linux 7 (64-bit)'
      activationkey = 'RHEL7-Generic'
    else
      raise "Unrecognised Operating System Name"
    end
    #
    # Check that the VM is booted and has an IP address
    #
    if vm.ipaddresses.length.zero?
      $evm.log(:info, "VM doesnt have an IP address yet - retrying in 1 minute")
      $evm.root['ae_result'] = 'retry'
      $evm.root['ae_retry_interval'] = '1.minute'
      exit MIQ_OK
    end
    ip_address = vm.ipaddresses[0]
    $evm.log(:info, "IP Address is: #{ip_address}")
    #
    # add host to /etc/ansible/hosts if it doesn't already exist
    #
    unless File.foreach('/etc/ansible/hosts').grep(/#{Regexp.escape(ip_address)}/).any?
      open('/etc/ansible/hosts', 'a') do |f|
        f.puts "#{ip_address}"
        f.close
      end
    end
    #
    # Remove the hosts key if it already exists
    #
    cmd = "ssh-keygen -R #{ip_address}"
    `#{cmd}`
    #
    # Create a temporary Ansible playbook file
    #
    tempfile = Tempfile.new('ansible-')
    
    playbook = []
    this_host = {}
    this_host['hosts'] = []
    this_host['hosts'] = "#{ip_address}"
    this_host['tasks'] = []
    this_host['tasks'] << { 'name'      => 'Set hostname',
                            'hostname'  => "name=#{vm.name}"
                          }
    this_host['tasks'] << { 'name'      => 'Install Cert',
                            'command'   => "/usr/bin/yum -y localinstall http://#{servername}/pub/katello-ca-consumer-latest.noarch.rpm"
                          }
    this_host['tasks'] << { 'name'      => 'Register with Satellite',
                            'command'   => "/usr/sbin/subscription-manager register --org #{organization} --activationkey #{activationkey}",
                            'register'  => 'registered'
                          }
    this_host['tasks'] << { 'name'      => 'Enable Repositories',
                            'command'   => "subscription-manager repos --enable=rhel-*-satellite-tools-*-rpms",
                            'when'      => 'registered|success'
                          }
    this_host['tasks'] << { 'name'      => 'Install Katello Agent',
                            'yum'       => 'pkg=katello-agent state=latest',
                            'when'      => 'registered|success',
                            'notify'    => ['Enable Katello Agent', 'Start Katello Agent']
                          }
    this_host['tasks'] << { 'name'      => 'Install Puppet',
                            'yum'       => 'pkg=puppet state=latest',
                            'when'      => 'registered|success',
                            'register'  => 'puppet_installed',
                            'notify'    => ['Enable Puppet']
                          }
    this_host['tasks'] << { 'name'      => 'Configure Puppet Agent',
                            'command'   => "/usr/bin/puppet config set server #{servername} --section agent",
                            'when'      => 'puppet_installed|success'
                              }
    this_host['tasks'] << { 'name'      => 'Run Puppet Test',
                            'command'   => '/usr/bin/puppet agent --test --noop --onetime --waitforcert 60',
                            'when'      => 'puppet_installed|success'
                          }
    this_host['tasks'] << { 'name'      => 'Start Puppet',
                            'service'   => 'name=puppet state=started'
                          }                         
    this_host['tasks'] << { 'name'      => 'Update all packages',
                            'command'   => '/usr/bin/yum -y update'
                          }
    this_host['handlers'] = []
    this_host['handlers'] << { 'name'    => 'Enable Katello Agent',
                               'service' => 'name=goferd enabled=yes'
                             }
    this_host['handlers'] << { 'name'    => 'Start Katello Agent',
                               'service' => 'name=goferd state=started'
                             }
    this_host['handlers'] << { 'name'    => 'Enable Puppet',
                               'service' => 'name=puppet enabled=yes'
                             }
    playbook << this_host
    #
    # Write the contents of the playbook
    #
    tempfile.write("#{playbook.to_yaml}\n")
    tempfile.close
    cmd = "ansible-playbook -s #{tempfile.path}"
    $evm.log(:info, "Running ansible-playbook using #{tempfile.path}")
    ansible_results = `#{cmd}`
    $evm.log(:info, "Finished ansible-playbook, results: #{ansible_results}")
    tempfile.unlink
  end
  $evm.root['ae_result'] = 'ok'
  exit MIQ_OK
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Error activating host: #{err.message}"
  exit MIQ_ERROR
end
