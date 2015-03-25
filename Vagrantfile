Vagrant.configure("2") do |config|
  config.vm.define :test_vm do |test_vm|
    test_vm.vm.box = "precise64"
    test_vm.vm.network :private_network, :ip=>"10.1.0.11", :libvirt__dhcp_enabled=>false
    test_vm.vm.provider :libvirt do  |domain|
      domain.memory = 2048
      domain.cpus =2 
      domain.nested =true
      domain.graphics_ip="0.0.0.0"
    end
    test_vm.vm.provision "ansible" do |ansible|
      ansible.playbook="install/allinone_nochef.yml"
    end
  end
end
