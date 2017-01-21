/*jslint node: true */
"use strict";

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'));
