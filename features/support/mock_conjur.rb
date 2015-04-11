require 'docker'

# A Docker container meant to mock Conjur in a very limited way.
class MockConjur
  def initialize
    @container = Docker::Container.create 'Image' => MockConjur.image_id
    @container.start
    ObjectSpace.define_finalizer self, proc { @container.delete force: true }
  end

  def id
    @container.id
  end

  class << self
    def image_id
      image.id
    end

    def image
      @image ||= Docker::Image.build <<-DOCKER
        FROM conjurinc/alpine
        RUN apk update && apk add nginx
        RUN mkdir -p /tmp/nginx
        CMD nginx && tail -f /var/log/nginx/access.log
      DOCKER
    end
  end
end
