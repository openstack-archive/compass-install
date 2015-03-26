Vagrant.configure("2") do |config|
  config.vm.define :compass_vm do |compass_vm|
    compass_vm.vm.box = "precise64"
    compass_vm.vm.network :private_network, :ip=>"10.1.0.11", :libvirt__dhcp_enabled=>false
    compass_vm.vm.provider :libvirt do  |domain|
      domain.memory = 2048
      domain.cpus =2 
      domain.nested =true
      domain.graphics_ip="0.0.0.0"
    end
    compass_vm.vm.provision "ansible" do |ansible|
      ansible.playbook="install/allinone_nochef.yml"
    end
  end
  config.vm.define :regtest_vm do |regtest_vm|
    regtest_vm.vm.box = "centos65"
    regtest_vm.vm.network :private_network, :ip=>"10.1.0.253", :libvirt__dhcp_enabled=>false
    regtest_vm.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 2
      domain.nested = true
      domain.graphics_ip="0.0.0.0"
    end
    regtest_vm.vm.provision "ansible" do |ansible|
      ansible.playbook="install/regtest.yml"
    end
  end
end
