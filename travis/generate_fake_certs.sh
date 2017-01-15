#!/usr/bin/env bash

echo "🐦 Generating Fake Certs";

touch $TRAVIS_BUILD_DIR/Config/certs/cert.pem
touch $TRAVIS_BUILD_DIR/Config/certs/key.pem
mkdir -p $TRAVIS_BUILD_DIR/Config/secrets
echo "{\"apps\":{\"dummy.app\":{\"certPath\":\"cert.pem\",\"keyPath\":\"key.pem\"}}}" > $TRAVIS_BUILD_DIR/Config/secrets/pushers.json

echo "✅  Done";
