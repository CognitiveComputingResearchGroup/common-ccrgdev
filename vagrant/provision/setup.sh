#! /bin/bash

#########################
# Software Installation #
#########################

#################
# Preliminaries #
#################
## Added to resolve an apt-get issue that occurs when installing packages in
## non-interactive mode. The issue is documented in more detail here
## (http://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory)
sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
sudo dpkg-reconfigure debconf -f noninteractive -p critical

## Setup PPAs and Alternate download locations ##

# Java
sudo apt-add-repository -y ppa:webupd8team/java &>>/var/tmp/vagrant_prov.log

# PyCharm
sudo sh -c 'echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" > /etc/apt/sources.list.d/getdeb-apps.list'
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -

# ROS
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116 &>>/var/tmp/vagrant_prov.log


## Accepting license agreements
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

## Sync package index files
sudo echo "Syncing apt-get package index" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get update -qq -y &>>/var/tmp/vagrant_prov.log



## install git
sudo echo "Installing Git (version control)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get install -qq -y git &>>/var/tmp/vagrant_prov.log

## install xfce4 (desktop) and virtualbox add-ons
sudo echo "Installing Xfce4 (desktop environment)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get install -qq -y dictionaries-common &>>/var/tmp/vagrant_prov.log
sudo apt-get install -qq -y xfce4 &>>/var/tmp/vagrant_prov.log
sudo apt-get install -qq -y gnome-icon-theme-full tango-icon-theme &>>/var/tmp/vagrant_prov.log

## Install firefox (browser)
sudo echo "Installing Firefox (browser)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get -qq -y install firefox &>>/var/tmp/vagrant_prov.log

## Install pip (Python package manager)
sudo echo "Installing PIP (Python package manager)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get -qq -y install build-essential python-dev &>>/var/tmp/vagrant_prov.log
sudo apt-get -qq -y install python-pip &>>/var/tmp/vagrant_prov.log

## Install jupyter (Python Notebooks)
sudo echo "Installing Jupyter (Python notebooks)" | tee -a /var/tmp/vagrant_prov.log
sudo pip -q install pyzmq --install-option="--zmq=bundled" &>>/var/tmp/vagrant_prov.log
sudo pip -q install jupyter &>>/var/tmp/vagrant_prov.log

## Install Java 8
sudo echo "Installing Java8" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get install -y -qq oracle-java8-installer &>>/var/tmp/vagrant_prov.log

## Install PyCharm (Python IDE)
sudo echo "Installing PyCharm (Python IDE)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get install pycharm &>>/var/tmp/vagrant_prov.log

## Install ROS
sudo echo "Installing ROS (the robot OS)" | tee -a /var/tmp/vagrant_prov.log
sudo apt-get install -y ros-jade-desktop-full &>>/var/tmp/vagrant_prov.log

sudo rosdep init &>>/var/tmp/vagrant_prov.log
rosdep -y update &>>/var/tmp/vagrant_prov.log

sudo apt-get install -y python-rosinstall &>>/var/tmp/vagrant_prov.log

sudo apt-get install -y ros-jade-rosbridge-server &>>/var/tmp/vagrant_prov.log

#####################
# Setup environment #
#####################
sudo echo "Setting up bash environment" | tee -a /var/tmp/vagrant_prov.log
CCRG_DEV_ROOT=/home/vagrant/Development/ccrg

mkdir -p $CCRG_DEV_ROOT

cd $CCRG_DEV_ROOT
git clone https://github.com/CognitiveComputingResearchGroup/lidapy-framework.git

##################
# Update .bashrc #
##################

# setup ros environment variable
if ! grep '/opt/ros/jade/setup.bash' /home/vagrant/.bashrc > /dev/null; then

cat <<EOF >> /home/vagrant/.bashrc
source /opt/ros/jade/setup.bash
EOF

fi

# start xfce desktop on login
if ! grep 'startxfce4' /home/vagrant/.bashrc > /dev/null; then

cat <<'EOF' >> /home/vagrant/.bashrc
if [ "$(tty)" = "/dev/tty1" -o "$(tty)" = "/dev/vc/1" ] ; then
  startxfce4
fi
EOF

fi
