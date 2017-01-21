pragma solidity ^0.4.4;

contract BigNum {

    struct BigNum {
        uint l;
        uint[] a;
    }

    function newBigNum(uint maxLen) internal returns (BigNum) {
        BigNum memory bn;
        bn.l = 0;
        bn.a = new uint[](maxLen);
        return bn;
    }

    function __div(BigNum a, BigNum b) internal returns(BigNum div, BigNum rem) {
        uint q1;
        uint qm;
        uint ql;

        if (__isZero(b)) {
            throw;
        }

        if (__isZero(a)) {
            return (newBigNum(0), newBigNum(0));
        }

        if (b.l>a.l) {
            return (newBigNum(0), a);
        }

        BigNum memory q = newBigNum(1 + a.l - b.l);
        BigNum memory r = newBigNum(a.l);

        uint d = b.a[b.a.length - b.l];
        if (b.l == 1) d--;


        while ( __gte(a,b) ) {


            uint cur;
            uint D;
            if (a.l == b.l) {
                D = a.a[a.a.length - a.l] * (2**128);
                if (a.l>1) D += a.a[a.a.length - a.l +1];

                d = b.a[b.a.length - b.l] *(2**128);
                if (b.l>1) d += b.a[b.a.length - b.l + 1];

                if (((d+1) == 0)||(b.l<=2)) d--;  // do not let overflow.

                cur = 0;
            } else {
                D = a.a[a.a.length - a.l] * (2**128) + a.a[a.a.length - a.l +1];
                cur = a.l-b.l-1;
            }

            q1 = D / (d+1);
            if (q1==0) q1=1;

            ql = q1 & (  (2**128) -1);
            qm = q1 / (2**128);


            r.l =0;
            __mul1acc(r,  b, ql, cur);
            __mul1acc(r,  b, qm, cur+1);

            __sum1to(q, ql, cur);
            __sum1to(q, qm, cur+1);

            __subFrom(a, r);

        }

        return (q, a);
    }


    function __mod(BigNum a, BigNum b) internal returns(BigNum rem) {
        uint q1;
        uint qm;
        uint ql;
        uint its = 0;

        if (__isZero(b)) {
            throw;
        }

        if (__isZero(a)) {
            return newBigNum(0);
        }

        if (b.l>a.l) {
            return a;
        }

        BigNum memory r = newBigNum(a.l);

        uint d = b.a[b.a.length - b.l];
        if (b.l == 1) d--;


        while ( __gte(a,b) ) {


            uint cur;
            uint D;
            if (a.l == b.l) {
                D = a.a[a.a.length - a.l] * (2**128);
                if (a.l>1) D += a.a[a.a.length - a.l +1];

                d = b.a[b.a.length - b.l] *(2**128);
                if (b.l>1) d += b.a[b.a.length - b.l + 1];

                if (((d+1) == 0)||(b.l<=2)) d--;  // do not let overflow.

                cur = 0;
            } else {
                D = a.a[a.a.length - a.l] * (2**128) + a.a[a.a.length - a.l +1];
                cur = a.l-b.l-1;
            }

            q1 = D / (d+1);
            if (q1==0) q1=1;

            ql = q1 & (  (2**128) -1);
            qm = q1 / (2**128);


            r.l =0;
            __mul1acc(r,  b, ql, cur);
            __mul1acc(r,  b, qm, cur+1);

            __subFrom(a, r);

            its ++;

        }

        return a;
    }


    function __mul(BigNum a, BigNum b) internal returns(BigNum) {
        uint i;

        BigNum memory r = newBigNum(a.l + b.l);

        for (i=0; i<b.l; i++) {
            __mul1acc(r,  a, b.a[b.a.length-i-1], i);
        }

        return r;
    }

    function __powMod(BigNum a, BigNum b, BigNum m) internal returns(BigNum) {
        uint i;

        BigNum memory acc = newBigNum( m.l*2 );
        BigNum memory r = newBigNum(m.l);

        var amod = __mod(a, m);


        r.l=1;
        r.a[r.a.length-1] =1;

        acc = __mod(a, m);


        for (i=0; i<b.l; i++) {
            uint exp = b.a[b.a.length-i-1];

            if (i == b.l-1) {
                while (exp != 0) {

                    if (exp & 1  == 1) {
                        r = __mul(acc, amod);
                        r = __mod(r, m);
                    }

                    acc = __mul(acc, acc);
                    acc = __mod(acc, m);
                    exp = exp/2;
                }
            } else {
                for (i=0; i<128; i++) {
                    if (exp & 1 == 1) {
                        r = __mul(acc, amod);
                        r = __mod(r, m);
                    }

                    acc = __mul(acc, acc);
                    acc = __mod(acc, m);
                    exp = exp/2;
                }
            }
        }

        return r;
    }

    function __isZero(BigNum a) internal returns(bool) {
        uint i;
        for (i=a.a.length-a.l; i<a.a.length; i++) {
            if (a.a[i] != 0) return false;
        }
        return true;
    }

    function __gte(BigNum a, BigNum b) internal returns(bool) {
        uint i;
        if (a.l>b.l) return true;
        if (a.l<b.l) return false;
        for (i=0; i<a.l; i++) {
            uint a1 = a.a[a.a.length-a.l+i];
            uint b1 = b.a[b.a.length-b.l+i];
            if (a1 != b1) {
                return (a1>b1);
            }
        }
        return true;
    }

    // acc = acc + a * q **e
    function __mul1acc(BigNum acc,  BigNum b,  uint q, uint e) internal {
        if (q==0) return;
        uint al = b.l + e +1;
        uint i;
        while ((acc.l < al )&&(acc.l<acc.a.length)) {
            acc.l++;
            acc.a[acc.a.length - acc.l ] = 0;
        }
        if (acc.l < acc.a.length) {
            acc.l++;
            acc.a[acc.a.length-acc.l] =0;
        }
        for (i=0; i<b.l; i++) {
            uint m = b.a[b.a.length-i-1] * q;
            uint k=acc.a.length - e - i - 1;
            while (m>0) {
                m = m + acc.a[k];
                acc.a[k] = m & ((2**128) -1);
                m = m / (2**128);
                if (m>0) k--;
            }
        }
        while ((acc.l>0)&&(acc.a[acc.a.length - acc.l] == 0)) acc.l--;
    }

    function __sum1to(BigNum acc, uint q, uint e) internal {
        if (q==0) return;
        uint m = q;
        uint k=acc.a.length - e - 1;
        while (acc.l <= e) {
            acc.l ++;
            acc.a[acc.a.length - acc.l] = 0;
        }
        if (acc.l < acc.a.length) {
            acc.l++;
            acc.a[acc.a.length-acc.l] =0;
        }
        while (m>0) {
            m = m + acc.a[k];
            acc.a[k] = m & ((2**128) -1);
            m = m / (2**128);
            if (m>0) k--;
        }
        while ((acc.l>0)&&(acc.a[acc.a.length - acc.l] == 0)) acc.l--;
    }

    function __subFrom(BigNum a, BigNum b) internal {
        uint c =0;
        uint i;
        uint d1;
        uint d2;

        for (i=0; i<a.l; i++) {
            d1 = a.a[a.a.length-i-1];
            if (i<b.l) {
                d2 = b.a[b.a.length-i-1] + c;
            } else {
                d2 = c;
            }
            if (d1 >= d2) {
                a.a[a.a.length -i -1] = d1 - d2;
                c = 0;
            } else {
                a.a[a.a.length -i -1] = (2**128) + d1 - d2;
                c=1;
            }
        }
        while ((a.l>0)&&(a.a[a.a.length - a.l] == 0)) a.l--;
    }

    function __load(bytes b) internal returns (BigNum) {
        uint fullWords = b.length/16;
        uint remainderBytes = b.length % 16;
        uint i;

        uint totalLen = remainderBytes > 0 ? fullWords+1 : fullWords;
        BigNum memory r = newBigNum(totalLen);
        r.l = totalLen;

        uint p;
        uint mask;
        uint tmp;
        if (remainderBytes > 0) {
            p = remainderBytes;
            mask = (2 ** (8*remainderBytes)) -1;
            assembly {
                tmp:= mload(add(b,p))
                tmp:= and(tmp,mask)
            }
            r.a[0] = tmp;
            p += 16;
            i=1;
        } else {
            p = 16;
            i=0;
        }
        mask = (2**128)-1;
        for (;i<totalLen; i++) {
            assembly {
                tmp:= mload(add(b,p))
                tmp:= and(tmp,mask)
            }
            r.a[i] = tmp;
            p += 16;
        }

        while ((r.l>0)&&(r.a[r.a.length - r.l] == 0)) r.l--;
        return r;
    }

    function __save(BigNum num) internal returns(bytes) {
        if (num.l == 0) {
            return new bytes(1);
        }
        uint fullWords = num.l -1;
        uint tmp = num.a[num.a.length - num.l];
        uint remainderBytes =0;
        uint i;
        while (tmp>0) {
            remainderBytes ++;
            tmp = tmp / 0x100;
        }
        if (remainderBytes == 16) {
            remainderBytes = 0;
            fullWords += 1;
        }

        uint totalLen = fullWords*16+remainderBytes;
        bytes memory b = new bytes(totalLen);

        uint p = totalLen;  // + 32 - 32
        for (i=0; i<num.l; i++) {
            tmp = num.a[num.a.length - i -1];
            assembly {
                mstore(add(b,p), tmp)
            }
            p -= 16;
        }
        // Fix the length
        assembly {
            mstore(b, totalLen)
        }

        return(b);
    }

    BigNum public testa;
    BigNum public testb;
    uint public test1;
    uint public test2;
    uint public test3;
    uint public test4;
    uint public test5;
    uint public test6;
    uint public test7;
    uint public test8;
    uint public it;
    bool public testBool;

    function testaL() constant returns(uint) {
        return testa.l;
    }

    function testaA(uint idx) constant returns(uint) {
        return testa.a[testa.a.length - idx -1];
    }

    function testbL() constant returns(uint) {
        return testb.l;
    }

    function testbA(uint idx) constant returns(uint) {
        return testb.a[testb.a.length - idx -1];
    }

    function loadSave(bytes a) returns(bytes b) {
        BigNum memory n = __load(a);
        testa = n;
        b = __save(n);
        Test(b);
    }

    function divT(bytes a, bytes b) returns(bytes q, bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);

        var (bq, br) = __div(ba,bb);

        q = __save(bq);
        r = __save(br);

        Test(q);
        Test(r);
    }

    function div(bytes a, bytes b) constant returns(bytes q, bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);

        var (bq, br) = __div(ba,bb);

        q = __save(bq);
        r = __save(br);
    }

    function mulT(bytes a, bytes b) returns(bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);

        var br = __mul(ba,bb);

        r = __save(br);

        Test(r);
    }

    function mul(bytes a, bytes b) constant returns(bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);

        var br = __mul(ba,bb);

        r = __save(br);
    }

    function powModT(bytes a, bytes b, bytes m) returns(bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);
        BigNum memory bm = __load(m);


        var br = __powMod(ba,bb, bm);

        r = __save(br);

        Test(r);
    }

    function powMod(bytes a, bytes b, bytes m) constant returns(bytes r) {
        BigNum memory ba = __load(a);
        BigNum memory bb = __load(b);
        BigNum memory bm = __load(m);

        var br = __powMod(ba,bb,bm);

        r = __save(br);
    }

    event Test(bytes b);
}
