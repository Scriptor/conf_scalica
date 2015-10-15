#!/bin/bash

echo "Did you properly set up your ssh keys yet? If not, please visit 
https://help.github.com/articles/generating-ssh-keys/ [Yn]"
read result
if ! [ "$result" == "Y" ]; then
	exit 0
fi

echo "Please enter your username for the user to be created and git"
echo -n '> '
read your_username

# echo "Please enter your email for git: "
# echo -n '> '
# read your_email

echo "Installing core package updates & build-essential & git"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential # c++ compliler etc.
sudo apt-get install git

echo 'setting timezone to America/New_York'
echo 'America/New_York' | sudo tee /etc/timezone > /dev/null

echo "creating user ${your_username} and adding him/her to admin group"
sudo adduser ${your_username}
sudo adduser ${your_username} admin

#define home
my_home=/home/${your_username}

echo "remove default info dump on ssh login"
touch ${my_home}/.hushlogin

echo "enable vi mode"
echo 'set editing-mode vi' | sudo tee ${my_home}/.inputrc > /dev/null

echo "set up ssh for ${your_username}"
sudo cp -R /home/ubuntu/.ssh ${my_home}/

echo "make .ssh/ belong to us"
sudo chown -R ${your_username}:admin ${my_home}/.ssh

echo 'copy ssh public key to authorized_keys'
cat ${my_home}/conf_scalica/id_rsa.tmp | sudo tee ${my_home}/.ssh/authorized_keys > /dev/null
sudo rm ${my_home}/conf_scalica/id_rsa.tmp

########## time to set things us! ##########
echo 'basic system setup complete, installing django etc...'

export DEBIAN_FRONTEND=noninteractive
sudo apt-get install libmysqlclient-dev -y
sudo apt-get -q -y install mysql-server
sudo apt-get install python-dev python-pip -y
sudo pip install virtualenv

virtual_envs=largescale
install_dir=${my_home}/${virtual_envs}

sudo mkdir -p ${install_dir}
sudo chown ${your_username}:${your_username} ${install_dir}

cd $install_dir
sudo virtualenv --system-site-packages .
source ./bin/activate
sudo pip install Django==1.8
sudo pip install django-debug-toolbar==1.3.2
sudo pip install MySQL-python==1.2.5

echo "get source code for scalica"
sudo git clone http://23.236.49.28/git/scalica.git scalica

echo "set up the database"
cd ${install_dir}/scalica/db
sudo ./install_db.sh
cd ${install_dir}/scalica/web/scalica
sudo python manage.py makemigrations
sudo python manage.py migrate

sudo chown -R ${your_username}:${your_username} ${install_dir}
sudo chown ${your_username}:${your_username} /tmp/db.debug.log

echo "enabling easy access to manage the server"
sudo ln -s ${install_dir}/scalica/web/scalica/manage.py ${my_home}/manage.py
sudo chown -R ${your_username}:${your_username} ${my_home}/manage.py

echo 'make issue.net readable by uncommenting: # Banner /etc/issue.net'
sudo vim /etc/ssh/sshd_config

echo 'writing banner text to issue.net from another file'
sudo cat ./banner.txt > /etc/issue.net

echo 'reloading ssh'
sudo service ssh reload

# echo "setting git global configs"
# git config --global user.name ${your_username}
# git config --global user.email ${your_email}
# git config --global --add color.ui true
# git config --global push.default simple

# git aliases
# git config --global alias.st status
# git config --global alias.co checkout
# git config --global alias.br branch
# git config --global alias.ci commit
