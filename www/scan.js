//Connection mysql
var con = require('./config');

exports.findById = function(req,res) {
    var id = req.params.id;
    var sql = 'SELECT * FROM scan s JOIN host h ON h.id = s.host_id WHERE s.id = ' + con.escape(id); con.query(sql, function (err,results){
            res.jsonp(results);
            });
};

exports.getLastHost = function(req,res) {
    var num = Number(req.params.num);
    if( isNaN(num) ){
        res.status(500);
        res.send('Fucking Naab is not a integer');
        return false;
    }
    var sql = ' SELECT s.id , s.date, s.host_id ,h.ip, h.scan  FROM scan s JOIN host h ON h.id = s.host_id  ORDER BY s.date DESC LIMIT ?';
    con.query(sql, num ,function (err,results){
            console.log(err);
            res.jsonp(results);
            });
};
