#include <stdio.h>
#include "mynet.h"
#include "klee/klee.h"


int main() {
    printf("Hello world!\n");
    char packet[1500];

    // get_packet(packet);
    klee_make_symbolic(packet, sizeof(packet), "packet");
    handle_packet(packet);

    return 0;
}