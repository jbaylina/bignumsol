/*jslint node: true */
"use strict";

var BASE = 16;

function add(a, b) {
    var i;
    var n = a.length>b.length ? a.length+1 : b.length+1;
    var r = Array(n);
    for (i=0; i<n; i++) r[i] =0;
    for (i=0; i<n-1; i++) {
         var a1 = a[a.length-i-1] || 0;
         var b1 = b[b.length-i-1] || 0;
         var s = r[n-i-1] + a1 + b1;
         r[n-i-1] = s % BASE;
         r[n-i-2] = Math.floor(s / BASE);
    }
    while (r[0] === 0) r.shift();
    return r;
}

function sub(a,b) {
    var i;
    var n = a.length>b.length ? a.length : b.length;
    var r = Array(n);
    for (i=0; i<n; i++) r[i] =0;
    var c =0;
    for (i=0; i<n; i++) {
        var a1 = a[a.length-i-1] || 0;
        var b1 = b[b.length-i-1] || 0;
        if (a1 >= b1 + c) {
            r[n-i-1] = a1 - b1 - c;
            c =0;
        } else {
            r[n-i-1] = BASE + a1 - b1 - c;
            c =1;
        }
    }
    while (r[0] === 0) r.shift();
    return r;
}

function cmp(a,b) {
    var i;
    if (a.length>b.length) return 1;
    if (a.length<b.length) return -1;
    for (i=0; i<a.length; i++) {
        if (a[i] === b[i]) continue;
        if (a[i]>b[i]) return 1; else return -1;
    }
    return 0;
}

function mul(a,b) {
    var i,j,k;
    var n = a.length + b.length +1;
    var r = Array(n);
    for (i=0; i<n; i++) r[i] =0;
    for (i=0; i< b.length; i++) {
        for (j=0; j<a.length; j++) {
            var m = a[a.length-j-1] * b[b.length-i-1];
            k =0;
            while (m>0) {
                var s = r[n-i-j-k-1] + m;
                m = Math.floor(s / BASE);
                r[n-i-j-k-1] = s%BASE;
                k++;
            }
        }
    }
    while (r[0] === 0) r.shift();
    return r;
}

function smallDiv(D1,D2, d) {
    var q = Math.floor((D1 * BASE + D2) / d);

    var r = [ Math.floor(q / BASE), q % BASE];

    while (r[0] === 0) r.shift();

    return r;
}

function div(a,b) {

    var qAcc = [0];
    var its =0;
    var i;

    while (cmp(a, b) >= 0) {


        var d = b[0] +1;
        var D1,D2;

        var p = (a.length - b.length);
        var cur;
        if (p === 0) {
            D1 =0;
            D2 = a[0];
            cur = 0;
        } else {
            D1 = a[0];
            D2 = a[1];
            cur = 1;
        }

        var q = smallDiv(D1,D2, d);

        var r = mul(b,q);

        for (i=0; i<p-cur; i++) {
            q.push(0);
            r.push(0);
        }

        a = sub(a, r);

        qAcc = add(q, qAcc);
        its ++;
    }

    console.log("its=" + its);

    return [ qAcc, a];
}

function num2big(a) {
    if (a===0) return [0];
    var r = [];
    while (a) {
        r.unshift(a % BASE);
        a = Math.floor(a/BASE);
    }
    return r;
}

function big2num(a) {
    var r=0;
    var b = 1;
    while (a.length) {
        var s = a.pop();
        r = r + s*b;
        b = b*BASE;
    }
    return r;
}

var a = 2147483648;
var b = 123445;

var bigA = num2big(a);
var bigB = num2big(b);

var bigA = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15];

var bigB = [
            15,15,15,15,15,10,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
            15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
];

var res = div(bigA,bigB);

console.log(JSON.stringify(res));

/*
var q = big2num(res[0]);
var r = big2num(res[1]);

console.log("a: " + a);
console.log("b: " + b);
console.log("a/b: " + Math.floor(a/b));
console.log("a%b: " + (a%b));
console.log("calc a/b: " + q);
console.log("calc a%b: " + r);

*/
