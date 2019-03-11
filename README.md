## ocp-deploy

Deploy and maintain an openshift-ansible based cluster. Use vagrant and virtualbox for easy testing and development of the cluster.

### Run these commands to get the enviornment running

Initialize the 3 VMs (ocp-01, ocp-02, and ocp-03)

	vagrant up

Register RHEL

Run on each VM `vagrant ssh <VMName>`  
Enter RedHat credentials when requested

	sudo -i
	subscription-manager register
	subscription-manager attach --pool=8a85f98c61b28d040161c607665e099b 

Deploy openshift and start developing! This may require changing the permissions on the ocp-folder to 775 so that docker can access it as a volume.

    bin/run -i inventories/dev playbooks/ocp-deploy.yml

Login to the cluster master node as root and run oc commands

    vagrant ssh ocp-01
	sudo -i
	oc get nodes

Access the openshift web interface:

    https://192.0.2.101:8443
	login: admin
	password: admin

When you are done developing for the day you can suspend your vms if you want to save resources but don't want to go through a full deploy:

    vagrant suspend

Then resume the vms when your ready to develop again

    vagrant resume

Or destroy everything and start from scratch the next time:

** *Important*  **  
You need to unregister each RHEL instance before destroying the VM  
Run on each VM `vagrant ssh <VMName>`  

	sudo -i
	subscription-manager unregister

Then we can destroy the VMs fromt he host machine

    vagrant destroy -f

While developing on a local laptop vms will quickly lose time synchronization when offline. It makes a lot of things weird and completely breaks merics and events.

    chronyc -a 'burst 4/4'
	sleep 10
	chronyc -a makestep

## Playbook Style/Design Guide

#### Notes

Any playbook that imports the openshift-ansible playbook should have the ocp- extension.

#### Directory Layout

 - **bin/{environment}**
	 - all  interactions with the cluster should be kept here
 - **inventories/{environment}**
	 - group_vars
		 - group.yml
			 - all configs for the cluster should be found here in their respective group file
	 - host_vars
		 - host.yml
			 - any config values that are specific to a certain host. Putting configuration here indicates a snowflake server problem. Think twice before putting configs here.
	 - cluster_inventory_file
		 - Inventory files should only contain basic connection/ip information and groups.
- **playbooks**
    - openshift-ansible
	    - this folder should be a git checkout or a symlink to the openshift-ansible project. It has been ignored so that nothing here gets commited and can be unique to each environment.
        -  playbook.yml
	    - All playbook files can be stored in this directory. If a need arises to organize the playbooks they can be placed in sub-folders.
        - ocp-playbook.yml
            - Any playbook that includes a playbook from openshift-ansible should prepend ocp
    
    - roles
	    - myrole
		    - standard location for ansible roles

- **vagrant**
	- place to store vagrant related files
- **Vagrantfile**
	- basic vagrant config
