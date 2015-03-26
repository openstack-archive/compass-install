Vagrant.configure("2") do |config|
  config.vm.define :compass_cobbler do |test_vm|
    compass_cobbler.vm.box = "precise64"
    compass_cobbler.vm.network :private_network, :ip=>"10.1.0.11", :libvirt__dhcp_enabled=>false
    compass_cobbler.vm.provider :libvirt do  |domain|
      domain.memory = 2048
      domain.cpus =2 
      domain.nested =true
      domain.graphics_ip="0.0.0.0"
    end
    compass_cobbler.vm.provision "ansible" do |ansible|
      ansible.playbook="install/allinone_nochef.yml"
    end
  end
end
