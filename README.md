docker-highcharts-server
========================

# Introduction
docker-highcharts-server is a dockerized [Highcharts](http://www.highcharts.com/) export server.

## Version
Current Version: **0.0.1**

# How to use this image.
## Interactive
```bash
docker run -it --rm -p 8888:8080 docker-highcharts-server:latest
```

## As daemon
```bash
docker run --name highcharts-server -d -p 8888:8080 docker-highcharts-server:latest
```
You can then go to http://localhost:8888/highcharts-export-web or http://host-ip:8888/highcharts-export-web in a browser.
