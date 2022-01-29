#include "image_format/image_format.h"
#include "input_format/input_format.h"
#include "transform/rotate_image.h"
#include <stdio.h>

int main( int argc, char** argv ) {
//    (void) argc; (void) argv; // supress 'unused parameters' warning

    if (argc != 3) {
        printf("Invalid input arguments!");
        return 1;
    }
 
    FILE *source_file = {0};
    struct image source_image = {0};

    if (open_file(&source_file, argv[1], "r") == OPEN_ERROR) {
        printf("Error opening source image file!");
        image_destroy(&source_image);
        return 2;
    }
    if (from_bmp(source_file, &source_image) != READ_OK) {
        printf("Error reading source image file!");
        image_destroy(&source_image);
        return 3;
    }
    if (close_file(source_file) == CLOSE_ERROR) {
        printf("Error closing source file!");
        image_destroy(&source_image);
        return 4;
    }
    struct image rotated_image = rotate(&source_image);
    image_destroy(&source_image);
    FILE *rotated_image_file = {0};

    if (open_file((FILE **) &rotated_image_file, argv[2], "w")) {
        printf("Error opening output image file!");
        image_destroy(&rotated_image);
        return 5;
    }
    if (to_bmp(rotated_image_file, &rotated_image) == WRITE_ERROR) {
        printf("Error writing output file!");
        image_destroy(&rotated_image);
        return 6;
    }
    if (close_file((FILE *) rotated_image_file) == CLOSE_ERROR) {
        printf("Error closing output file!");
        image_destroy(&rotated_image);
        return 7;
    }
    image_destroy(&rotated_image);

    return 0;
}

