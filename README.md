# Puppet Enterprise Demo Environment

#### Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
    * [Access the Puppet Enterprise Console](#access-the-puppet-enterprise-console)
4. [Creating a New Demo](#creating-a-new-demo)
    * [Adding VMs](#adding-vms)
    * [Adding VM Roles](#adding-vm-roles)
    * [Adding Vagrant Boxes](#adding-vagrant-boxes)
    * [Modifying the PE Master](#modifying-the-pe-master)
        * [Puppetfile](#puppetfile)
    * [Using YAML ERB templates](#using-yaml-erb-templates)


## Overview

This tool provides a quick way to bootstrap an example deployment of Puppet
Enterprise, complete with a master and several managed nodes running different
operating systems. It's intended to give you an easy way to demonstrate Puppet
Enterprise, Puppet Apps, and partner integrations  on a single laptop without 
any outside infrastructure.

## Quick Start

If you are using Mac OS X, the following command will install Puppet, Virtualbox, Vagrant, and the
necessary vagrant plugins

      $ curl -L https://github.com/puppetlabs/puppetconf-partner-demo-env/pe-demo-install-script | bash

Note, you might be asked to accept the XCode EULA during the running of the
script. Just accept it and re-run the script if it quits early.

Once done, you can bring up a single master by running `vagrant up` in the
*puppetconf-partner-demo-env* directory.  It's going to take a while for the VM
to come up and be fully configured.

The above insatllation script ensures the following software is installed on your system:

* Puppet (gem if not already present)
* librarian-puppet (gem)
* Virtualbox 5.0
* Vagrant (latest)
* vagrant-oscar plugin
* vagrant-vbox-snapshot plugin

### Non-Mac host machines

You will need to install the following software:

* [Vagrant (latest)](https://www.vagrantup.com)
* [vagrant-oscar plugin](https://github.com/oscar-stack/oscar#installation)
* [Virtualbox (latest)](https://www.virtualbox.org)

Clone the https://github.com/puppetlabs/puppetconf-partner-demo-env repository.

### Access the Puppet Enterprise Console

You'll be back at the command prompt, but the puppet master is still running in
the background. Before you can get to the console, you'll need to figure out
where it is:

        $ vagrant hosts list

The response should look something like `10.20.1.1 master`, meaning that the
`master` VM has the IP address of `10.20.1.1`. Next, just point your browser to
`https://10.20.1.1` (or whatever the actual IP address is) and log in with the
username `admin`, password `puppetlabs`. Don't worry if you get
a warning about the security certificate; that really won't affect anything. 

When you log in, you may notice that there's just one node listed: `master`.
Not a bad start, but also not a great example of Puppet in action. In the next
section, you'll add some additional nodes to manage.

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

### Adding vagrant boxes

Create a new file **config/boxes.yaml** file. Inside, specify the list
of roles using a format something like this: 

        ---
        boxes:
          'rhel-70-x64-vbox': 'http://example.com/rhel-70.virtualbox.box'

Now your VM definitions can specify *rhel-70-x64-vbox* for the *box* parameter.

### Modifying the PE master

You can specify Puppet code to run on the PE master **during vagrant
provisioning**. This is useful to create node groups in the classifier, stage
files and repositories, set up packages, and more.  Note this is entirely
optional. 

In the **puppet/manifests** directory there are a list of **.pp** files.  When
Vagrant runs Puppet is run on the master during the provisioning processes, all
.pp files in your demo's manifests directory will be combined into a single
manifest.  This means every .pp file can contain raw resources without any
classes.

#### Puppetfile

If your Puppet manifests make use of modules from the Forge or github, you can
add modules to the **puppet/Puppetfile** file.
