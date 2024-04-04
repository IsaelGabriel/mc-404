int read(int __fd, const void *__buf, int __n){
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
}

#define STDIN_FD  0
#define STDOUT_FD 1
#define BUFFER_SIZE 20

int pow(int a, int b) {
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
            *conv += (*(str + i) - 48) * pow(10, p);
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
            *conv += (*(str + i) - 48) * pow(16, p);
            p++;
        }else if (*(str + i) >= 65 && *(str + i) <= 70){
            *conv += (*(str + i) - 55) * pow(16, p);
            p++;
        }
        i--;
    }
}

void to_bin_str(int n, char* buf) {
    int neg = n < 0;
    if(neg) n *= -1;
    int bin_size = 0;

    char str[32];

    *buf = '0';
    *(buf + 1) = 'b';

    int i = 0;

    while(i < 32 && n != 0) {
        str[32-i] = (n % 2) + 48;
        n = n >> 1;
        i++;
    }

    for(int j = 0; j < i; j++) {
        *(buf + 2 + i - j) = str[32-j];
    }
    *(buf + 2 + i + 1) = '\n'; 
}

int main()
{
    char str[20];
    /* Read up to 20 bytes from the standard input into the str buffer */
    int n = read(STDIN_FD, str, 20);
    int conv = 0;

    if(str[0] == '0' && str[1] == 'x') {
        hex_conversion(&conv, str);
    }else {
        decimal_conversion(&conv, str);
    }

    char out[34];

    to_bin_str(conv, out);
    write(STDOUT_FD, out, 34); 

    /* Write n bytes from the str buffer to the standard output */
    write(STDOUT_FD, str, n);
    return 0;
}