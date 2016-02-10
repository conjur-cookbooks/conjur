#!/usr/bin/env ruby

require 'methadone'
require 'json'
require 'active_support/core_ext/hash'

class CookbookTest
  include Methadone::Main
  include Methadone::SH
  include Methadone::CLILogging

  class << self
    def conjur_image
      'registry.tld/conjur-appliance-cuke-master:4.6-stable'
    end
    
    # Actual tests should ignore exit status. If the command fails,
    # the build will be marked unstable.
    def test_step cmd
      sh cmd
    end

    # If a setup step fails, the build should fail.
    def setup_step cmd
      ret = nil
      sh! cmd do |out|
        ret = out
      end
      ret
    end

    # If a cleanup step fails, the build should fail (so we'll know
    # cleanup needs to happen manually).
    def cleanup_step cmd
      sh! cmd
    end

    # Run a shell command, streaming output to STDERR. 120 minute default timeout.
    # 
    # +options+:
    # * Anything from https://github.com/chef/mixlib-shellout/blob/master/lib/mixlib/shellout.rb
    # * nofail: don't fail on error at all
    def sh_stream! command, options = {}
      nofail = options.delete(:nofail)
      options[:timeout] ||= 60 * 120
      options[:live_stdout] ||= STDERR
      options[:live_stderr] ||= STDERR
      debug "streaming output from #{command}"
      require 'mixlib/shellout'
      Mixlib::ShellOut.new(command, options).tap do |shell|
        shell.run_command
        shell.error! unless nofail
      end
    end

    def test_step_stream command, options = {}
      sh_stream! command, options.merge(:nofail => true)
    end

    def setup_step_stream command, options = {}
      sh_stream! command, options.merge(:nofail => false)
    end

    def clean_output
      setup_step %Q(/bin/rm -rf ci/reports/*)
    end

    def source_dirs
      ['attributes', 'recipes', 'files', 'templates', 'libraries']
    end

    def lint_cookbook
      source = source_dirs.join(' ')
      test_step "rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out ci/reports/rubocop.xml #{source}"

      test_step "foodcritic ."
    end

    def run_rspec
      test_step_stream "rspec --format documentation --format RspecJunitFormatter --out ci/reports/specs.xml spec/"
    end

    def kitchen_instances
      [options[:only] || `kitchen  list -b`.split("\n")].flatten
    end

    def instance_id_url
      'http://169.254.169.254/latest/meta-data/instance-id'
    end

    def kitchen_tests
      debug "options[:'conjur-creds']: #{options[:'conjur-creds']}"
      creds = JSON.parse(options[:'conjur-creds']).with_indifferent_access
      debug "creds: #{creds}"

      conjur_addr, token, cert = 
        setup_step_stream(%Q(ci/start_conjur.sh #{creds[:host]} #{creds[:login]} #{creds[:api_key]})).stdout.split(':')
      at_exit { cleanup_step "ci/stop_conjur.sh" } unless options[:keep]

      debug "conjur_addr: #{conjur_addr} token: #{token} cert: #{cert[0..10]}"
      
      kitchen_instances.each do |h|
        setup_step_stream "kitchen  create #{h}"
        at_exit { cleanup_step "kitchen destroy #{h}" } unless options[:keep]

        setup_step %Q(kitchen exec #{h} -c "echo '#{conjur_addr} conjur' | sudo tee -a /etc/hosts >/dev/null")

        # This is kind of gross, but some platforms have curl, and
        # others have wget. I don't really want to take the hit of an
        # apt-get update here (which would be required to install
        # curl)
        hostid = setup_step(%Q(kitchen exec #{h} -c 'echo $( if type -P curl >/dev/null;then  curl -s #{instance_id_url}; else wget -O - -q #{instance_id_url}; fi)' | grep -v 'Execute command on')).strip

        api_key = setup_step(%Q(ci/create_host.sh #{h} #{token} #{hostid})).strip

        env = "env CONJUR_APPLIANCE_URL=https://conjur/api CONJUR_SSL_CERTIFICATE='#{cert}' CONJUR_AUTHN_LOGIN='host/#{hostid}' CONJUR_AUTHN_API_KEY='#{api_key}'"
        setup_step_stream "#{env} kitchen  converge #{h}"

        # There doesn't seem to be a way to redirect busser's output
        # to a file, so grab the Junit part of the results from the
        # output
        results = test_step_stream("kitchen  verify #{h}").stdout[%r{(<\?xml version="1.0".*</testsuite>)}m,1]
        File.open("ci/reports/TEST-#{h}.xml", 'w') { |log| log.puts results }

      end
    end
  end

  main do
    clean_output
    lint_cookbook
    run_rspec
    kitchen_tests if options[:'kitchen']
    
  end
  
  
  
  options[:keep] = false
  options[:'kitchen'] = true
  options[:'conjur-creds'] = {}

  on '--conjur-creds [CREDS]', '-c', 'Conjur credentials'
  on '--keep', '-k', 'clean up everything when done'
  on '--[no-]kitchen', '-K', 'Only run test-kitchen step'
  on '--only [KITCHEN INSTANCE]', '-o', 'Only run kitchen setup and tests for this instance'

  use_log_level_option
  go!
end
