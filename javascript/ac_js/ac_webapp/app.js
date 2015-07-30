var express = require('express');
var app = express();
var fs = require('fs');

app.use('/data', express.static('../../../data'));
app.use('/res', express.static('../../../resources'));
app.use('/js', express.static('../../../js_lib'));

app.get('/', function(req, res) {
  res.set('Content-Type', 'text/html');
  fs.readFile('ac_vis.html', function(err, data){
    res.send(data);
  });
});

var server = app.listen(8000, function() {
  var host = server.address().address;
  var port = server.address().port;

  console.log('AC webapp listening at http://%s:%s', host, port);
})
