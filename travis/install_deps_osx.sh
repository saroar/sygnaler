#!/usr/bin/env bash

echo "Installing Deps";

# Determine OS
UNAME=`uname`;
if [[ $UNAME == "Darwin" ]];
then
    OS="macos";
else
    echo "🚫  Unsupported OS: $UNAME, skipping...";
    exit 0;
fi

echo "🖥  Operating System: $OS";

echo "⚙️  Updating Homebrew";
brew update;

echo "⚙️  Installing mysql";
brew install mysql;
brew link mysql;
mysql.server start;

echo "⚙️  Installing curl";
brew reinstall curl --with-openssl --with-nghttp2;
brew link curl --force;

echo "✅  Done";
