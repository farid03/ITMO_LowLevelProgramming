#ifndef INPUT_FORMAT_H
#define INPUT_FORMAT_H

#include "../image_format/image_format.h"
#include <inttypes.h>
#include <stdio.h>

/*  deserializer   */
enum read_status  {
  READ_OK = 0,
  READ_INVALID_SIGNATURE,
  READ_INVALID_BITS,
  READ_INVALID_HEADER,
  READ_ERROR
  /* коды других ошибок  */
};

enum read_status from_bmp( FILE* in, struct image* img );

/*  serializer   */
enum  write_status  {
  WRITE_OK = 0,
  WRITE_ERROR
  /* коды других ошибок  */
};

enum write_status to_bmp( FILE* out, struct image const* img );

enum open_status {
  OPEN_OK = 0,
  OPEN_ERROR
};

enum open_status open_file( FILE** file, const char *path, const char *mode );

enum close_status {
  CLOSE_OK = 0,
  CLOSE_ERROR
};

enum close_status close_file( FILE* out );

size_t get_image_pixel_index(const uint64_t image_width, const size_t x, const size_t y);

#endif
