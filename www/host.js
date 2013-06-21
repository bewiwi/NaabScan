//Connection mysql
var con = require('./config');

exports.findById = function(req,res) {
    var id = req.params.id;
    var sql = 'SELECT * FROM host WHERE id = ?';
    con.query(sql,id, function (err,results){
            res.jsonp(results);
            });
};

exports.findAll = function(req,res) {
    var sql = 'SELECT * FROM host';
    con.query(sql, function (err,results){
            res.jsonp(results);
            });
};

exports.addOrUpdate = function(req,res) {
    var ip = req.params.ip;
    
    var CheckIP = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
    if(! CheckIP.test(ip))
    {
        console.log("Your IP Address Is NOT Valid.");
        res.send(404, 'Et Mon *** c\'est une ip ?');
        return false;
    }

    var sql = 'SELECT id FROM host WHERE ip = ?';
    var exist = 1;
    con.query(sql,ip,function (err,results){
            if ( typeof(results[0]) == 'undefined' ){
            sql = 'INSERT INTO host (ip,scan) VALUES ( ? , 1 )';
            }else{
            sql = 'UPDATE host SET scan = 1 WHERE ip = ?';
            }
            con.query(sql,ip,function (err,results){
                if (err){
                //                res.jsonp(err);        
                res.send(500,'ERROR ');
                }
                res.send(200,'Ok naab');
                });
            });

};
