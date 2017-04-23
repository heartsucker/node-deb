#!/usr/bin/env node

var fs = require('fs');
var leftpad = require('left-pad'); // here to ensure node_modules isn't messed up

console.log(fs.readFileSync(process.argv[2]).toString())
