/*jslint node: true */
"use strict";

var async = require('async');
var ethConnector = require('ethconnector');
var path = require('path');
var _ = require('lodash');

var bigNumAbi;
var bigNum;

var src;

exports.deploy = function(opts, cb) {
    var compilationResult;
    return async.series([
        function(cb) {
            ethConnector.loadSol(path.join(__dirname, "../BigNum.sol"), function(err, _src) {
                if (err) return cb(err);
                src = _src;
                cb();
            });
        },
        function(cb) {
            ethConnector.applyConstants(src, opts, function(err, _src) {
                if (err) return cb(err);
                src = _src;
                cb();
            });
        },
        function(cb) {
            ethConnector.compile(src, function(err, result) {
                if (err) return cb(err);
                compilationResult = result;
                cb();
            });
        },
        function(cb) {
            bigNumAbi = JSON.parse(compilationResult.BigNum.interface);
            ethConnector.deploy(compilationResult.BigNum.interface,
                compilationResult.BigNum.bytecode,
                0,
                0,
                function(err, _bigNum) {
                    if (err) return cb(err);
                    bigNum = _bigNum;
                    cb();
                });
        },
    ], function(err) {
        if (err) return cb(err);
        cb(null,bigNum, compilationResult);
    });
};
