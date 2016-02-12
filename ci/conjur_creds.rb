#!/opt/conjur/embedded/bin/ruby

require 'conjur/cli'

Conjur::Config.load
Conjur::Config.apply

host = URI.parse(Conjur::Authn.host).host
login, api_key = Conjur::Authn.get_credentials(:noask => true)
puts JSON.dump(:host => host, :login => login, :api_key => api_key)



