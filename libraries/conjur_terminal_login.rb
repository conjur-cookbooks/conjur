module ConjurTerminalLogin
  def conjur_cacertfile
    conjur_require_file("Conjur server certificate (conjur-acct.pem)", [ File.expand_path(conjur_conf['cert_file'], "/etc/"), File.expand_path("~/conjur-#{conjur_account}.pem") ])
  end
  
  def conjur_authorized_keys_command_url
    [ conjur_appliance_url, "pubkeys" ].join('/')
  end
  
  def conjur_account
    ENV['CONJUR_ACCOUNT'] || conjur_conf['account']
  end
  
  def conjur_host_id
    id = [ ENV['CONJUR_AUTHN_LOGIN'], conjur_netrc[0] ].compact.first
    raise "No host identity is available" unless id
    tokens = id.split('/')
    raise "Expecting 'host' id, got #{tokens[0]}" unless tokens[0] == 'host'
    tokens[1..-1].join('/')
  end
  
  def conjur_host_api_key
    ENV['CONJUR_AUTHN_API_KEY'] || conjur_netrc[1] or raise "No host api key is available"
  end
  
  def conjur_ldap_url
    "ldaps://#{URI.parse(conjur_appliance_url).host}"
  end

  def conjur_appliance_url
    ENV['CONJUR_APPLIANCE_URL'] || conjur_conf['appliance_url']
  end

  def conjur_conf
    path = conjur_require_file("Conjur configuration (conjur.conf)", [ ENV['CONJURRC'], "/etc/conjur.conf" ])
    require 'yaml'
    return YAML.load(path)
  end
  
  protected

  def conjur_netrc
    require 'netrc'
    
    Netrc.configure do |config|
      config[:allow_permissive_netrc_file] = true
    end
    
    netrc = Netrc.read(conjur_conf['netrc_path'] || Netrc.default_path)
    netrc["#{conjur_appliance_url}/authn"] || []
  end
  
  def conjur_require_file name, paths
    paths.select do |f|
      File.file?(f)
    end.tap do |path|
      raise "No #{name} found" unless path
    end
  end
end

class Chef::Resource
  include ConjurTerminalLogin
end
