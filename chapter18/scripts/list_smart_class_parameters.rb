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
  hostgroup_id    = $evm.object['dialog_hostgroup_id']
  puppet_class_id = $evm.object['dialog_puppet_class_id']

  uri_base = "https://#{servername}/api/v2"
  
  values_hash = {}
  if puppet_class_id.nil?
    values_hash['!'] = "Select a Puppet Class and click 'Refresh'"
  else
    call_string = "#{uri_base}/hostgroups/#{hostgroup_id}/smart_class_parameters"
    rest_return = rest_action(call_string, :get)
    rest_return['results'].each do |parameter|
      $evm.log(:info, "Found smart class parameter '#{parameter['parameter']}' with ID: #{parameter['id'].to_s}")
      #
      # Retrieve the details of this smart class parameter
      # to find out which puppet class it's associated with
      #
      call_string = "#{uri_base}/hostgroups/#{hostgroup_id}/smart_class_parameters/#{parameter['id']}"
      parameter_details = rest_action(call_string, :get)
      if parameter_details['puppetclass']['id'].to_s == puppet_class_id
        $evm.log(:info, "Parameter #{parameter['id'].to_s} matches the requested Puppet Class")
        values_hash[parameter['id'].to_s] = parameter_details['parameter']
      end
    end
    if values_hash.length > 0
      if values_hash.length > 1
        values_hash['!'] = '-- select from list --'
      end
    else
      values_hash['!'] = 'This Puppet class has no Smart Class Parameters'
    end
  end

  list_values = {
    'sort_by'   => :description,
    'data_type' => :string,
    'required'  => true,
    'values'    => values_hash
  }
  list_values.each { |key, value| $evm.object[key] = value }
  exit MIQ_OK
rescue RestClient::Exception => err
  $evm.log(:error, "The REST request failed with code: #{err.response.code}") unless err.response.nil?
  $evm.log(:error, "The response body was:\n#{err.response.body.inspect}") unless err.response.nil?
  exit MIQ_STOP
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end