#include <stdio.h>
#include <stdlib.h>

#define TAPE_SIZE 30000

void execute_brainfuck(const char *code) {
    char tape[TAPE_SIZE] = {0};
    char *ptr = tape;
    const char *pc = code;

    while (*pc) {
        switch (*pc) {
            case '>':
                ++ptr;
                break;
            case '<':
                --ptr;
                break;
            case '+':
                ++(*ptr);
                break;
            case '-':
                --(*ptr);
                break;
            case '.':
                putchar(*ptr);
                break;
            case ',':
                *ptr = getchar();
                break;
            case '[':
                if (*ptr == 0) {
                    int loops = 1;
                    while (loops > 0) {
                        ++pc;
                        if (*pc == '[') ++loops;
                        if (*pc == ']') --loops;
                    }
                }
                break;
            case ']':
                if (*ptr != 0) {
                    int loops = 1;
                    while (loops > 0) {
                        --pc;
                        if (*pc == '[') --loops;
                        if (*pc == ']') ++loops;
                    }
                }
                break;
            default:
                break;
        }
        ++pc;
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s \"<brainfuck code>\"\n", argv[0]);
        return 1;
    }

    execute_brainfuck(argv[1]);

    return 0;
}
