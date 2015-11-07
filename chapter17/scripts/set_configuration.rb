require 'rest-client'
require 'json'
require 'openssl'
require 'base64'

begin
  
  def rest_action(uri, verb, payload=nil)
    headers = {
      :content_type  => 'application/json',
      :accept        => 'application/json;version=2',
      :authorization => "Basic #{Base64.strict_encode64("#{@username}:#{@password}")}"
    }
    response = RestClient::Request.new(
      :method      => verb,
      :url         => uri,
      :headers     => headers,
      :payload     => payload,
      verify_ssl: false
    ).execute
    return JSON.parse(response.to_str)
  end
   
  servername      = $evm.object['servername']
  @username       = $evm.object['username']
  @password       = $evm.object.decrypt('password')
  
  if $evm.root['vmdb_object_type'] == 'miq_provision'
    parameter_id    = $evm.root['miq_provision'].get_option(:dialog_parameter_id)
    parameter_value = $evm.root['miq_provision'].get_option(:dialog_parameter_value)
    hostgroup_id    = $evm.root['miq_provision'].get_option(:dialog_hostgroup_id)
    hostname        = $evm.root['miq_provision'].get_option(:dialog_vm_name)
  elsif $evm.root['vmdb_object_type'] == 'service_reconfigure_task'
    parameter_id    = $evm.root['dialog_parameter_id']
    parameter_value = $evm.root['dialog_parameter_value']
    hostgroup_id    = $evm.root['dialog_hostgroup_id']
    hostname        = $evm.root['dialog_vm_name']  
  end
  #
  # Only set the smart class parameter if we've been passed a parameter value from a service dialog
  #
  unless parameter_value.nil?
    uri_base = "https://#{servername}/api/v2"
    #
    # Get the domain name for the hostgroup
    #
    rest_return = rest_action("#{uri_base}/hostgroups/#{hostgroup_id}", :get)
    domain_name = rest_return['domain_name']
    match = "fqdn=#{hostname}.#{domain_name}"
    #
    # See if the override match already exists
    #
    rest_return = rest_action("#{uri_base}/smart_class_parameters/#{parameter_id}/override_values", :get)
    override_value_id = 0
    if rest_return['total'] > 0
      rest_return['results'].each do |override_value|
        if override_value['match'] == match
          override_value_id = override_value['id']
        end
      end
    end
    if override_value_id.zero?
      payload = {
        :match => match,
        :value => parameter_value
      }
      rest_return = rest_action("#{uri_base}/smart_class_parameters/#{parameter_id}/override_values", :post, JSON.generate(payload))
    else
      payload = {
        :value => parameter_value
      }
      rest_return = rest_action("#{uri_base}/smart_class_parameters/#{parameter_id}/override_values/#{override_value_id}", :put, JSON.generate(payload))
    end
  end
  
  $evm.root['ae_result'] = 'ok'
  exit MIQ_OK
rescue RestClient::Exception => err
  $evm.log(:error, "The REST request failed with code: #{err.response.code}") unless err.response.nil?
  $evm.log(:error, "The response body was:\n#{err.response.body.inspect}") unless err.response.nil?
  $evm.root['ae_reason'] = "The REST request failed with code: #{err.response.code}" unless err.response.nil?
  $evm.root['ae_result'] = 'error'
  exit MIQ_STOP
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  $evm.root['ae_reason'] = "Unspecified error, see automation.log for backtrace"
  $evm.root['ae_result'] = 'error'
  exit MIQ_STOP
end