#include "header/util.h"

void memcpy(void* src, void* dest, int16 no_bytes) {
    int i = 0;
    for (; i < no_bytes; i++)
        *((char*)(dest + i)) = *((char*)(src + i));
}

char itoa(int num) {
    //quite a simple one but get's the job done
    return '0' + num;
}

void free(void* src) {
    *((char*)src) = (char*)0x0;
    //this is the best I can do for now
    // I know that free doesn't work like this
}