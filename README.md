# 📖 Introduction

**sygnaler** is an alternative Push Gateway for Matrix (http://matrix.org/) written in swift.

See http://matrix.org/docs/spec/client_server/r0.2.0.html#id51 for a high level overview of how notifications work in Matrix.

http://matrix.org/docs/spec/push_gateway/unstable.html#post-matrix-push-r0-notify describes the protocol that Matrix Home Servers use to send notifications to Push Gateways such as **sygnaler**

## 🦄 Deploy

Fully deploy w/ MySQL Database included on Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## 🛠 Setup

### MySQL Config

To build, the first place you'll want to look is the `Config/` directory. In their, you should create a `secrets` folder and a nested `mysql.json`. Here's how my `Config/` folder looks locally.

```
Config/
  - mysql.json
	secrets/
	  - mysql.json
```

The `secrets` folder is under the gitignore and shouldn't be committed.

Here's an example `secrets/mysql.json`

```json
{
  "host": "z99a0.asdf8c8cx.us-east-1.rds.amazonaws.com",
  "user": "username",
  "password": "badpassword",
  "database": "databasename",
  "port": "3306",
  "encoding": "utf8"
}
```

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
