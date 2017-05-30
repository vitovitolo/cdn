# CDN 

This is a simple CDN server with some basic static content cache

## Requirements

This project was created and tested in a Debian Jessie box with:

```
$ vagrant --version
Vagrant 1.6.5

$ ansible --version
ansible 1.7.2
```

For testing purpose you will need to install Test Kitchen:

```
$ kitchen --version
Test Kitchen version 1.16.0
```

## Provision the CDN server

This will start up an Ubuntu Xenial 64bits vm box and provision it with ansible

```
vagrant up
```

## Test

This command will run a vm with vagrant, provision with ansible and test with serverspec.

At the end of the test Kitchen will destroy the vm

```
kitchen test
```

