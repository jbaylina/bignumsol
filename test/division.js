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
    it('Should Divide two small numbers', function(done) {
        var a = num2buff(2);
        var b = num2buff(1);
        checkTestDivision(a,b, done);
    });
    it('Should work various edge cases', function(done) {

        function n(f) {
            var n = f/4;
            var S= "1" + Array(n).join("0");
            var bn = new BigNumber(S, 16);
            console.log(bn.toString(16));
            return bn;
        }
        this.timeout(2000000);
        var edgeNumbers = [
            new BigNumber('01',16),
            new BigNumber('02',16),
            new BigNumber('03',16),
            new BigNumber('FF',16),
            new BigNumber('0100',16),
            n(16).sub(1),
            n(16),
            n(16).add(1),

            n(32).sub(1),
            n(32),
            n(32).add(1),

            n(64).sub(1),
            n(64),
            n(64).add(1),

            n(128).sub(1),
            n(128),
            n(128).add(1),

            n(256).sub(1),
            n(256),
            n(256).add(1),

            n(256).sub(1),
            n(256),
            n(256).add(1),

            n(512).sub(1),
            n(512),
            n(512).add(1),

            n(1024).sub(1),
            n(1024),
            n(1024).add(1),
        ];
        var i=0;
        var j=0;
        async.whilst(
            function() { return i<edgeNumbers.length; },
            function(cb) {
                checkDivision(num2buff(edgeNumbers[i]), num2buff(edgeNumbers[j]), function(err) {
                    if (err) return cb(err);
                    j++;
                    if (j == edgeNumbers.length) {
                        i++;
                        j=0;
                    }
                    cb();
                });
            },
            done
        );
    });

    function checkDivision(a,b, cb) {
        var aB = new BigNumber(a);
        var bB = new BigNumber(b);
        var qB = aB.divToInt(bB);
        var rB = aB.modulo(bB);
        log(aB.toString(16) + " / " + bB.toString(16));
        bigNumContract.div(num2buff(aB), num2buff(bB), function(err, res) {
            assert.ifError(err);
            var q2B = new BigNumber(res[0]);
            var r2B = new BigNumber(res[1]);
            log(qB.toString(16) + " , " + rB.toString(16));
            log(q2B.toString(16) + " , " + r2B.toString(16));
            assert(qB.equals(res[0]));
            assert(rB.equals(res[1]));
            cb();
        });
    }

    function checkTestDivision(a,b, cb) {
        var aB = new BigNumber(a);
        var bB = new BigNumber(b);
        var qB = aB.div(bB).floor();
        var rB = aB.modulo(bB);
        log("test: " + aB.toString(16) + " / " + bB.toString(16));
        bigNumContract.divT(num2buff(aB), num2buff(bB), {from: ethConnector.accounts[0], gas: 4000000}, function(err, res) {
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



