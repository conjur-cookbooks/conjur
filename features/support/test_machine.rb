require 'docker'

# TestMachine encapsulates test container setup and operation logic.
# To use you need to set TRUSTED_IMAGE to an identifier of a Docker
# container with preinstalled cookbook and conjur config.
class TestMachine
  def initialize
    @image = TestMachine.trusted_image
  end

  def launch
    @image.run
  end

  def configure
    @image = TestMachine.configured_image
  end

  class << self
    def configured_image
      @configured_image ||= begin
        container = Docker::Container.create \
          'Image' => run_config.id,
          'Cmd' => base_command
        container.commit.tap &container.method(:delete)
      end
    end

    def trusted_image
      @image ||= ENV['TRUSTED_IMAGE'].tap do |image|
        fail 'Please set TRUSTED_IMAGE to image name' unless image
        fail "Image #{image} doesn't exist. Have you ran `make`?" unless Docker::Image.exist? image
      end
    end

    def base_command
      @base_command ||= Docker::Image.get(trusted_image).info['Config']['Cmd']
    end

    def root_directory
      @root ||= File.expand_path '../../..', __FILE__
    end

    private

    def run_config
      container = config_container
      container.start 'Binds' => ["#{root_directory}:/var/chef/cookbooks/conjur"]
      container.attach do |stream, chunk|
        print chunk if stream == :stdout
      end
      container.commit.tap { container.delete }
    end

    def config_container
      Docker::Container.create \
        'Image' => trusted_image,
        'Cmd' => %w(/usr/bin/chef-solo -o conjur::configure),
        'Env' => %w(
          CONJUR_AUTHN_LOGIN=host/test
          CONJUR_AUTHN_API_KEY=the-secret-key
        )
    end
  end
end
