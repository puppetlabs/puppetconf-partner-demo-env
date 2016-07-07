demo_pwd="`pwd`/puppetconf-partner-demo-env"
cwd=`pwd`
username=`whoami`

if ! [ `uname -s` == "Darwin" ]; then
  echo "This install script only works on Mac OS X"
  exit 1
fi

# Clone the demo environment repository
[ -d $demo_pwd ] || git clone https://github.com/puppetlabs/puppetconf-partner-demo-env.git $demo_pwd || \
  (echo "git is not installed. Follow the XCode instructions that appeared on your screen to install git and then re-run the installer command." && exit 2)

# Make sure we have sudo permissions
echo "Type in your local password (What you use to log into you Mac):"
sudo echo 'Installing system requirements......'

# Install the Puppet gem if Puppet's not already installed
which puppet || sudo gem install puppet --no-rdoc --no-ri

# Install librarian-puppet gem if it's not already installed
which librarian-puppet || sudo gem install librarian-puppet --no-rdoc --no-ri

# Pull the required Puppet modules to set up the demo environment
cd $demo_pwd/scripts
librarian-puppet install
cd $cwd

# Run Puppet to set up the demo environment requirements
# See demo_requirements.pp to see what manifests are being applied
sudo FACTER_username=$username puppet apply --detailed-exitcodes --modulepath $demo_pwd/scripts/modules $demo_pwd/scripts/demo_requirements.pp

if [ $? == 1 ]; then
  echo "Puppet failed to set up the demo environment."
  echo "Try rerunning the installer command."
  echo "Please contact carl@puppet.com for help."
  exit 3
fi

cat <<End-of-message
-------------------------------------
The demo environment should now be operational.
If you have questions or run into problems, please
contact Carl Caum <carl@puppet.com>

A directory named puppetconf-partner-demo-env has been created
for you. Go into that directory 
with `cd puppetconf-partner-demo-env`,then you can use the 
following commands to operate the environment.

To spin up the demo environment VMs, run
  $ vagrant up

To get IP addresses to connect to the demo hosts, run
  $ vagrant hosts list

To destroy the demo environemnt VMs, run
  $ vagrant destroy
or
  $ vagrant destroy -f #destroy all without asking
-------------------------------------
End-of-message
