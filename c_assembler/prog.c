#include <stdio.h>
#include <stdint.h>

struct random_holder {
    uint32_t state;
    uint32_t (*handler)(uint32_t);
};

extern int demo();
extern uint32_t xorshift(uint32_t state);

int main() {
    struct random_holder rand = {
        .state = 5,
        .handler = xorshift
    };

    return demo(&rand);
}