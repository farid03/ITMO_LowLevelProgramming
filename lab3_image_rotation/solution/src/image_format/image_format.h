#ifndef IMAGE_FORMAT_H
#define IMAGE_FORMAT_H

#include "stddef.h"
#include  <stdint.h>

struct image {
  uint64_t width, height;
  struct pixel* data;
};

struct __attribute__((packed)) pixel {
    uint8_t b, g, r;
};

struct image image_create(uint64_t width, uint64_t height);

void image_destroy(struct image* const image);

#endif
