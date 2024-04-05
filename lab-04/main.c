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
        }
        i--;
    }
}

void to_bin_str(int n, char* buf) {
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
}

void to_dec_str(int n, char* out) {
    int pseudo_neg = (n >> 31) & 1;
    //int true_neg = n < 0;
    int nn = 0;
    int start_n = 0; 
    if(pseudo_neg) {
        start_n = 1;
        n = ~(n - 1);
        out[0] = '-';
    }
    nn = n;


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

    /*char out_bin[35];

    to_bin_str(conv, out_bin);
    */
    char out_dec[11];

    to_dec_str(conv, out_dec);

    printf("%s\n", out_dec);
    //write(STDOUT_FD, out, 35); 

    /* Write n bytes from the str buffer to the standard output */
    //write(STDOUT_FD, str, n);
    return 0;
}