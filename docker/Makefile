# Base image. It's used as a base for the main image so that chef incremental
# convergence can take care of applying any changes in development without
# starting from scratch. Note no dependency on the tarball.
%-base.image : NAME = conjurinc/conjur-cookbook-test-$*-base
%-base.image: %.docker
	docker build -f $< -t $(NAME) .
	docker inspect -f '{{.Id}}' $(NAME) > $@

# Make make not delete the cached image
.SECONDARY: phusion-base.image

NAME = conjurinc/conjur-cookbook-test-$*
%.image: Dockerfile %-base.image cookbooks.tar.gz conjur.conf
	cat $< | sed -e 's@<base>@$(NAME)-base@' > Dockerfile.tmp
	docker build -f Dockerfile.tmp -t $(NAME) .
	docker inspect -f '{{.Id}}' $(NAME) > $@
	rm Dockerfile.tmp
