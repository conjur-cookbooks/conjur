require 'conjur/cli'

# A Docker container meant to mock Conjur in a very limited way.
class MockConjur
  def initialize
    #@container = Docker::Container.create 'Image' => MockConjur.image_id
    #@container.start 'Binds' => ["#{MockConjur.server_script}:/server"]
    #ObjectSpace.define_finalizer self, proc { @container.delete force: true }
  end

=begin
  def id
    @container.id
  end
=end

  def audits
    sleep 20
    Conjur::Config.load
    Conjur::Config.apply
    api = Conjur::Authn.connect nil, :noask => true
    api.audit_resource("cucumber:host:#{ENV['HOST_RESOURCE']}").select { |e| e["action"] == 'login' }
    # split it into lines, then parse each one separately
    # (@container.exec(['cat', '/audits']).first.first || '').lines.map &JSON.method(:parse)
  end

=begin
  class << self
    def image_id
      image.id
    end

    def image
      @image ||= Docker::Image.build <<-DOCKER
        FROM conjurinc/alpine
        RUN apk update && apk add ruby
        CMD /server
      DOCKER
    end

    def server_script
      File.expand_path '../mock_conjur_server.rb', __FILE__
    end
  end
=end

end
