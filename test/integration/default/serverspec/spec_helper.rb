require 'serverspec'
require 'rspec_junit_formatter'

RSpec.configure do |config|
  config.add_formatter RspecJunitFormatter
end

set :backend, :exec

set :path, '/usr/local/bin:$PATH' # make sure we can find the cli
