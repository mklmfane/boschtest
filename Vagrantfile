# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# -*- mode: ruby -*-
# vi: set ft=ruby :

# https://github.com/dotless-de/vagrant-vbguest/issues/367

if defined?(VagrantVbguest)
  class MyWorkaroundInstallerUntilPR373IsMerged < VagrantVbguest::Installers::
    protected
    
    def has_rel_repo?
      unless instance_variable_defined?(:@has_rel_repo)
        rel = release_version
        @has_rel_repo = communicate.test(centos_8? ? 'yum repolist' : "yum repolist --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates")
      end
      @has_rel_repo
    end

    def centos_8?
      release_version && release_version.to_s.start_with?('8')
    end

    def install_kernel_devel(opts=nil, &block)
      if centos_8?
        communicate.sudo('yum update -y kernel', opts, &block)
        communicate.sudo('yum install -y kernel-devel', opts, &block)
        communicate.sudo('shutdown -r now', opts, &block)

        begin
          sleep 10
        end until @vm.communicate.ready?
      else
        rel = has_rel_repo? ? release_version : '*'
        cmd = "yum install -y kernel-devel-`uname -r` --enablerepo=C#{rel}-base --enablerepo=C#{rel}-updates"
        communicate.sudo(cmd, opts, &block)
      end
    end
  end
end

module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") { Cap::ChangeHostName }
      guest_capability("linux", "configure_networks") { Cap::ConfigureNetworks }
    end
  end
end



Vagrant.configure("2") do |config|


  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  if defined?(MyWorkaroundInstallerUntilPR373IsMerged)
        config.vbguest.installer = MyWorkaroundInstallerUntilPR373IsMerged
  end
      
      # Monkey patch for https://github.com/dotless-de/vagrant-vbguest/issues/367
  class Foo < VagrantVbguest::Installers::CentOS
        def has_rel_repo?
          unless instance_variable_defined?(:@has_rel_repo)
          rel = release_version
          @has_rel_repo = communicate.test("yum repolist")
        end
        @has_rel_repo
  end

  def install_kernel_devel(opts=nil, &block)
        cmd = "yum update kernel -y"
        communicate.sudo(cmd, opts, &block)

        cmd = "yum install -y kernel-devel"
        communicate.sudo(cmd, opts, &block)

        cmd = "shutdown -r now"
        communicate.sudo(cmd, opts, &block)

        begin
          sleep 5
        end until @vm.communicate.ready?
       end
  end
  config.vbguest.installer = Foo

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end


  config.ssh.insert_key = false 
  config.vm.box = "centos/8"
  
  config.vm.define "tower" do |tower|
    config.vm.hostname = "tower.local"
      tower.vm.box = "ansible/tower"
      tower.vm.network :private_network, ip: "192.168.56.2"
      tower.vm.provider :virtualbox do |v|
        v.gui = false
        v.memory = 2048
        v.cpus = 2
    end
  end
  
  
  config.vm.define "app_box", primary: true do |app| 
    config.vm.hostname = "app.local"
      app.vm.network :private_network, ip: "192.168.56.11"
      app.vm.provider :virtualbox do |v|
         v.gui = false
         v.memory = 512  
    end
  end
  
  config.vm.define "jenkins_box" do |jenkins|
    config.vm.hostname = "jenkins.local"
      jenkins.vm.network :private_network, ip: "192.168.56.3"
      jenkins.vm.provider :virtualbox do |v|
        v.gui = false
        v.memory = 2048
    end
  end
  


  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.


  config.vm.provision "shell", inline: <<-EOC
mkdir -p /home/vagrant/.ssh
cp ./vagrant.pub /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh  
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd.service  
  EOC


  
  
# Update all machines using a script
  config.vm.provision "shell", keep_color: true, inline: <<-SHELL 
