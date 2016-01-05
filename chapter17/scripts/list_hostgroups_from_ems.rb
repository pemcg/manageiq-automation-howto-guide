begin
  
  values_hash = {}
  hostgroups = $evm.vmdb(:configuration_profile).all
  
  if hostgroups.length > 0
    if hostgroups.length > 1
      values_hash['!'] = '-- select from list --'
    end
    hostgroups.each do |hostgroup|
      $evm.log(:info, "Found Host Group '#{hostgroup.name}' with ID: #{hostgroup.manager_ref}")
      values_hash[hostgroup.manager_ref] = hostgroup.name
    end
  else
    values_hash['!'] = 'No hostgroups are available'
  end

  list_values = {
    'sort_by'   => :description,
    'data_type' => :string,
    'required'  => true,
    'values'    => values_hash
  }
  list_values.each { |key, value| $evm.object[key] = value }
  exit MIQ_OK
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end




