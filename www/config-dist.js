var mysql = require('mysql');
var con = mysql.createConnection({
    user : 'naabscan',
    password : 'a2wYdNKNLcWZ74ym',
    database : 'naabscan',
    socketPath : '/var/run/mysqld/mysqld.sock',
});

module.exports = con;
