sudo apt-get update -y
sudo apt-get install git python-pip python-dev -y
vagrant_pkg_url=https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
wget ${vagrant_pkg_url}
sudo dpkg -i $(basename ${vagrant_pkg_url})
sudo apt-get install libxslt-dev libxml2-dev libvirt-dev build-essential qemu-utils qemu-kvm libvirt-bin virtinst -y
sudo service libvirt-bin restart
sudo vagrant plugin install vagrant-libvirt
sudo vagrant plugin install vagrant-mutate
precise_box_vb_url=https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box
precise_box_vb_filename=$(basename ${precise_box_vb_url})
wget ${precise_box_vb_url}
mv ${precise_box_vb_filename} precise64.box
sudo vagrant mutate precise64.box libvirt
sudo pip install ansible
git clone http://git.openstack.org/stackforge/compass-install
cd compass-install
sudo vagrant up --provision
if [[ $? != 0 ]]; then
    sudo vagrant provision compass_cobbler
    if [[ $? != 0 ]]; then
        echo "provisioning of compass failed"
        exit 1
    fi
fi



