#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/types.h>
#include <linux/fcntl.h>
#include <linux/ioport.h>
#include <linux/delay.h>

#include <asm/fcntl.h>
#include <asm/uaccess.h>
#include <asm/io.h>

#define DRIVER_AUTHOR "TEAM5"
#define DRIVER_DESC "7-Segment Counter"

#define SEGMENT_MAJOR 240
#define SEGMENT_NAME "SEGMENT"
#define SEGMENT_MODULE_VERSION "SEGMENT COUNTER v0.1"

#define SEGMENT_ADDRESS_DATA 0x88000030
#define SEGMENT_ADDRESS_DATA_RANGE 0x100

#define COUNTER_ADDRESS_START 0x88000034
#define COUNTER_ADDRESS_START_RANGE 0x1

#define COUNTER_ADDRESS_SET 0x88000035
#define COUNTER_ADDRESS_SET_RANGE 0x1

#define MODE_0_COUNTER_STOP 0x0
#define MODE_1_COUNTER_START 0x1
#define MODE_2_COUNTER_SET_DISABLE 0x2
#define MODE_3_COUNTER_SET_ENABLE 0x3

static unsigned int segment_usage = 0;
static unsigned int *segment_data;
static unsigned char *counter_start;
static unsigned char *counter_set;

int segment_open(struct inode *inode, struct file *flip) {
    if (segment_usage !=0) return -EBUSY;

    segment_data = ioremap(SEGMENT_ADDRESS_DATA, SEGMENT_ADDRESS_DATA_RANGE);
    counter_start = ioremap(COUNTER_ADDRESS_START, COUNTER_ADDRESS_START_RANGE);
    counter_set = ioremap(COUNTER_ADDRESS_SET, COUNTER_ADDRESS_SET_RANGE);

    if (!check_mem_region((unsigned long)segment_data, SEGMENT_ADDRESS_DATA_RANGE) &&
        !check_mem_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE) &&
        !check_mem_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE)) {
        request_region((unsigned long)segment_data, SEGMENT_ADDRESS_DATA_RANGE, SEGMENT_NAME);
        request_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE, SEGMENT_NAME);
        request_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE, SEGMENT_NAME);
    } else {
        printk("Driver: Unable To Register This\n");
    }

    segment_usage = 1;
    return 0;
}

int segment_release(struct inode *inode, struct file *flip) {
    iounmap(segment_data);
    iounmap(counter_start);
    iounmap(counter_set);

    release_region((unsigned long)segment_data, SEGMENT_ADDRESS_DATA_RANGE);
    release_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE);
    release_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE);

    segment_usage = 0;
    return 0;
}

ssize_t segment_write(struct file *inode, const char *gdata, size_t length, loff_t *off_what) {
    unsigned int num, ret;

    ret = copy_from_user(&num, gdata, 4);

    *segment_data = num;

    return length;
}

static int segment_ioctl(struct inode *inode, struct file *flip, unsigned int cmd, unsigned long arg) {
    switch (cmd) {
    case MODE_0_COUNTER_STOP:
        *counter_start = 0x00;
        break;
    case MODE_1_COUNTER_START:
        *counter_start = 0x01;
        break;
    case MODE_2_COUNTER_SET_DISABLE:
        *counter_set = 0x00;
        break;
    case MODE_3_COUNTER_SET_ENABLE:
        *counter_set =0x01;
        break;
    default:
        return -EINVAL;
    }
    return 0;
}

struct file_operations segment_fops = {
    .owner   = THIS_MODULE,
    .open    = segment_open,
    .write   = segment_write,
    .release = segment_release,
    .ioctl   = segment_ioctl
};

int segment_init(void) {
    int result;

    result = register_chrdev(SEGMENT_MAJOR, SEGMENT_NAME, &segment_fops);
    if (result < 0) {
        printk(KERN_WARNING"Can't get any major\n");
        return result;
    }

    printk(KERN_INFO"Init Module, 7-Segment Major Number: %d\n", SEGMENT_MAJOR);
    return 0;
}

int segment_exit(void) {
    unregister_chrdev(SEGMENT_MAJOR, SEGMENT_NAME);

    printk("driver: %s DRIVER EXIT\n", SEGMENT_NAME);

    return 0;
}

module_init(segment_init);

module_exit(segment_exit);

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("Dual BSD/GPL");
