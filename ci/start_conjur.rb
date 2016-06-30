#!/usr/bin/env ruby

require 'methadone'
require 'json'
require 'active_support/core_ext/hash'

class StartConjur
  include Methadone::Main
  include Methadone::SH
  include Methadone::CLILogging

  class << self
    
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

    # If a setup step fails, the build should fail. Wrap the call to
    # #sh! to make it easier to grab command's stdout.
    def setup_step cmd
      ret = nil
      sh! cmd do |out|
        ret = out
      end
      ret
    end

    def setup_step_stream command, options = {}
      sh_stream! command, options.merge(:nofail => false)
    end

    def start_conjur
      debug "options[:'conjur-creds']: #{options[:'conjur-creds']}"
      creds = JSON.parse(options[:'conjur-creds']).with_indifferent_access
      debug "creds: #{creds}"

      external_addr, internal_addr, token = 
        setup_step_stream(%Q(ci/start_conjur.sh #{creds[:host]} #{creds[:login]} #{creds[:api_key]})).stdout.split(':')

      puts "#{external_addr} #{internal_addr} #{token}"
    end
  end

  main do
    start_conjur
  end

  options[:'conjur-creds'] = {}

  on '--conjur-creds [CREDS]', '-c', 'Conjur credentials to use to access the Conjur Docker registry'

  use_log_level_option
  go!
end
