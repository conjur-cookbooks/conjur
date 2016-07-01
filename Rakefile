#!/usr/bin/env rake

desc "Update vendor/cookbooks"
task :vendor do
  puts "Vendoring cookbooks"
  sh 'rm -rf vendor'
  sh 'berks update'
  sh 'berks vendor vendor/cookbooks'
end

desc "Package cookbooks into a chef-solo tarball"
task :package => :vendor do
  `rm -rf vendor/cookbooks/conjur`
  `mkdir -p vendor/cookbooks/conjur`
  `cp -r metadata.rb Berksfile Berksfile.lock CHANGELOG.md chefignore \
    README.md attributes recipes files templates libraries \
  vendor/cookbooks/conjur`
  version=`git describe --tags --dirty`.strip
  Dir.chdir 'vendor'
  tarball = "conjur-#{version}.tar.gz"
  puts "Building cookbook tarball #{tarball}"
  `tar -cvzf ../#{tarball} cookbooks`
end
