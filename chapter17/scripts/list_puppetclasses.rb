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
  
  servername   = $evm.object['servername']
  @username    = $evm.object['username']
  @password    = $evm.object.decrypt('password')
  hostgroup_id = $evm.object['dialog_hostgroup_id']

  uri_base = "https://#{servername}/api/v2"
  
  values_hash = {}
  if hostgroup_id.nil?
    values_hash['!'] = "Select a Host Group and click 'Refresh'"
  else
    rest_return = rest_action("#{uri_base}/hostgroups/#{hostgroup_id}/puppetclasses", :get)
    if rest_return['total'] > 0
      if rest_return['total'] > 1
        values_hash['!'] = '-- select from list --'
      end
      rest_return['results'].each do |classname, classinfo|
        $evm.log(:info, "Found Puppet Class '#{classname}' with ID: #{classinfo[0]['id'].to_s}")
        $evm.log(:info, "Classname: #{classname}")
        values_hash[classinfo[0]['id'].to_s] = classname
      end
    else
      values_hash['!'] = 'No Puppet Classes are defined for this Hostgroup'
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