sudo yum install -y gcc gcc-c++ make
sudo yum update -y && sudo yum upgrade -y
  SHELL
  

  config.vm.define "jenkins" do |subconfigure|
    subconfigure.vm.box = BOX_IMAGE
    subconfigure.vm.hostname = "jenkins"
    subconfigure.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.107"
    subconfigure.vm.network "forwarded_port", guest:8080, host:8080
    
    subconfigure.vm.provider "virtualbox" do |vpm|
  	vpm.memory = 3600
  	vpm.cpus = 2
    end
    
    subconfigure.vm.provision "shell", keep_color: true, inline: <<-SHELL 
sudo yum install -y wget git
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
sudo yum install -y jenkins java-1.8.0-openjdk-devel
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl stop jenkins
sudo systemctl start jenkins
    SHELL
  end    

  

  config.vm.define "master" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "master"
    subconfigure.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.115"  
    subconfig.vm.network "forwarded_port", guest:80, host:8082  
         
           
    subconfig.vm.provision "shell", inline: <<-SHELL       
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y epel-release
sudo yum install -y docker-ce
sudo yum install -y ansible
sudo systemctl enable --now docker
sudo systemctl restart docker
sudo usermod -aG docker $USER
sudo yum install -y traceroute

######Work on this#############
cat <<- EOF  >>/etc/ansible/hosts 
[loadbalancer]
10.0.0.10 ansible_user=vagrant ansible_ssh_pass=vagrant
[webserver]
10.0.0.1[1:2] ansible_user=vagrant ansible_ssh_pass=vagrant
EOF
##################################

    SHELL
    
    
    subconfig.vm.provision :docker_compose,
       yml: [
      	    "/vagrant/docker-compose.yml",
            ],
       rebuild: true,     
       run: "always"
  end




  ################ VBox #############################
  # let's use vbox
  # TODO: let's refactor and build a function for god's sake

    
  config.vm.define "sonar_box" do |sonar|
    config.vm.hostname = "sonar.local"
    sonar.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.125"
    sonar.vm.provider :virtualbox do |v|
        v.gui = false
        v.memory = 3000
    end
 end

  config.vm.define "nexus_box", primary: true do |nexus|
    config.vm.hostname = "nexus.local"
    nexus.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.126"
    nexus.vm.provider :virtualbox do |v|
        v.gui = false
        v.memory = 1024   
    end
  end

  config.vm.define "app_box", primary: true do |app|
      config.vm.hostname = "app.local"
      app.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.125"
      app.vm.provider :virtualbox do |v|
        v.gui = false
        v.memory = 512  
      end
  end

  config.vm.define "app2_box", primary: true do |app2|
      config.vm.hostname = "app2.local"
      app2.vm.network "public_network", bridge: 'wlo1', ip: "192.168.0.135"
      app2.vm.provider :virtualbox do |v|
         v.gui = false
         v.memory = 512
      end
  end
 
  ################ LIB VIRT #########################



  config.vm.define "sonar" do |sonar|
      config.vm.hostname = "sonar.local"
      sonar.vm.network :private_network, ip: "10.0.0.20"
      sonar.vm.provider :libvirt do |lb|
          lb.memory = 2048
      end
  end

  config.vm.define "nexus", primary: true do |nexus|
      config.vm.hostname = "nexus.local"
      nexus.vm.network :public_network, ip: "192.168.0.145"
      nexus.vm.provider :libvirt do |lb|
        lb.memory = 1024
      end
  end

  config.vm.define "app", primary: true do |app|
    config.vm.hostname = "app.local"
    app.vm.network :public_network, ip: "192.168.0.147"
    app.vm.provider :libvirt do |lb|
        lb.memory = 512
    end
  end

  config.vm.define "app2", primary: true do |app2|
    config.vm.hostname = "app2.local"
    app2.vm.network :private_network, ip: "192.168.0.150"
    app2.vm.provider :libvirt do |lb|
        lb.memory = 512
    end
  end

  config.vm.provider "libvirt" do |libvirt|
      libvirt.storage_pool_name = "ext_storage"
  end

  

  if Vagrant.has_plugin?("vagrant-hostmanager")
      config.hostmanager.enabled = true
      config.hostmanager.manage_host = true
      config.hostmanager.manage_guest = true
  end
end
