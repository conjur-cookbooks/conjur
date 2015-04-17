# Base image. It's used as a base for the main image so that chef incremental
# convergence can take care of applying any changes in development without
# starting from scratch. Note no dependency on the tarball.
%-base.image : NAME = conjurinc/conjur-cookbook-test-$*-base
%-base.image: %.docker
	docker build -f $< -t $(NAME) .
	docker inspect -f '{{.Id}}' $(NAME) > $@

# Make make not delete the cached image
.SECONDARY: phusion-base.image trusty-base.image

NAME = conjurinc/conjur-cookbook-test-$*
TEMP_DOCKER_FILE = Dockerfile.$*
%.image: Dockerfile %-base.image cookbooks.tar.gz conjur.conf
	cat $< | sed -e 's@<base>@$(NAME)-base@' > $(TEMP_DOCKER_FILE)
	docker build -f $(TEMP_DOCKER_FILE) -t $(NAME) .
	docker inspect -f '{{.Id}}' $(NAME) > $@
	rm $(TEMP_DOCKER_FILE)
