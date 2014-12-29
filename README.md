docker-highcharts-server
========================
----------
***Unfortunately, the build is not automated, since it can not be created by an unknown error in DockerHub. I pushed a local builded and working version to [ldaume/docker-highcharts-export][1]***
----------
# Introduction
docker-highcharts-server is a dockerized [Highcharts](http://www.highcharts.com/) export server.

## Version
Current Version: **0.0.1**

# How to use this image.
## Interactive

    docker run -it --rm -p 8888:8080 ldaume/docker-highcharts-server

## As daemon

    docker run --name highcharts-server -d -p 8888:8080 ldaume/docker-highcharts-server

## Connect
You can then go to [http://localhost:8888/highcharts-export-web][2] or [http://host-ip:8888/highcharts-export-web][3] in a browser.


  [1]: https://registry.hub.docker.com/u/ldaume/docker-highcharts-export/
  [2]: http://localhost:8888/highcharts-export-web
  [3]: http://host-ip:8888/highcharts-export-web