#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdlib.h>




static void invalid_op() {
    printf("Invalid operation\n");
    exit(1);
}

static void maybe_crash(int should_crash) {
    if (should_crash) {
        *( (volatile int*)NULL ) = 999;
    }
}

static bool password_is_correct(char* thepassword) {
    return memcmp(thepassword, "secret", sizeof("secret")) == 0;
}

void get_packet(char packet[1500]) {
    int rnd = open("/dev/random", O_RDONLY);
    if (read(rnd, packet, sizeof(*packet)) == -1) {
        perror("bad random read");
    }
}

void handle_packet(char packet[1500]) {
    switch((unsigned char)packet[0]) {
        case 0:
            invalid_op();
            break;
        case 1:
            maybe_crash(packet[3]);
            break;
        case 2:
            if (password_is_correct(packet + 1)) {
                printf("Correct password!\n");
            }
            break;
    }
}