//Connection mysql
var con = require('./config');

exports.findPortsByScanId = function(req,res) {
    var id = req.params.scanid;
    var sql = 'SELECT * FROM port WHERE scan_id = ?';
    con.query(sql, id ,function (err,results){
            console.log(err);
            res.jsonp(results);
            });
};
