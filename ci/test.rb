#!/usr/bin/env ruby

require 'methadone'
require 'conjur/cli'

class CookbookTest
  include Methadone::Main
  include Methadone::SH
  include Methadone::CLILogging

  class << self
    def conjur_image
      'registry.tld/conjur-appliance-cuke-master:4.6-stable'
    end
    
    def src_output
      '/src/output'
    end
    def ci_output
      "#{Dir.pwd}/ci/output"
    end

    def output_mount
      "#{ci_output}:#{src_output}"
    end

    # Actual tests should ignore exit status. If the command fails,
    # the build will be marked unstable.
    alias_method :test_step, :sh

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
    alias_method :cleanup_step, :sh!

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
      setup_step "rm -rf ci/reports; mkdir -p ci/reports"

      setup_step %Q(docker run --rm -v #{output_mount} #{conjur_image} /bin/bash -xc 'rm -rf #{src_output}/*')
    end

    def build_ci_containers
      setup_step_stream 'docker build -t ci-conjur-cookbook -f docker/Dockerfile .'
      
      # Take advantage of the docker layer cache to work around the fact
      # that berks package isn't idempotent.
      setup_step 'docker build -t ci-cookbook-storage -f docker/Dockerfile.cookbook .'
      setup_step "docker run -i --rm -v #{output_mount} ci-cookbook-storage bash -c 'mkdir -p #{src_output} && mv /cookbooks/conjur.tar.gz /src/output/cookbooks.tar.gz'"
    end

    def lint_cookbook
      test_step "docker run -i --rm -v #{output_mount} ci-conjur-cookbook chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out #{src_output}/rubocop.xml"

      test_step 'docker run -i --rm ci-conjur-cookbook chef exec foodcritic .'
    end

    def run_rspec
      test_step_stream "docker run -i --rm -v #{output_mount} -v #{Dir.pwd}/spec:/src/spec ci-conjur-cookbook chef exec rspec --format documentation --format RspecJunitFormatter --out /src/spec/report.xml spec/"
    end

    def kitchen_instances
      [options[:only] || `kitchen list -b`.split("\n")].flatten
    end

    def instance_id_url
      'http://169.254.169.254/latest/meta-data/instance-id'
    end

    def kitchen_tests
      Conjur::Config.load
      Conjur::Config.apply

      build_host = URI.parse(Conjur::Authn.host).host
      build_user, build_api_key = Conjur::Authn.get_credentials(:noask => true)

      conjur_addr, conjur_port, token, cert = 
        setup_step_stream(%Q(ci/start_conjur.sh #{build_host} #{build_user} #{build_api_key})).stdout.split(':')
      at_exit { cleanup_step "ci/stop_conjur.sh" } unless options[:keep]

      debug "conjur_addr: #{conjur_addr} token: #{token} cert: #{cert[0..10]}"
      
      kitchen_instances.each do |h|
        setup_step_stream "chef exec kitchen create #{h}"
        at_exit { cleanup_step "chef exec kitchen destroy #{h}" } unless options[:keep]

        setup_step %Q(chef exec kitchen exec #{h} -c "echo '#{conjur_addr} conjur' | sudo tee -a /etc/hosts >/dev/null")

        # This is kind of gross, but some platforms have curl, and
        # others have wget. I don't really want to take the hit of an
        # apt-get update here (which would be required to install
        # curl)
        hostid = setup_step(%Q(chef exec kitchen exec #{h} -c 'echo $( if type -P curl >/dev/null;then  curl -s #{instance_id_url}; else wget -O - -q #{instance_id_url}; fi)' | grep -v 'Execute command on')).strip

        api_key = setup_step(%Q(ci/create_host.sh #{h} #{token} #{hostid})).strip

        env = "env CONJUR_APPLIANCE_URL=https://conjur:#{conjur_port}/api CONJUR_SSL_CERTIFICATE='#{cert}' CONJUR_AUTHN_LOGIN='host/#{hostid}' CONJUR_AUTHN_API_KEY='#{api_key}'"
        setup_step_stream "chef exec #{env} kitchen converge #{h}"

        test_step_stream "chef exec kitchen verify #{h}"

        login_audit = nil 
        exitstatus = test_step "ci/check_login.sh #{hostid}" do |out|
          login_audit = out     # don't strip this one, we're just writing to the results
        end
        File.open("ci/reports/#{h}-login.xml", 'w') do |log|
          log.write exitstatus == 0 ? login_audit : "no ssh:login found for #{hostid}"
        end
      end
    end
  end

  main do
    clean_output
    build_ci_containers
    lint_cookbook
    run_rspec
    kitchen_tests if options[:'kitchen']
    
  end
  
  
  
  options[:keep] = false
  options[:'kitchen'] = true

  on '--keep', '-k', 'clean up everything when done'
  on '--[no-]kitchen', '-K', 'Only run test-kitchen step'
  on '--only [KITCHEN INSTANCE]', '-o', 'Only run kitchen setup and tests for this instance'

  use_log_level_option
  go!
end
