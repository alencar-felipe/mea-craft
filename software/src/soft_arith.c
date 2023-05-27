unsigned int __mulsi3 (unsigned int a, unsigned int b)
{
    unsigned int r = 0;

    while (a) {
        if (a & 1) {
	        r += b;
        }
        
        a >>= 1;
        b <<= 1;
    }

    return r;
}

unsigned int __udivsi3 (unsigned int a, unsigned int b)
{
    unsigned int quotient;

    if (b == 0) return 0xFFFFFFFF;

    quotient = 0;

    while (a >= b) {
        a -= b;
        quotient++;
    }

    return quotient;
}

int __divsi3(int dividend, int divisor) {
    int quotient = 0;
    int sign = 1;
    
    if (dividend < 0) {
        sign = -sign;
        dividend = -dividend;
    }
    
    if (divisor < 0) {
        sign = -sign;
        divisor = -divisor;
    }
    
    while (dividend >= divisor) {
        dividend -= divisor;
        quotient++;
    }
    
    return sign * quotient;
}
