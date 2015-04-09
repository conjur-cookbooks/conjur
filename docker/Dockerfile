FROM <base>

ADD cookbooks.tar.gz /var/chef
RUN chef-solo -o conjur::install
ADD conjur.conf /etc/
