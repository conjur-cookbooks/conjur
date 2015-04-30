#!/usr/bin/env rake

desc "Update vendor/cookbooks"
task :vendor do
  puts "Vendoring cookbooks"
  `rm -rf vendor`
  `berks update`
  `berks vendor vendor/cookbooks`
end

desc "Package cookbooks into a chef-solo tarball"
task :package => :vendor do
  `mkdir -p vendor/cookbooks/conjur`
  `cp -r metadata.rb Berksfile Berksfile.lock CHANGELOG.md chefignore README.md attributes recipes spec vendor/cookbooks/conjur`
  version=`git describe --tags --abbrev=0`.strip
  Dir.chdir 'vendor'
  tarball = "conjur-#{version}.tar.gz"
  puts "Building cookbook tarball #{tarball}"
  `tar czf ../#{tarball} cookbooks`
end
