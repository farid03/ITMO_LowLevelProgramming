#include "bmp_header.h"
#include "input_format.h"

static inline size_t get_padding(const uint64_t width) {
    return (!width % 4 == 0) ? 4 - ((width * sizeof(struct pixel)) % 4) : 0;;
}

inline size_t get_image_pixel_index(const uint64_t image_width, const size_t x, const size_t y) {
    return y * image_width + x;
}

enum read_status from_bmp(FILE *in, struct image *img) {
    struct bmp_header bmp_image_header = {0};
    if (!fread(&bmp_image_header, sizeof(struct bmp_header), 1, in)) {
        return READ_INVALID_HEADER;
    }

    if (bmp_image_header.biBitCount != 24) {
        return READ_INVALID_BITS;
    }

    *img = image_create(bmp_image_header.biWidth, bmp_image_header.biHeight);

    size_t padding = get_padding(img->width);;

    for (size_t y = 0; y < img->height; y++) {
        for (size_t x = 0; x < img->width; x++) {
            if (fread(&(img->data[get_image_pixel_index(img->width, x, y)]), sizeof(struct pixel), 1, in) != 1) {
                return READ_ERROR;
            } // FILE *stream, long offset, int origin
        }
        if (fseek(in, padding, SEEK_CUR)) {
            return READ_ERROR;
        }
    }

    return READ_OK;
}

enum write_status to_bmp(FILE *out, struct image const *img) {
    size_t padding = get_padding(img->width);
    struct bmp_header bmp_image_header = (struct bmp_header) {
            .bfType = 0x4D42,
            .bOffBits = 54,
            .biSize = 40,
            .biWidth = img->width,
            .biHeight = img->height,
            .biPlanes = 1,
            .biBitCount = 3 * 8,
            .biCompression = 0,
            .biSizeImage = (img->width * sizeof(struct pixel) + padding) * img->height,
            .bfileSize = (img->width * sizeof(struct pixel) + padding) * img->height + sizeof(struct bmp_header)
    };


    if (!fwrite(&bmp_image_header, sizeof(bmpHeader), 1, out)) {
        return WRITE_ERROR;
    }

    if (fseek(out, bmp_image_header.bOffBits, SEEK_SET)) {
        return WRITE_ERROR;
    }

    struct pixel pixel;

    if (img->data == NULL) {
        return WRITE_ERROR;
    }

    for (size_t y = 0; y < img->height; y++) {
        for (size_t x = 0; x < img->width; x++) {
            pixel = img->data[get_image_pixel_index(img->width, x, y)];
            if (fwrite(&pixel, sizeof(struct pixel), 1, out) != 1) {
                return WRITE_ERROR;
            }
        }
        if (fwrite(&pixel, sizeof(unsigned char), padding, out) != padding) {
            return WRITE_ERROR;
        }
    }

    return WRITE_OK;

}

enum open_status open_file(FILE **file, const char *path, const char *mode) {
    *file = fopen(path, mode);
    if (*file == NULL) {
        return OPEN_ERROR;
    }
    return OPEN_OK;
}

enum close_status close_file(FILE *out) {
    if (fclose(out) == EOF) {
        return CLOSE_ERROR;
    }
    return CLOSE_OK;
}
