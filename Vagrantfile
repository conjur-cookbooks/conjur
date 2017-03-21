Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"

  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = 'vendor'
    chef.add_recipe "conjur"
  end
end
