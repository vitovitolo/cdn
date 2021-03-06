# CDN 

This is a simple CDN server with some basic static content cache

## Design

This vagrant box will set up a HAProxy + Varnish + Nginx + Sinatra Web Service

![alt text](https://github.com/vitovitolo/cdn/raw/develop/docs/diagram.png "Architecture")

The proxy redirect all requests to the cache except URL like /stats. This kind of requests will sent to the statistics web app. 

If the cache will miss some content, it will request to another proxy in order to balance the requests between the app servers. Another reason to setup another proxy in front of the app servers is that Varnish doesnt support SSL backends.

The cache is configured with 512m of memory limit but it is configurable.

The Stats web service is configured to parse the proxy access log to retrieve the last 24 hours requests and exec some cache shell command to show the hits and miss requests also.


HAproxy has few ports opened for different purpose

- 80/tcp HTTP: Public HTTP port redirect allways to HTTPS

- 443/tcp HTTPS: Public HTTPS port redirect to Varnish if URL is not /stats

- 8080/tcp: App Servers proxy. Balanace in roundrobin agains three SSL backends configured

- 8888/tcp: HAProxy Stats socket

Varnish has two ports opened:

- 6081/tcp: Main port to receive requests

- 6082/tcp: Admin socket

Nginx 

- 8000: Passenger + Sinatra Web App with statistics about cache and proxy


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

## Test the cache


The first time this requests it's execute, the cache server MISS the static file and get it from one backend server and save it in memory.

```
curl -s -v -k -L https://192.168.77.77/user/themes/new-cabify-web/img/logo.png -o /dev/null
* Hostname was NOT found in DNS cache
*   Trying 192.168.77.77...
* Connected to 192.168.77.77 (192.168.77.77) port 443 (#0)

# SSL stuff...

> GET /user/themes/new-cabify-web/img/logo.png HTTP/1.1
> User-Agent: curl/7.38.0
> Host: 192.168.77.77
> Accept: */*
> 
< HTTP/1.1 200 OK
* Server nginx is not blacklisted
< Server: nginx
< Date: Wed, 31 May 2017 09:09:21 GMT
< Content-Type: image/png
< Content-Length: 3934
< Last-Modified: Mon, 29 May 2017 16:11:45 GMT
< ETag: "592c4841-f5e"
< X-Varnish: 2
< Age: 0
< Via: 1.1 varnish-v4
< Accept-Ranges: bytes
< 
{ [data not shown]
```

We can check the stats to see that cache_miss counter are growing:

```
curl  -k -L https://192.168.77.77/stats

{"requests":1,"cache_miss":1,"cache_hits":0}
```
 
Then the cache will HIT the further requests
```
curl -s -v -k -L https://192.168.77.77/user/themes/new-cabify-web/img/logo.png -o /dev/null

* Hostname was NOT found in DNS cache
*   Trying 192.168.77.77...
* Connected to 192.168.77.77 (192.168.77.77) port 443 (#0)

# SSL stuff...

> GET /user/themes/new-cabify-web/img/logo.png HTTP/1.1
> User-Agent: curl/7.38.0
> Host: 192.168.77.77
> Accept: */*
> 
< HTTP/1.1 200 OK
* Server nginx is not blacklisted
< Server: nginx
< Date: Wed, 31 May 2017 09:12:38 GMT
< Content-Type: image/png
< Content-Length: 3934
< Last-Modified: Mon, 29 May 2017 09:05:02 GMT
< ETag: "592be43e-f5e"
< X-Varnish: 32770
< Age: 0
< Via: 1.1 varnish-v4
< Accept-Ranges: bytes
< 
{ [data not shown]
```

We could check the stats again and see hits growing:
```
curl -v -k -L https://192.168.77.77/stats

{"requests":3,"cache_miss":1,"cache_hits":1}
```

With a simple loop like this:
```
for i in {1..10}; do  curl -s -v -k -L https://192.168.77.77/user/themes/new-cabify-web/img/logo.png -o /dev/null ; done
```

Then the cache HITS are growing again:
``` 
curl -v -k -L https://192.168.77.77/stats

{"requests":14,"cache_miss":1,"cache_hits":11}
```

The cache is configured for excluding URLs like /api:
```
curl -v -k -L https://192.168.77.77/api/regions -o /dev/null

* Hostname was NOT found in DNS cache
*   Trying 192.168.77.77...
* Connected to 192.168.77.77 (192.168.77.77) port 443 (#0)

# SSL stuff...

> GET /api/regions HTTP/1.1
> User-Agent: curl/7.38.0
> Host: 192.168.77.77
> Accept: */*
> 
< HTTP/1.1 200 OK
* Server nginx is not blacklisted
< Server: nginx
< Date: Wed, 31 May 2017 09:18:06 GMT
< Content-Type: application/json; charset=utf-8
< Content-Length: 14012
< Status: 200 OK
< Cache-Control: max-age=3600, public
< X-Country-Code: ES
< X-Powered-By: Phusion Passenger Enterprise 5.0.29
< X-Varnish: 13
< Age: 0
< Via: 1.1 varnish-v4
< Accept-Ranges: bytes
< 
{ [data not shown]
```

Then we could not see the request in the cache but the requests counter is growing:
```
curl -v -k -L https://192.168.77.77/stats

{"requests":16,"cache_miss":1,"cache_hits":11}
```

## Test the code

This command will run a vm with vagrant, provision with ansible and test with serverspec.

At the end of the test, Test-Kitchen will destroy the vm

```
kitchen test
```

