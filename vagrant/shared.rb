DEFAULT_VM_BOX = ENV['DEFAULT_VM_BOX'] || 'generic/rhel7'

module SubscriptionManagerMonkeyPatches
  def self.subscription_manager_registered?(machine)
    true if machine.communicate.sudo("/usr/sbin/subscription-manager list --consumed --pool-only | grep -E '^[a-f0-9]{32}$'")
  rescue
    false
  end
end

VagrantPlugins::Registration::Plugin.guest_capability 'redhat', 'subscription_manager_registered?' do
  SubscriptionManagerMonkeyPatches
end

def register_rhel_subscription(config)
  if Vagrant.has_plugin?('vagrant-registration') && ENV.has_key?('RHEL_USER')
    config.registration.username = ENV['RHEL_USER']
    config.registration.password = ENV['RHEL_PASS']

    # add subscription pool: Red Hat OpenShift Container Platform, Premium (One Year, Enterprise Program)
    config.registration.pools = ['8a85f98c61b28d040161c607665e099b']
  end
end

def create_vm(config, options = {})
  prefix = options.fetch(:prefix, "node")
  id = options.fetch(:id, 1)
  extra_disks = options.fetch(:extra_disks, 0)
  extra_disks_size = options.fetch(:extra_disks_size, 0)
  vm_box = options.fetch(:vm_box, DEFAULT_VM_BOX)
  sync = options.fetch(:sync, false)
  vm_name = "%s-%02d" % [prefix, id]

  memory = options.fetch(:memory, 1024)
  cpus = options.fetch(:cpus, 1)

  config.vm.synced_folder '.', '/vagrant', disabled: !sync
  config.vm.define vm_name do |node|
    node.vm.box_download_insecure = true
    node.vm.box = vm_box
    node.vm.hostname = vm_name

    private_ip = "192.0.2.10#{id}"
    node.vm.network :private_network, ip: private_ip, netmask: "255.255.255.128"

    node.vm.provider :virtualbox do |vb|
      vb.memory = memory
      vb.cpus = cpus
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      vb.check_guest_additions = false
      vb.functional_vboxsf = false
      add_extra_disks(vm_name, vb, extra_disks, extra_disks_size) if extra_disks > 0
    end

  end
end

def add_extra_disks(vm_name, vb, extra_disks, extra_disks_size)
  dirname = File.dirname(__FILE__)

  # vb.customize ['storagectl', :id, '--name', 'CustomSATA', '--add', 'sata', '--portcount', extra_disks]
  if extra_disks > 3
    extra_disks = 3
  end

  for i in 1..(extra_disks) do
    disk_path = "#{dirname}/#{vm_name}-disk-#{i}.vdi"
    unless File.exist?(disk_path)
      vb.customize [
        'createhd',
        '--filename', disk_path,
        '--size', extra_disks_size * 1024
      ]
    end

   if i < 2
     port = 0
     device = i
   else
     port = 1
     device = i - 2
   end

    storage_controller = 'IDE Controller'

    vb.customize [
      'storageattach', :id,
      '--storagectl', storage_controller,
      '--port', port,
      '--device', device,
      '--type', 'hdd',
      '--medium', disk_path
    ]
  end
end
