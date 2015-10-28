#
# Description: Create configured host record in Satellite 6
#

@method = 'register_satellite'

require 'rest-client'
require 'json'
require 'openssl'
require 'base64'


begin
  # ----------------------------------------------------
  
  def query_id (uri, field, content)
  
    url = URI.escape("#{@uri_base}/#{uri}?search=#{field}=\"#{content}\"")
    request = RestClient::Request.new(
      method: :get,
      url: url,
      headers: @headers,
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    )
  
    id = nil
    rest_result = request.execute
    json_parse = JSON.parse(rest_result)
  
    subtotal = json_parse['subtotal'].to_i
    if subtotal == 1
      id = json_parse['results'][0]['id'].to_s
    elsif subtotal.zero?
      $evm.log(:error, "Query to #{url} failed, no result")
      id = -1
    elsif subtotal > 1
      $evm.log(:error, "Query to #{url} returned multiple results")
      id = -1
    else
      $evm.log(:error, "Query to #{url} failed, unknown condition")
      id = -1
    end
    id
  end
  
  # ----------------------------------------------------

  servername    = $evm.object['servername']
  username      = $evm.object['username']
  password      = $evm.object.decrypt('password')
  organization  = $evm.object['organization']
  location      = $evm.object['location']
  
  prov = $evm.root['miq_provision']
  template = prov.source
  vm = prov.destination
  #
  # Only register if the provisioning template is linux
  #
  if template.platform == "linux"
    #
    # Pick a host-group based on the operating system being provisioned
    #
    if vm.operating_system.product_name == 'Red Hat Enterprise Linux 6 (64-bit)'
      hostgroup = 'Generic_RHEL6_Servers'
    elsif vm.operating_system.product_name == 'Red Hat Enterprise Linux 7 (64-bit)'
      hostgroup = 'Generic_RHEL7_Servers'
    else
      raise "Unrecognised Operating System Name"
    end
    
    @uri_base = "https://#{servername}/api/v2"
    @headers = {
      :content_type   => 'application/json',
      :accept         => 'application/json;version=2',
      :authorization  => "Basic #{Base64.strict_encode64("#{username}:#{password}")}"
    }
    #
    # Get the host-group id 
    #
    $evm.log(:info, "Getting hostgroup id for '#{hostgroup}' from Satellite")
    hostgroup_id = query_id("hostgroups", "name", hostgroup)
    raise "Cannot determine hostgroup id for '#{hostgroup}'" if hostgroup_id == -1
    $evm.log(:info, "hostgroup_id: #{hostgroup_id}")

    #
    # Get the location id 
    #
    $evm.log(:info, "Getting location id for '#{location}' from Satellite")
    location_id = query_id("locations", "name", location)
    raise "Cannot determine location id for '#{location}'" if location_id == -1
    $evm.log(:info, "location_id: #{location_id}")

    #
    # Get the organization id 
    #
    $evm.log(:info, "Getting organization id for '#{organization}' from Satellite")
    organization_id = query_id("organizations", "name", organization)
    raise "Cannot determine organization id for '#{organization}'" if organization_id == -1
    $evm.log(:info, "organization_id: #{organization_id}")
    #
    # Create the host record
    #
    hostinfo = {
      :name             => vm.name,
      :mac              => vm.mac_addresses[0],
      :hostgroup_id     => hostgroup_id,
      :location_id      => location_id,
      :organization_id  => organization_id,
      :build            => 'false'
    }
    $evm.log(:info, "Creating host record in Satellite with the following details: #{hostinfo}")
    
    uri = "#{@uri_base}/hosts"
    request = RestClient::Request.new(
      method: :post,
      url: uri,
      headers: @headers,
      verify_ssl: OpenSSL::SSL::VERIFY_NONE,
      payload: { host: hostinfo }.to_json
    )
    rest_result = request.execute
    $evm.log(:info, "return code => <#{rest_result.code}>")
  end
  vm.start
  $evm.root['ae_result'] = 'ok'
  exit MIQ_OK
rescue RestClient::Exception => err
  $evm.log(:error, "The REST request failed with code: #{err.response.code}") unless err.response.nil?
  $evm.log(:error, "The response body was:\n#{err.response.body.inspect}") unless err.response.nil?
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "The REST request failed with code: #{err.response.code}" unless err.response.nil?
  exit MIQ_STOP
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Error registering with Satellite: #{err.message}"
  exit MIQ_ERROR
end
