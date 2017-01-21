/*jslint node: true */
"use strict";

var ursa = require('ursa');
var BigNumber = require('bignumber.js');


var keys = ursa.generatePrivateKey();
console.log('keys:', keys);


console.log('exponent: ', keys.getExponent().toString('hex'));
console.log('modulus: ', keys.getModulus().toString('hex'));

var text = "Hello world!";

console.log("text: ", text);

var data = new Buffer(text, 'utf8');
console.log('data: ', data.toString('hex'));

var enc = keys.privateEncrypt(data);
console.log('enc: ', enc.toString('hex'));


var unenc1 = keys.publicDecrypt(enc);
console.log('unenc_good: ', unenc1.toString('hex'));

var modB  = new BigNumber(keys.getModulus().toString('hex'),16);
console.log('modulusH: ', modB.toString(16));

var expB = new BigNumber(keys.getExponent().toString('hex'), 16);
console.log('expH: ', expB.toString(16));

var encB = new BigNumber(enc.toString('hex'), 16);
console.log('encB: ', encB.toString(16));

var unencB = encB.toPower(expB, modB);
var unencH = unencB.toString(16);
console.log('unencH: ', encB.toString(16));


if (unencH.length % 2 == 1) unencH = '0' + unencH;
var unenc2 = new Buffer(unencH, 'hex');

console.log('unenc_good: ', unenc2.toString('hex'));

var untext = unenc2.toString('utf8');
console.log("unenc text: ", untext);




