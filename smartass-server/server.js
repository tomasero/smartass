var EventSource = require('eventsource');
var rest = require('restler');

var deviceID = "36002b000447343337373738";
var accessToken = "0700fc7548ae1314981e2f828371ed67459a8e42";
var accessTokenURI = "/?access_token=" + accessToken;
var device = "https://api.particle.io/v1/devices/" + deviceID;
var eventsURI = device + "/events" + accessTokenURI;
var eventSrc = new EventSource(eventsURI);
var pressureURI = device + "/fsrReading" + accessTokenURI;
var pressureDict = {};

eventSrc.addEventListener('pressure', function(e) {
    var data = JSON.parse(e.data);
    pressureDict = JSON.parse(data['data']);
    console.log(pressureDict);
//    console.log(JSON.stringify(pressureDict));
});

eventSrc.addEventListener('status', function (e) {
    var data = JSON.parse(e.data);
    console.log(data);
});
// es.addEventListener('GPS_RAW', function(e) {
//     var data = JSON.parse(e.data);
//     console.log(data['data']);
// });


function getPressure() {
    rest.post(pressureURI).on('complete', function (data, response) {
        var data = JSON.parse(e.data);
        console.log(data);
    });
}

var express = require('express');
var app = express();

app.get('/getPressure', function(req, res){
    console.log("getPressure");
    res.json(pressureDict);
});

app.listen(3000);
