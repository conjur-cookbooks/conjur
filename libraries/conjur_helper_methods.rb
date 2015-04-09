module LogshipperHelperMethods
  def logshipper_fifo_path
    '/var/run/logshipper'
  end
end

module ConjurClientVersion
  def conjur_client_version node
    node.conjur.client.version
  end
end

module ConjurHelperMethods
  include ConjurClientVersion
  
  def conjur_cacertfile
    conjur_require_file("Conjur server certificate (conjur-acct.pem)", [ File.expand_path(conjur_conf['cert_file'], File.dirname(conjur_conf_filename)), File.expand_path("~/conjur-#{conjur_account}.pem") ])
  rescue
    nil
  end
  
  def conjur_authorized_keys_command_url
    [ conjur_appliance_url, "pubkeys" ].join('/')
  end
  
  def conjur_account
    ENV['CONJUR_ACCOUNT'] || conjur_conf['account'] or raise "Conjur account is not available"
  end
  
  def conjur_host_id node = nil
    id = [ ENV['CONJUR_AUTHN_LOGIN'], (node ? (node.conjur['identity']||{}) : {})['login'], conjur_netrc[0] ].compact.first
    raise "No host identity is available" unless id
    tokens = id.split('/')
    raise "Expecting 'host' id, got #{tokens[0]}" unless tokens[0] == 'host'
    tokens[1..-1].join('/')
  end
  
  def conjur_host_api_key node = nil
    ENV['CONJUR_AUTHN_API_KEY'] || (node ? (node.conjur['identity']||{}) : {})['password'] || conjur_netrc[1] or raise "No host api key is available"
  end
  
  def conjur_ldap_url
    "ldaps://#{URI.parse(conjur_appliance_url).host}"
  end

  def conjur_appliance_url
    ENV['CONJUR_APPLIANCE_URL'] || conjur_conf['appliance_url']
  end
  
  def conjur_conf_filename
    conjur_require_file("Conjur configuration (conjur.conf)", [ ENV['CONJURRC'], "/etc/conjur.conf" ])
  end

  def conjur_conf
    require 'yaml'
    YAML.load(File.read(conjur_conf_filename))
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
    paths.compact.select do |f|
      File.file?(f)
    end.first.tap do |path|
      raise "No #{name} found" unless path
    end
  end
end

class Chef::Resource
  include ConjurHelperMethods
  include LogshipperHelperMethods
end

class Chef::Recipe
  include LogshipperHelperMethods
  include ConjurClientVersion
end
