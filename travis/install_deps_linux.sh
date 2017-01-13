#!/usr/bin/env bash

echo "Installing Deps";

# Determine OS
UNAME=`uname`;
if [[ $UNAME == "Linux" ]];
then
    UBUNTU_RELEASE=`lsb_release -a 2>/dev/null`;
    if [[ $UBUNTU_RELEASE == *"15.10"* ]];
    then
        OS="ubuntu1510";
    else
        OS="ubuntu1404";
    fi
else
    echo "🚫  Unsupported OS: $UNAME, skipping...";
    exit 0;
fi

echo "🖥  Operating System: $OS";

echo "⚙️  Updating APT Sources";
sudo apt-get -qq update;

echo "⚙️  Installing mysql";
sudo apt-get install -y mysql-server libmysqlclient-dev;
sudo mysql_install_db;

echo "⚙️  Installing curl build deps";
sudo apt-get -y -qq build-dep curl;

echo "⚙️  Installing nghttp2 build deps";
sudo apt-get -y -qq install git g++ make binutils autoconf automake autotools-dev \
     libtool pkg-config zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libev-dev \
     libevent-dev libjansson-dev libjemalloc-dev cython python3-dev python-setuptools;

echo "⚙️  Installing nghttp2";
cd ~;
git clone --quiet https://github.com/nghttp2/nghttp2.git;
cd nghttp2;
git submodule update --init;
autoreconf -i;
automake;
autoconf;
./configure;
make;
sudo make install;

echo "⚙️  Installing curl";
cd ~;
wget -q http://curl.haxx.se/download/curl-7.52.1.tar.bz2;
tar -xjf curl-7.52.1.tar.bz2;
cd curl-7.52.1;
./configure --with-nghttp2=/usr/local --with-ssl;
make;
sudo make install;
sudo ldconfig;
sudo ln -fs /usr/local/bin/curl /usr/bin/curl;

echo "⚙️  curl --version";
curl --version;

echo "✅  Done";
