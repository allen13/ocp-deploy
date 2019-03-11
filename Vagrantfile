# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative './vagrant/shared.rb'

Vagrant.configure("2") do |config|
  register_rhel_subscription(config)

  create_vm(
    config,
    id: 1,
    prefix: "ocp",
    cpus: 4,
    memory: 6144,
    extra_disks: 3,
    extra_disks_size: 40
  )

  create_vm(
    config,
    id: 2,
    prefix: "ocp",
    cpus: 4,
    memory: 6144,
    extra_disks: 3,
    extra_disks_size: 40
  )

  create_vm(
    config,
    id: 3,
    prefix: "ocp",
    cpus: 4,
    memory: 6144,
    extra_disks: 3,
    extra_disks_size: 40
  )
end
