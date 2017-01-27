[![Build Status](https://travis-ci.org/gperdomor/sygnaler.svg?branch=master)](https://travis-ci.org/gperdomor/sygnaler)
[![codecov](https://codecov.io/gh/gperdomor/sygnaler/branch/master/graph/badge.svg)](https://codecov.io/gh/gperdomor/sygnaler)

# 📖 Introduction

**sygnaler** is an alternative Push Gateway for Matrix (http://matrix.org/) written in swift.

See http://matrix.org/docs/spec/client_server/r0.2.0.html#id51 for a high level overview of how notifications work in Matrix.

http://matrix.org/docs/spec/push_gateway/unstable.html#post-matrix-push-r0-notify describes the protocol that Matrix Home Servers use to send notifications to Push Gateways such as **sygnaler**

## ✅ Support
- [x] Linux and macOS
- [x] APNS authentication and certificate authentication
- [x] Push and VOIP notifications
- [x] Sandbox and production mode
- [x] Multiple apps
- [ ] Support Android Apps
- [ ] Handle errors using MySQL Database

## 🦄 Deploy

Fully deploy w/ MySQL Database included on Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## 🛠 Setup

### Pusher apps Config

To configure your apps, the first place you'll create a `pushers.json` file inside `Config/secrets/`, this file must contains the configuration of all your applications in which you want receive your notifications.

The file contains only two keys, `max_tries` as integer and `apps` as an object of **apps**.

There are two ways you can configure an app. You can either use the new authentication key APNS authentication method or the 'old'/traditional certificates method

#### 🔑 Authentication key authentication (preferred)

This is the easiest to setup authentication method. Also the token never expires so you won't have to renew the private key (unlike the certificates which expire at a certain date).

#### 🎫 Certificate authentication

If you decide to go with the more traditional authentication method, you need to convert your push certificate, using:

```
openssl pkcs12 -in Certificates.p12 -out push.crt.pem -clcerts -nokeys
openssl pkcs12 -in Certificates.p12 -out push.key.pem -nocerts -nodes
```
#### 📦 App configuration keys

| Key      | Default | Description |
|:--------:|:-------:|-------------|
| authKey  | true    | False to use certificates. True to use Apple Authentication Key |
| voip     | false   | True to send VOIP notifications |
| sandbox  | false   | Send notification using sandbox or production mode |
| certPath | -       | The path of your certificate. Relative to `Config/certs` directory. **Required if `authKey = false`** |
| keyPath  | -       | If `authKey = true`: the path of your Apple Authentication Key. If `authKey = false`: the path of your certificate key. In both cases the path should be relative to `Config/certs` directory. |
| teamId   | -       | Your team Id, look your membership info at developer.apple.com |
| keyId    | -       | The Apple Authentication Key Id, **Required if `authKey = true`** |

Here's an example `secrets/pushers.json`

```json
{
  "max_tries": 3,
  "apps": {
    "YOUR_APP_BUNDLE_ID": {
        "authKey": true,
        "voip": true,
        "teamId": "TEAM_ID",
        "keyId": "KEY_ID",
        "keyPath": "PATH/TO/AppleAuthenticationKey.p8",
        "sandbox": true
    },
    "ONE_MORE_APP_BUNDLE_ID": {
        "authKey": true,
        "teamId": "TEAM_ID",
        "keyId": "KEY_ID",
        "keyPath": "PATH/TO/AppleAuthenticationKey.p8"
    },
    "OTHER_APP_BUNDLE_ID": {
        "voip": true,
        "certPath": "PATH/TO/certificate.pem",
        "keyPath": "PATH/TO/certificate-key.pem"
    },
    "ANOTHER_APP_BUNDLE_ID": {
        "certPath": "PATH/TO/certificate.pem",
        "keyPath": "PATH/TO/certificate-key.pem"
    }
  }
}

```
### SwiftBeaver Integration

**Sygnaler** use SwiftBeaver to handle logs to console by default. You also can configure Sygnaler to use SwiftBeaver
Cloud Platform configuring your keys in `Config/secrets/app.json`

```json
{
  "sb_app_id": "MY_APP_ID",
  "sb_secret_key": "SECRET_KEY",
  "sb_encryption_key": "ENCRYPTION_KEY"
}
```
if you are in production mode you can configure using the following env vars: `$VAPOR_SB_APP_ID`, `$VAPOR_SB_SECRET_KEY` and `$VAPOR_SB_ENCRYPTION_KEY`

### Vapor CLI

The Vapor Command Line Interface makes it easy to build and run Vapor projects. Install it on Mac by running

#### Brew

```sh
brew install vapor/tap/toolbox
```

#### Curl

```sh
curl -sL toolbox.vapor.sh | bash
```

#### Building

```sh
vapor build --mysql
```

## Manual Deploy

When deploying, one may optionally include the `secrets` folder if they have a secure way of doing so. The official deploy is done through use of environment variables configured on the server that match the following scheme.

#### `mysql.json`

```
{
  "host": "$MYSQL_HOST",
  "user": "$MYSQL_USER",
  "password": "$MYSQL_PASS",
  "database": "$MYSQL_DB",
  "port": "$MYSQL_PORT",
  "encoding": "utf8"
}

// OR

{
  "url": "mysql://user:pass@host:3306/database"
}
```

## 💧 Community

Join the welcoming community of fellow Vapor developers in [slack](http://vapor.team).

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.

## 🙌 Thanks

A great deal of work on this library was originally done by @gperdomor. Thanks 🙌
