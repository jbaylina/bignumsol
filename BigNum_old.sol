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
        uint its = 0;

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

/*
            if (its == 1 ) {
                testa = r;
                testb = b;
                test1 = q1;
                test2 = qm;
                test3 = cur;
                test4 = D;
                test5 = d;
                return;
            }
*/
            __mul1acc(r,  b, qm, cur+1);



            __sum1to(q, ql, cur);
            __sum1to(q, qm, cur+1);
            __subFrom(a, r);

            its ++;


        }

        return (q, a);
    }

    function __divold2(BigNum a, BigNum b) internal returns(BigNum div, BigNum rem) {
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



        uint[] memory d = new uint[](4);
        d[0] = b.a[b.a.length - b.l];
        d[1] = b.l>1 ? b.a[b.a.length - b.l + 1]: 0;
        d[2] = b.a[b.a.length - b.l] + 1;
        d[3] = b.l>1 ? (2**128) - b.a[b.a.length - b.l + 1] : 2**128;
        d[3] --;


        while ( __gte(a,b) ) {

            uint cur;
            uint D;
            if (a.l == b.l) {
                D = a.a[a.a.length - a.l] * (2**128);
                if (a.l>1) D += a.a[a.a.length - a.l +1];
                d[0] = d[0]*(2**128) + d[1];
                d[2] = d[0] +1;
                if (b.l>2) {
                    d[1]=b.a[b.a.length - b.l + 2];
                    d[3] = (2**128) - b.a[b.a.length - b.l + 1] -1;
                } else {
                    d[1] =0;
                    d[3] = 2**128 -1;
                }

                cur = 0;
            } else {
                D = a.a[a.a.length - a.l] * (2**128) + a.a[a.a.length - a.l +1];
                cur = a.l-b.l-1;
            }

            if (d[0] > 2**128) {
                qm = d[0]-1;
            } else {
                qm = (d[0] * (2**128) - d[1]) / (2**128);
            }
            qm = D / d[0] * qm / d[0];

            if (d[0] > 2**128) {
                ql = d[2];
            } else {
                ql = (d[2] * (2**128) + d[3]) / (2**128);
            }
            ql = D / d[2] * ql / d[2];

            q1 = qm > ql ? qm : ql;
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


    function __divold(BigNum a, BigNum b) internal returns(BigNum div, BigNum rem) {

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

        while ( __gte(a,b) ) {

            uint cur;
            uint D;
            if (a.l == b.l) {
                D = a.a[a.a.length - a.l];
                cur = 0;
            } else {
                D = a.a[a.a.length - a.l] * (2**128) + a.a[a.a.length - a.l +1];
                cur = a.l-b.l-1;
            }


            uint q1;
            uint qm;
            uint ql;
            ql = D/(b.a[b.a.length - b.l]+1);
            qm = D/(b.a[b.a.length - b.l]);

            if (b.l>1) {
                q1 = (qm * b.a[b.a.length - b.l + 1]  +
                     ql * ( (2**128) - b.a[b.a.length - b.l + 1])) /
                        (2**128);
            } else {
                q1 = qm;
            }


//          uint q1 = D/b.a[b.a.length - b.l];
            ql = q1 & (  (2**128) -1);
            qm = q1 / (2**128);



            bool done=false;
            while (!done) {
                r.l =0;
                __mul1acc(r,  b, ql, cur);
                __mul1acc(r,  b, qm, cur+1);
                done = __gte(a, r);
                if (!done) {
                    q1 = (q1 + (D/(b.a[b.a.length - b.l]+1))) / 2;
//                    q1--;
                    ql = q1 & (  (2**128) -1);
                    qm = q1 / (2**128);
                }
            }

// g

            __sum1to(q, ql, cur);
            __sum1to(q, qm, cur+1);
            __subFrom(a, r);

/*
            test1 = q1;
            test2 = q2;
            test3 = q.a.length;

            test4 ++;
            if (test4==4)  return (q,a);
*/
        }



        return (q, a);
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

    event Test(bytes b);
}
