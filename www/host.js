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

