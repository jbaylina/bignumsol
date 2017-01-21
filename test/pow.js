/*jslint node: true */
/*global describe, it, before, beforeEach, after, afterEach */
"use strict";


var bigNum_helper = require('../js/bignum_helper.js');
var ethConnector = require('ethconnector');
var assert = require("assert"); // node.js core module
var async = require('async');
var _ = require('lodash');
var BigNumber = require('bignumber.js');

var verbose = true;

function log(S) {
    if (verbose) {
        console.log(S);
    }
}

function num2buff(n) {
    var bn = new BigNumber(n);
    var s = bn.toString(16);
    if (s.length % 2 === 1) s = '0' + s;
    s = '0x' +s;
    return s;
}

describe('BigNum Division Test', function(){
    var bigNumContract;
    before(function(done) {
        this.timeout(20000);
        ethConnector.init('testrpc',{gasLimit: 4000000},done);
    });
    it('should deploy a bigNum ', function(done){
        this.timeout(2000000);
        bigNum_helper.deploy({}, function(err, _bigNumContract) {
            assert.ifError(err);
            assert.ok(_bigNumContract.address);
            bigNumContract = _bigNumContract;
            done();
        });
    });
    it('Should Power two small numbers', function(done) {
        var a = num2buff(3);
        var b = num2buff(3);
        var m = num2buff(7);
        checkTestPow(a,b,m, done);
    });
    it('Should Power two small numbers', function(done) {
        var a = num2buff(3);
        var b = num2buff(3);
        var m = num2buff(7);
        checkPow(a,b,m, done);
    });
    function checkPow(a,b,m, cb) {
        var aB = new BigNumber(a);
        var bB = new BigNumber(b);
        var mB = new BigNumber(m);
        var rB = aB.toPower(bB, mB);
        log(aB.toString(16) + " ^ " + bB.toString(16) + " % " + mB.toString(16));
        bigNumContract.powMod(num2buff(aB), num2buff(bB), num2buff(mB), function(err, res) {
            assert.ifError(err);
            var r2B = new BigNumber(res);
            log(rB.toString(16));
            log(r2B.toString(16));
            assert(rB.equals(res));
            cb();
        });
    }

    function checkTestPow(a,b,m, cb) {
        var aB = new BigNumber(a);
        var bB = new BigNumber(b);
        var mB = new BigNumber(m);
        var rB = aB.toPower(bB, mB);
        log("test: " + aB.toString(16) + " ^ " + bB.toString(16) + " % " + mB.toString(16));
        bigNumContract.powModT(num2buff(aB), num2buff(bB), num2buff(mB), {from: ethConnector.accounts[0], gas: 4000000}, function(err, res) {
            assert.ifError(err);
            async.series([
                function(cb) {
                    bigNumContract.testaL(function(err, res) {
                        assert.ifError(err);
                        var N = res.toNumber();
                        log("testaL = " + N);
                        var i=0;
                        async.whilst(
                            function() { return i<N; },
                            function(cb) {
                                bigNumContract.testaA(i, function(err, res) {
                                    assert.ifError(err);
                                    log("--> " + res.toString(16));
                                    i++;
                                    cb();
                                });
                            },
                            cb
                        );
                    });
                },
                function(cb) {
                    bigNumContract.testbL(function(err, res) {
                        assert.ifError(err);
                        var N = res.toNumber();
                        log("testbL = " + N);
                        var i=0;
                        async.whilst(
                            function() { return i<N; },
                            function(cb) {
                                bigNumContract.testbA(i, function(err, res) {
                                    assert.ifError(err);
                                    log("--> " + res.toString(16));
                                    i++;
                                    cb();
                                });
                            },
                            cb
                        );
                    });
                },
                function(cb) {
                    bigNumContract.test1(function(err, res) {
                        assert.ifError(err);
                        log("test1 = " + res.toString(16));
                        cb();
                    });
                },
                function(cb) {
                    bigNumContract.test2(function(err, res) {
                        assert.ifError(err);
                        log("test2 = " + res.toString(16));
                        cb();
                    });
                },
                function(cb) {
                    bigNumContract.test3(function(err, res) {
                        assert.ifError(err);
                        log("test3 = " + res.toString(16));
                        cb();
                    });
                },
                function(cb) {
                    bigNumContract.test4(function(err, res) {
                        assert.ifError(err);
                        log("test4 = " + res.toString(16));
                        cb();
                    });
                },
                function(cb) {
                    bigNumContract.test5(function(err, res) {
                        assert.ifError(err);
                        log("test5 = " + res.toString(16));
                        cb();
                    });
                }
            ], cb);
        });
    }
});



