#include "rotate_image.h"

struct image rotate( struct image const *source ) {
    struct image rotated_image = image_create(source->height, source->width);
    for(size_t y = 0; y < source->height; y++){
      for(size_t x = 0; x < source->width; x++){
        rotated_image.data[get_image_pixel_index(rotated_image.width, source->height - 1 - y, x)] = 
        source->data[get_image_pixel_index(source->width, x, y)];
      }
    }
    return rotated_image;
}
