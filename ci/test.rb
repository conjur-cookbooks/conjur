#!/usr/bin/env ruby

require 'methadone'

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
    alias_method :setup_step, :sh!

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

    def cleanup
      cleanup_step 'kitchen destroy -c'
      cleanup_step 'cd ci && vagrant destroy -f'
      cleanup_step "conjur host retire #{conjur_hostid}"
    end

    def clean_output
      setup_step "docker run --rm -v #{output_mount} #{conjur_image} /bin/bash -xc 'rm -rf #{src_output}/*'"
    end

    def build_ci_containers
      setup_step 'docker build -t ci-conjur-cookbook -f docker/Dockerfile .'
      
      # Take advantage of the docker layer cache to work around the fact
      # that berks package isn't idempotent.
      setup_step 'docker build -t ci-cookbook-storge -f docker/Dockerfile.cookbook .'
      setup_step "docker run -i --rm -v #{output_mount} ci-cookbook-storage bash -c 'mkdir -p #{src_output} && mv /cookbooks/conjur.tar.gz /src/output/cookbooks.tar.gz'"
    end

    def lint_cookbook
      test_step "docker run -i --rm -v #{output_mount} ci-conjur-cookbook chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out #{src_output}/rubocop.xml"

      test_step 'docker run -i --rm ci-conjur-cookbook chef exec foodcritic .'
    end

    def run_rspec
      test_step "docker run -i --rm -v #{output_mount} -v #{Dir.pwd}/spec:/src/spec ci-conjur-cookbook chef exec rspec --format RSpecJUnitFormatter --out /src/spec/report.xml spec/"
    end

    def kitchen_instances
      [options[:only] || `kitchen list -b`.split("\n")].flatten
    end

    def kitchen_tests
      conjur_hostid, conjur_addr, token = `ci/start.sh`.split(' ')
      exit_now! "ci/start.sh failed" unless $?.exitstatus == 0

      debug "conjur hostid: #{conjur_hostid} conjur addr: #{conjur_addr} token: #{token}"
      
      setup_step_stream "chef exec kitchen converge #{options[:only]}"

      test_step_stream "chef exec kitchen verify #{options[:only]}"

      kitchen_instances.each do |h|
        setup_step_stream "chef exec kitchen exec #{h} -c 'sudo /tmp/kitchen/data/conjurize.sh #{conjur_addr} #{token}'"
        host_id = `chef exec kitchen exec #{h} -c "sudo /usr/local/bin/conjur authn whoami" | grep -v 'Execute command on' | jsonfield username | sed 's;host/;;'`
        exit_now! "conjur authn whoami failed on #{h}" unless $?.exitstatus == 0
        
        login_audit = `ci/check_login.sh #{host_id}`
        File.open("ci/output/#{h}-login.log", 'w') do |log|
          log.write $?.exitstatus == 0 ? login_audit : "no ssh:login found for #{host_id}"
        end
      end
    end
  end

  main do
    
    at_exit { cleanup } unless options[:keep]
    
    clean_output
    build_ci_containers
    unless options[:'kitchen-only']
      lint_cookbook
      run_rspec
    end
    kitchen_tests
    
  end
  
  
  
  options[:keep] = false
  options[:'kitchen-only'] = false

  on '--keep', '-k', 'clean up everything when done'
  on '--only [KITCHEN INSTANCE]', '-o', 'Only run kitchen setup and tests for this instance'
  on '--kitchen-only', '-K', 'Only run test-kitchen step'

  use_log_level_option
  go!
end
