#include "image_format.h"
#include <malloc.h>

struct image image_create(uint64_t width, uint64_t height) {
    return (struct image) { .width = width, .height = height, .data = malloc( width * height * sizeof(struct pixel)) };
}

void image_destroy(struct image* const image) {
    free(image->data);
}
