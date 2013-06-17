var express = require('express'),
    hosts = require('./host'),
    ports = require('./port'),
    scans = require('./scan');

var app = express();

//Host
app.get('/host/:id',hosts.findById);
app.get('/host',hosts.findAll);

//Scan
app.get('/scan/:id',scans.findById);
app.get('/scan/last/:num',scans.getLastHost);

//Ports
app.get('/port/:scanid',ports.findPortsByScanId);

app.listen(1337);
console.log('Naab Listening');
