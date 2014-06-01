#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main(int argc, char **argv) {
    int dev; int data;
    if (argc != 3) {
        printf("Usage: segcounter type val\n");
        return 1;
    }
    dev = open("/dev/segcounter", O_RDWR|O_SYNC);

    if (dev != -1) {
        switch (argv[1][0]) {
        case 'c': //counter start flag
            ioctl(dev, atoi(argv[2]), NULL, NULL);
            printf("START %d\n", atoi(argv[2]));
            break;
        case 's': //set flag
            ioctl(dev, 2, NULL, NULL);
            printf("SET %d\n", atoi(argv[2]));
            break;
        case 'r': //read flag
            read(dev, &data, 4);
            printf("READ %d\n", data);
            break;
        case 'w': //write
            data = atoi(argv[2]);
            write(dev, &data, 4);
            printf("WRITE %d\n", data);
            break;
        default:
            printf("Not supported!\n");
        }
        close(dev);
        return 0;
    } else {
        printf("Cannot open the device\n");
        exit(-11);
    }
}
