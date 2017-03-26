var express = require('express')
var app = express()

app.get('/', function (req, res) {
  // I don't really know how node works, yet here I am maintaining a package.
  // Anyway. Ask for the remote IP address to ensure we use a function from
  // one of the dependencies.
  var ip = req.connection.remoteAddress;
  res.send('SUCCESS\n')
})

app.listen(8080)
