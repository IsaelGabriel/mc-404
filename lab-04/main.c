#include <stdio.h>

/*int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}*/

#define STDIN_FD  0
#define STDOUT_FD 1
#define BUFFER_SIZE 20

int power(int a, int b) {
    int c = 1;
    for(int i = 0; i < b; i++) {
        c *= a;
    }
    return c;
}

void decimal_conversion(int* conv, char* str) {
    int p = 0;
    int i = BUFFER_SIZE - 1;
    while(i > 0) {
        if(*(str + i) >= 48 && *(str + i) <= 57) {
            *conv += (*(str + i) - 48) * power(10, p);
            p++;
        }
        i--;
    }
    if(*str == 45) *conv *= -1;
}

void hex_conversion(int* conv, char* str) {
    int p = 0;
    int i = BUFFER_SIZE - 1;
    while(i > 0) {
        if(*(str + i) >= 48 && *(str + i) <= 57) {
            *conv += (*(str + i) - 48) * power(16, p);
            p++;
        }else if (*(str + i) >= 65 && *(str + i) <= 70){
            *conv += (*(str + i) - 55) * power(16, p);
            p++;
        }else if(*(str + i) >= 97 && *(str + i) <= 102) {
            *conv += (*(str + i) - 87) * power(16, p);
            p++;
        }
        i--;
    }
}

void to_bin_str(int n, char* buf) {
    for(int i = 0; i < 36; i++) {
        buf[i] = 0;
    }

    int neg = n < 0;
    unsigned int nn = n;
    if(neg) {
        nn = -n;
        nn = ~nn + 1;
    }else {
        nn = n;
    }

    char str[33];
    for(int i = 0; i < 33; i++) {
        str[i] = 0;
    }

    *buf = '0';
    *(buf + 1) = 'b';

    int k;

    for(int i = 31; i >= 0; i--) {
        k = nn >> i;
        str[31 - i] = '0' + (k & 1);
    }
    
    int j = 0;
    if(str[0] == '0') {
        while(str[j] == 48) {
            j++;
        }
    }

    if(j == 32) *(buf + 2) = '0';
    else {
        for(int a = 0; a < 32 - j; a++) {
            *(buf + 2 + a) = str[a + j];
        }
    }
    *(buf + 3 + 32 - j) = '\n';
    for(int i = 4 + 32 - j; i < 36; i++) {
        buf[i] = 0;
    }
}

void to_dec_str(int n, char* out) {
    int pseudo_neg = (n >> 31) & 1;
    //int true_neg = n < 0;
    unsigned int nn = 0;
    int start_n = 0; 
    if(pseudo_neg) {
        start_n = 1;
        nn = ~(n - 1);
        out[0] = '-';
    }else {
        nn = n;
    }

    for(int i = 10; i >= start_n; i--) {
        out[i] = (nn % 10) + 48;
        nn = (nn - (nn % 10)) / 10;
    }

    int end_n = 10;
    
    if(out[start_n] == '0') {
        while(out[start_n] == '0' && end_n > start_n) {
            for(int i = start_n; i < end_n; i++) {
                out[i] = out[i+1];
            }
            out[end_n] = 0;
            end_n--;
        }
    }

    out[12] = 0;

}

void to_unsigned_str(int n, char* out) {
    unsigned int a = n;
    unsigned int bytes[4];
    unsigned int b = 0;

    bytes[0] = (a & 0x000000FF) >> 0;
    bytes[1] = (a & 0x0000FF00) >> 8;
    bytes[2] = (a & 0x00FF0000) >> 16;
    bytes[3] = (a & 0xFF000000) >> 24;

    bytes[0] <<= 24;
    bytes[1] <<= 16;
    bytes[2] <<= 8;
    bytes[3] <<= 0;

    b = (bytes[0] | bytes[1] | bytes[2] | bytes[3]);


    for(int i = 9; i >= 0; i--) {
        out[i] = (b % 10) + 48;
        b = (b - (b % 10)) / 10;
    }

    int end_n = 9;

    if(out[0] == '0') {
        while(out[0] == '0' && end_n > 0) {
            for(int i = 0; i < end_n; i++) {
                out[i] = out[i+1];
            }
            out[end_n] = 0;
            end_n--;
        }
    }
}

void to_hex_str(int n, char* out) {
    int neg = n < 0;
    unsigned int a;
    if(neg) {
        a = -n;
        a = ~a + 1;
    }else {
        a = n;
    }

    out[0] = '0';
    out[1] = 'x';

    int i = 9;
    while(i >= 2) {
        char code = (a % 16) + 48;
        if(code > 57) code += 39;
        out[i] = code;

        a = (a - (a % 16)) / 16;
        i--;
    }
    
    
    int end_n = 9;
    if(out[2] == '0') {
        while(out[2] == '0' && end_n > 2) {
            for(int j = 2; j < end_n; j++) {
                out[j] = out[j+1];
            }
            out[end_n] = 0;
            end_n--;
        }
    }


}

void to_octal_str(int n, char* out) {
    for(int x = 0; x < 15; x++) {
        out[x] = 0;
    }
    
    int neg = n < 0;
    unsigned int a;
    if(neg) {
        a = -n;
        a = ~a + 1;
    }else {
        a = n;
    }

    out[0] = '0';
    out[1] = 'o';

    int i = 12;
    while(i >= 2) {
        char code = (a % 8) + 48;
        if(code > 57) code += 39;
        out[i] = code;

        a = (a - (a % 8)) / 8;
        i--;
    }
    
    
    int end_n = 12;
    if(out[2] == '0') {
        while(out[2] == '0' && end_n > 2) {
            for(int j = 2; j < end_n; j++) {
                out[j] = out[j+1];
            }
            out[end_n] = 0;
            end_n--;
        }
    }

    out[end_n + 1] = '\n';
}

void routine(int n) {
    char out_bin[36];
    char out_dec[13];
    char out_unsigned[11];
    char out_hex[11];
    char out_octal[15];

    printf("From: %d\n", n);

    to_bin_str(n, out_bin);

    printf("%s\n", out_bin);

    to_dec_str(n, out_dec);

    printf("%s\n", out_dec);

    to_unsigned_str(n, out_unsigned);

    printf("%s\n", out_unsigned);

    to_hex_str(n, out_hex);

    printf("%s\n", out_hex);

    to_octal_str(n, out_octal);

    printf("%s\n\n", out_octal);


    //printf("From: %d\n%s\n%s\n%s\n%s\n\n", n, out_bin, out_dec, out_unsigned, out_hex);

}

int main()
{
    char str[20];
    /* Read up to 20 bytes from the standard input into the str buffer */
    //int n = read(STDIN_FD, str, 20);
    
    int conv = -545648;
    /*
    if(str[0] == '0' && str[1] == 'x') {
        hex_conversion(&conv, str);
    }else {
        decimal_conversion(&conv, str);
    }*/

    //scanf("%d", &conv);

    routine(545648);
    routine(0x545648);
    routine(-545648);
    routine(0x80000000);

    //write(STDOUT_FD, out, 35); 

    /* Write n bytes from the str buffer to the standard output */
    //write(STDOUT_FD, str, n);
    return 0;
}