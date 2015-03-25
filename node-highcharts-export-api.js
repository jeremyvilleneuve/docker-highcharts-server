var filename = '';

var Hapi = require('hapi');
var http = require('http');

// Create a server with a host and port
var server = new Hapi.Server();
server.connection({
    host: '0.0.0.0',
    port: 8081
});

// Add the route
server.route({
    method: 'POST',
    path:'/save_chart',
    handler: function (request, reply) {

        // parse all of the data in the body of the request
        var data = JSON.stringify(request.payload.data);

        console.log("***** Received data from API: " +  data);

        // configure the connection details for the highcharts phantomjs server
        var options = {
                host: '127.0.0.1',
                port: '3003',
                path: '/',
                method: 'POST',
                headers: {
                        'Content-Type': 'application/json; charset=utf-8',
                        'Content-Length': data.length
                }
        };

        // post the highcharts JSON to the phantomjs highcharts server
        var req = http.request(options, function(res) {
                console.log("***** Starting request to phantomjs server....");
                var msg = '';

                res.setEncoding('utf8');
                res.on('data', function(chunk) {
                        console.log("***** Getting data chunk back from phantomjs....");
                        msg += chunk;
                });
                res.on('end', function() {
                        // console.log("***** Reply from phantomjs: " + msg);
                        console.log("***** Reply from phantomjs: " + msg.substr(1,20)) + "{{output trimmed}}";

                        // build the filename that will store the file
                        var timestamp_milliseconds = new Date().getTime();

                        // append random number to end of the filename
                        filename = timestamp_milliseconds + "_" + Math.floor(Math.random() * (99999 - 1)) + 1;
                        filename = filename + ".png";

                        // convert the base64 string to binary
                        var b64string = msg;
                        var buf = new Buffer(b64string, 'base64');

                        // write the binary data to a png file on the server
                        console.log("***** Attempting to write file.....");
                        var fs = require('fs');
                        fs.writeFile("/opt/chartimages/" + filename, buf, function(err) {
                                if(err) {
                                        console.log(err);
                                } else {
                                        timestamp = new Date().toISOString();
                                        console.log(filename + " created at " + timestamp);
                                        reply(filename);
                                }
                        });
                });
        });

        // execute the POST to the highcharts server
        req.write(data);

        // if the highcharts server returns an error
        req.on('error', function(e) {
                console.log('** ERROR: problem with the phantomjs server: ' + e.message);
                reply('');
        });


        req.end();
    }
});


server.route({
    method: 'GET',
    path: '/{param*}',
    handler: {
        directory: {
            path: '/opt/chartimages'
        }
    }
});

// Start the server
server.start();
