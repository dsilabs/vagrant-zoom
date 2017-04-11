#!/bin/bash

# crypto headers
sudo apt-get -y install build-essential libssl-dev libffi-dev python-dev

# setup python pip (python package manager)
# TODO: add a virtualenv to this setup (maybe even one for zoom and one for testsuite)
sudo apt-get -y install python3-pip

sudo pip3 install --upgrade pip
sudo pip3 install nose
sudo pip3 install fake-factory

# setup MariaDB (database engine)
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mariadb.mirror.colo-serv.net/repo/10.1/ubuntu xenial main'
sudo apt-get update
echo mariadb-server-10.1 mysql-server/root_password password root | sudo debconf-set-selections
echo mariadb-server-10.1 mysql-server/root_password_again password root | sudo debconf-set-selections
sudo apt-get -y -q install mariadb-server

# Install Locales (was needed for testsuite)
sudo apt-get -y install language-pack-en-base
echo "127.0.0.1 database" | sudo tee -a /etc/hosts

# create basic filesystem structure
sudo mkdir /work
sudo chmod -R 775 /work
sudo chown -R root:dev /work
sudo chmod g+rws /work

mkdir -p /work/source/{libs,themes,apps}
mkdir -p /work/stage/{libs,themes,apps}
mkdir /work/{data,jobs,lib,log,systems}

# setup zoom (DSI python web framework)
git clone https://github.com/dsilabs/zoom.git /work/source/libs/zoom
sudo pip3 install -r /work/source/libs/zoom/requirements.txt

ln -s /work/source/libs/zoom/zoom /work/lib/zoom
echo "/work/lib" | sudo tee /usr/local/lib/python3.5/dist-packages/dsi.pth

mkdir -p /work/web/{apps,sites,themes,www}
mkdir /work/web/sites/default
mkdir -p /work/web/sites/localhost/apps
mkdir -p /work/web/sites/localhost/data/buckets
mkdir /work/web/www/static

ln -s /work/source/libs/zoom/web/apps/* /work/web/apps/
ln -s /work/source/libs/zoom/web/www/static/* /work/web/www/static/
ln -s /work/source/libs/zoom/web/themes/* /work/web/themes/

cp /work/source/libs/zoom/web/sites/default/site.ini /work/web/sites/default/site.ini
ln -s /work/web/sites/localhost/ /work/web/sites/172.28.128.250

# setup the zoom site configuration including database credential
echo -n "CREATE USER dz@localhost IDENTIFIED BY 'root2';" | mysql -uroot -proot
echo -n "GRANT CREATE, DROP, ALTER, DELETE, INDEX, INSERT, SELECT, UPDATE, CREATE TEMPORARY TABLES, TRIGGER, CREATE VIEW, SHOW VIEW, ALTER ROUTINE, CREATE ROUTINE, EXECUTE, LOCK TABLES ON zoomdata.* TO dz@localhost;" | mysql -uroot -proot
sed -i'' 's|^dbname=|dbname=zoomdata|' /work/web/sites/default/site.ini
sed -i'' 's|^dbuser=|dbuser=dz|' /work/web/sites/default/site.ini
sed -i'' 's|^dbpass=|dbpass=root2|' /work/web/sites/default/site.ini

echo "create database if not exists zoomdata" | mysql -uroot -proot
echo "create database if not exists zoomtest" | mysql -uroot -proot
mysql -uroot -proot zoomdata < /work/source/libs/zoom/tools/zoom/sql/setup_mysql.sql
mysql -uroot -proot zoomtest < /work/source/libs/zoom/tools/zoom/sql/setup_mysql.sql
