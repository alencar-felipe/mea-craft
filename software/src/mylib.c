#include "mylib.h"

typedef uint32_t size_t;

#define PAD_RIGHT 1
#define PAD_ZERO 2
#define PRINT_BUF_LEN 12 // the following should be enough for 32 bit int

static void printchar(char **str, int c);
static int prints(char **out, const char *string, int width, int pad);
static int printi(char **out, int i, int b, int sg, int width, int pad, int letbase);
static int print(char **out, const char *format, va_list args);

void *memset(void *s, int c, size_t n)
{
    unsigned char* p = s;
    while (n-- > 0) {
        *p++ = (unsigned char) c;
    }
    return s;
}

void *memcpy(void *dest, const void *src, size_t n) 
{
    unsigned char* dest_char = dest;
    const unsigned char* src_char = src;
    while (n-- > 0) {
        *dest_char++ = *src_char++;
    }
    return dest;
}

int putchar(int c)
{
    WRITE_BYTE(UART_DATA, c);
    return c;
}

int puts(const char *str) {
    int i = 0;
    while (str[i] != '\0') {
        putchar(str[i]);
        i++;
    }
    putchar('\n');
    return i;
}

int printf(const char *format, ...)
{
    va_list args;

    va_start(args, format);
    return print(0, format, args);
}

int sprintf(char *out, const char *format, ...)
{
    va_list args;

    va_start(args, format);
    return print(&out, format, args);
}

unsigned int __mulsi3(unsigned int a, unsigned int b)
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

unsigned int __udivsi3(unsigned int a, unsigned int b)
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

int __divsi3(int dividend, int divisor)
{
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

unsigned int __umodsi3(unsigned int dividend, unsigned int divisor)
{
	if (divisor == 0) {
		return 0;
	}

	unsigned int quotient = dividend / divisor;
	unsigned int remainder = dividend - (quotient * divisor);
	return remainder;
}

static void printchar(char **str, int c)
{
	if (str) {
		**str = c;
		++(*str);
	} else {
        putchar(c);
	}
}

static int prints(char **out, const char *string, int width, int pad)
{
	register int pc = 0, padchar = ' ';

	if (width > 0) {
		register int len = 0;
		register const char *ptr;
		for (ptr = string; *ptr; ++ptr) ++len;
		if (len >= width) width = 0;
		else width -= len;
		if (pad & PAD_ZERO) padchar = '0';
	}
	if (!(pad & PAD_RIGHT)) {
		for ( ; width > 0; --width) {
			printchar (out, padchar);
			++pc;
		}
	}
	for ( ; *string ; ++string) {
		printchar (out, *string);
		++pc;
	}
	for ( ; width > 0; --width) {
		printchar (out, padchar);
		++pc;
	}

	return pc;
}

static int printi(char **out, int i, int b, int sg, int width, int pad,
	int letbase)
{
	char print_buf[PRINT_BUF_LEN];
	register char *s;
	register int t, neg = 0, pc = 0;
	register unsigned int u = i;

	if (i == 0) {
		print_buf[0] = '0';
		print_buf[1] = '\0';
		return prints (out, print_buf, width, pad);
	}

	if (sg && b == 10 && i < 0) {
		neg = 1;
		u = -i;
	}

	s = print_buf + PRINT_BUF_LEN-1;
	*s = '\0';

	while (u) {
		t = u % b;
		if( t >= 10 )
			t += letbase - '0' - 10;
		*--s = t + '0';
		u /= b;
	}

	if (neg) {
		if( width && (pad & PAD_ZERO) ) {
			printchar (out, '-');
			++pc;
			--width;
		}
		else {
			*--s = '-';
		}
	}

	return pc + prints (out, s, width, pad);
}

static int print(char **out, const char *format, va_list args)
{
	register int width, pad;
	register int pc = 0;
	char scr[2];

	for (; *format != 0; ++format) {
		if (*format == '%') {
			++format;
			width = pad = 0;
			if (*format == '\0') break;
			if (*format == '%') goto out;
			if (*format == '-') {
				++format;
				pad = PAD_RIGHT;
			}
			while (*format == '0') {
				++format;
				pad |= PAD_ZERO;
			}
			for ( ; *format >= '0' && *format <= '9'; ++format) {
				width *= 10;
				width += *format - '0';
			}
			if( *format == 's' ) {
				register char *s = (char *)va_arg( args, int );
				pc += prints (out, s?s:"(null)", width, pad);
				continue;
			}
			if( *format == 'd' ) {
				pc += printi (out, va_arg( args, int ), 10, 1, width, pad, 'a');
				continue;
			}
			if( *format == 'x' ) {
				pc += printi (out, va_arg( args, int ), 16, 0, width, pad, 'a');
				continue;
			}
			if( *format == 'X' ) {
				pc += printi (out, va_arg( args, int ), 16, 0, width, pad, 'A');
				continue;
			}
			if( *format == 'u' ) {
				pc += printi (out, va_arg( args, int ), 10, 0, width, pad, 'a');
				continue;
			}
			if( *format == 'c' ) {
				/* char are converted to int then pushed on the stack */
				scr[0] = (char)va_arg( args, int );
				scr[1] = '\0';
				pc += prints (out, scr, width, pad);
				continue;
			}
		}
		else {
		out:
			printchar (out, *format);
			++pc;
		}
	}
	if (out) **out = '\0';
	va_end( args );
	return pc;
}