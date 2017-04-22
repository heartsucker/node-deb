#!/usr/bin/env node

var fs = require('fs');

fs.readFile(process.argv[1], 'utf8', function(e, d) {
    if err != null {
        console.log(d);
        process.exit(0);
    } else {
        console.log(e);
        process.exit(1);
    }
});
