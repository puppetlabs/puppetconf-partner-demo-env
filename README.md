# Puppet Enterprise Demo Environment

#### Table of Contents

1. [Overview](#overview)
    * [Who can use this tool](#who-can-use-this-tool)
       * [System Requirements](#system-requirements)
2. [Quick Start](#quick-start)
    * [Mac Host Machines](#mac-host-machines)
    * [Non-Mac Host Machines](#non-mac-host-machines)
3.  [Using the Demo Environment](#using-the-demo-environment)
    * [Access the Puppet Server Command line](#access-the-puppet-server-command-line)
    * [Access the Puppet Enterprise Console](#access-the-puppet-enterprise-console)
    * [Snapshotting the Environment](#snapshotting-the-environment)
4. [Extending the Demo Environment](#extending-the-demo-environment)
    * [Adding VMs](#adding-vms)
    * [Adding VM Roles](#adding-vm-roles)
    * [Adding Vagrant Boxes](#adding-vagrant-boxes)
    * [Adding Your Own Puppet Code](#adding-your-own-puppet-code)
    * [Modifying the PE Master](#modifying-the-pe-master)
        * [Puppetfile](#puppetfile)

## Overview

This tool provides a quick way to bootstrap a local deployment of Puppet
Enterprise, complete with a Puppet Enterprise master. Multiple agents can be
added for a multitude of operating systems.  It's intended to give you an easy
way to demonstrate Puppet Enterprise and how it works with your technology.
The entire environment is self contained on your workstation without any
outside infrastructure required, though it does require access to the Internet.

### Who can use this tool

To use this tool, the operator will need to be pretty comfortable with
operating command line interfaces as well as comfortable with working with YAML
files if you want to extend this environment to include your own demo
components.

If you do intend to extend this environment with your own demo components (VMs
and roles), it's recommend that you keep the changes in version control.
Therefor, a basic understanding of git is recommended.

#### System Requirements

Any workstation that will run this environment needs the following:

* Multi-core, modern CPU
* At least 4GB of free RAM. 8GB recommended
* At least 3GB of free disk space.

## Quick Start

### Mac Host Machines

If you are using Mac OS X, the following command will install Puppet, Virtualbox, Vagrant, and the
necessary Vagrant plugins

**You may have to scroll horizontally to get the whole command**

    curl -L https://raw.githubusercontent.com/puppetlabs/puppetconf-partner-demo-env/master/scripts/install_demo_environment.sh | bash

Note, you might be asked to accept the XCode EULA during the running of the
script. Just accept it and re-run the script if it quits early.

Once done, you can bring up a single master by running `vagrant up` in the
*puppetconf-partner-demo-env* directory.  It's going to take a while for the VM
to come up and be fully configured.

The above installation script ensures the following software is installed on your system:

* Puppet (gem if not already present)
* librarian-puppet (gem)
* Virtualbox 5.0
* Vagrant
* vagrant-oscar plugin
* vagrant-vbox-snapshot plugin

### Non-Mac Host Mchines

You will need to install the latest version of the following software:

* [Vagrant](https://www.vagrantup.com)
* [vagrant-oscar plugin](https://github.com/oscar-stack/oscar#installation)
* [vagrant-snapshot plugin](https://github.com/dergachev/vagrant-vbox-snapshot#install) #optional but recommended
* [Virtualbox](https://www.virtualbox.org)
* [git](https://git-scm.com)

Clone the https://github.com/puppetlabs/puppetconf-partner-demo-env repository.

## Using the demo environment

The demo environment uses [Vagrant](https://www.vagrantup.com) to create
on-demand, fully configured virtual infrastructure. ALL Vagrant commands should
be run in the terminal of your choice in the `puppetconf-partner-demo-env`
directory created from the set up process above.

If you intend to add your own VMs to the environment, it is suggested that you
fork this repository to your own github account.

### Creating the environment

Once you have the demo environment provisioned, you'll be ready to create the
virtual machines. Go into your demo environment's directory
(puppetconf-partner-demo-env) in your terminal application and run the
following command.

        $ vagrant up

The master.vm machine will take a considerable amount of time to install the
Puppet Enterprise master.

### Access the Puppet server command line

From the puppetconf-partner-demo-env directory on your terminal application,
run the following command to SSH into the Puppet master.

        $ vagrant ssh master.vm

Once you've logged into the master, you'll need to become root for most tasks.
That can easily be done with the following command:

        $ sudo su

### Access the Puppet Enterprise Console

Before you can get to the console, you'll need to figure out what it's IP
address is with the following command run from the puppetconf-partner-demo-env
directory:

        $ vagrant hosts list

The response should look something like `10.20.1.1 master.vm master`, meaning that the
`master` VM has the IP address of `10.20.1.1`. Next, just point your browser to
`https://10.20.1.1` (or whatever the actual IP address is) and log in with the
username `admin`, password `puppetlabs`. Don't worry if you get
a warning about the security certificate; that really won't affect anything. 

When you log in, you may notice that there's just one node listed: `master`.
Not a bad start, but also not a great example of Puppet in action. In the next
section, you'll learn how to add some additional nodes to manage.

### Snapshotting the Environment

Once you finish provisioning the demo environment that will host the demos you
want to give, it is recommended you snapshot the environment so you can quickly
return to a good state after you give a demo. The `vagrant snapshot` command
will do that for you.

For each of the VMs in your demo environment, run the following command:

        $ vagrant snapshot save <vm-name> base

Restore the snapshot with

        $ vagrant snapshot restore <vm-name> base

See a list of snapshots available with

        $ vagrant snapshot list

## Extending the Demo Environment

This demo environment can be extended by

* Adding virtual machines
* Adding roles to auto-configure VMs upon creation
* Adding VM images
* Adding yor own Puppet code

### Adding VMs

Open the **config/vms.yaml** file.  Inside, specify a list of
all the VMs you'll need using a format something like this:

        ---
        vms:
          - name: "master"
            box:  "puppetlabs/centos-7.0-64-nocm"
            roles: [ "master" ]
          - name: "pe-agent1"
            box:  "puppetlabs/centos-7.0-64-nocm"
            roles: [ "agent" ]
          - name: "pe-agent2"
            box:  "puppetlabs/centos-7.0-64-nocm"
            roles: [ "agent", "example_role" ]

For a complete list of Vagrant boxes that can be used for the **box** parameter, browse Atlas' [Vagrant Cloud](https://atlas.hashicorp.com/boxes/search?utm_source=vagrantcloud.com&vagrantcloud=1)

To add a Vagrant box you've made yourself, see the [Adding vagrant boxes](#adding-vagrant-boxes) section in this README

### Adding VM roles

Open the **config/roles.yaml** file. Inside, specify the list
of roles using a format something like this: 

        ---
        roles:
          master:
            ...
          agent:
            ...
          example_role:
            provisioners:
              - type: shell
                inline: |-
                  echo 'demo'

Replace the `echo 'demo'` with any shell commands you wish to run. If you wish
to run a shell script from a file in the repository, use the path parameter
instead. e.g.

          ...
          example_role:
            provisioners:
              - type: shell
                path: scripts/my_totally_awesome_script.sh

      
### Adding vagrant boxes

Create a new file **config/boxes.yaml** file. Inside, specify the list
of boxes using the following format.

        ---
        boxes:
          'rhel-70-x64-vbox': 'http://example.com/rhel-70.virtualbox.box'

Now your VM definitions can specify *rhel-70-x64-vbox* for the *box* parameter.

### Adding your own Puppet code

If you'd like to add your own Puppet code to, for example, manage your demo
VMs, you can do so in the environments/<environment> directory. Each directory
inside the `environments` directory automatically creates a corresponding
environment on the Puppet master.  Most demos will just need to use the default
`production` environment.

Inside each environment, you'll find a few important directories. The
*manifests* directory holds the site.pp file which is the global Puppet code
that will be applied to every single Puppet run. Usually the only things that
go in here are [node definitions](https://docs.puppet.com/puppet/latest/reference/lang_node_definitions.html) and [application declarations](https://docs.puppet.com/pe/latest/app_orchestration_declare_instance.html).

The *modules* directory holds all of the Puppet modules you want available for
the classification in the Console or for use in your roles and profiles.

The *site* directory holds two important directories: *role* and *profile*.
These directories are Puppet modules for implimenting the [roles and profiles pattern](https://docs.puppet.com/pe/latest/puppet_assign_configurations.html#assigning-configuration-data-with-role-and-profile-modules)

### Modifying the PE master

You can specify Puppet code to run on the PE master **during vagrant
provisioning**. This is useful to create node groups in the classifier, stage
files and repositories, set up packages, and more. Note this is entirely
optional.

In the **puppet/manifests** directory there are a list of **.pp** files.  When
Vagrant runs Puppet is run on the master during the provisioning processes, all
.pp files in your demo's manifests directory will be combined into a single
manifest.  This means every .pp file can contain raw resources without any
classes.

#### Puppetfile

If your Puppet manifests make use of modules from the Forge or github, you can
add modules to the **puppet/Puppetfile** file.
