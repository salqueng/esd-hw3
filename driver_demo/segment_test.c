#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char **argv) {
    int dev; int data;
    if (argc != 3) {
        printf("Usage: segment_test type val\n");
        return 1;
    }
    dev = open("/dev/segment", O_RDWR|O_SYNC);

    if (dev != -1) {
        switch (argv[1][0]) {
        case 's': //set flag
            ioctl(dev, 0 + atoi(argv[2]), NULL, NULL);
            break;
        case 'r': //start flag
            ioctl(dev, 2 + atoi(argv[2]), NULL, NULL);
            break;
        case 'w': //write
            data = atoi(argv[2]);
            write(dev, &data, 4);
            break;
        default:
            printf("Not supported!");
        }
        close(dev);
        return 0;
    } else {
        printf("Cannot open the device");
        exit(-11);
    }
}
