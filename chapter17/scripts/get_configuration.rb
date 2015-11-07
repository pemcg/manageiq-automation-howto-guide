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
  
  parameter_id    = $evm.object['dialog_parameter_id']
  hostgroup_id    = $evm.object['dialog_hostgroup_id']
  hostname        = $evm.object['dialog_vm_name']

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
  value_string = ""
  if rest_return['total'] > 0
    rest_return['results'].each do |override_value|
      if override_value['match'] == match
        value_string = override_value['value']
        break
      end
    end
  end

  list_values = {
     'required'   => false,
     'protected'  => false,
     'read_only'  => false,
     'value'      => value_string,
   }
  list_values.each { |key, value| $evm.object[key] = value }
  
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