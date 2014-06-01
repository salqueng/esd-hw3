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

#define SEGCOUNTER_MAJOR 240
#define SEGCOUNTER_NAME "SEGCOUNTER"
#define SEGCOUNTER_MODULE_VERSION "SEGMENT COUNTER v0.1"

#define COUNTER_ADDRESS_DATA_INPUT 0x88000054
#define COUNTER_ADDRESS_DATA_OUTPUT 0x8800058
#define COUNTER_ADDRESS_DATA_RANGE 0x100

#define COUNTER_ADDRESS_START 0x88000035
#define COUNTER_ADDRESS_START_RANGE 0x1

#define COUNTER_ADDRESS_SET 0x88000034
#define COUNTER_ADDRESS_SET_RANGE 0x1

#define MODE_0_COUNTER_STOP 0x0
#define MODE_1_COUNTER_START 0x1
#define MODE_2_COUNTER_SET_DISABLE 0x2
#define MODE_3_COUNTER_SET_ENABLE 0x3

static unsigned int segcounter_usage = 0;
static unsigned int *counter_data_input;
static unsigned int *counter_data_output;
static unsigned char *counter_start;
static unsigned char *counter_set;

int segcounter_open(struct inode *inode, struct file *flip) {
    if (segcounter_usage !=0) return -EBUSY;

    counter_data_input = ioremap(COUNTER_ADDRESS_DATA_INPUT, COUNTER_ADDRESS_DATA_RANGE);
    counter_data_output = ioremap(COUNTER_ADDRESS_DATA_OUTPUT, COUNTER_ADDRESS_DATA_RANGE);
    counter_start = ioremap(COUNTER_ADDRESS_START, COUNTER_ADDRESS_START_RANGE);
    counter_set = ioremap(COUNTER_ADDRESS_SET, COUNTER_ADDRESS_SET_RANGE);

    if (!check_mem_region((unsigned long)counter_data_input, COUNTER_ADDRESS_DATA_RANGE) &&
        !check_mem_region((unsigned long)counter_data_output, COUNTER_ADDRESS_DATA_RANGE) &&
        !check_mem_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE) &&
        !check_mem_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE)) {
        request_region((unsigned long)counter_data_input, COUNTER_ADDRESS_DATA_RANGE, SEGCOUNTER_NAME);
        request_region((unsigned long)counter_data_output, COUNTER_ADDRESS_DATA_RANGE, SEGCOUNTER_NAME);
        request_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE, SEGCOUNTER_NAME);
        request_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE, SEGCOUNTER_NAME);
    } else {
        printk("Driver: Unable To Register This\n");
    }

    segcounter_usage = 1;
    return 0;
}

int segcounter_release(struct inode *inode, struct file *flip) {
    iounmap(counter_data_input);
    iounmap(counter_data_output);
    iounmap(counter_start);
    iounmap(counter_set);

    release_region((unsigned long)counter_data_input, COUNTER_ADDRESS_DATA_RANGE);
    release_region((unsigned long)counter_data_output, COUNTER_ADDRESS_DATA_RANGE);
    release_region((unsigned long)counter_start, COUNTER_ADDRESS_START_RANGE);
    release_region((unsigned long)counter_set, COUNTER_ADDRESS_SET_RANGE);

    segcounter_usage = 0;
    return 0;
}

ssize_t segcounter_read(struct file *inode, const char *gdata, size_t length, loff_t *off_what) {
    int ret;
    ret = copy_to_user(gdata, counter_data_output, 4);
    if (ret < 0) {
        return -1;
    }
    print_current_status();
    return length;
}

ssize_t segcounter_write(struct file *inode, const char *gdata, size_t length, loff_t *off_what) {
    unsigned int num, ret;

    ret = copy_from_user(&num, gdata, 4);

    *counter_data_input = num;

    print_current_status();
    return length;
}

static int segcounter_ioctl(struct inode *inode, struct file *flip, unsigned int cmd, unsigned long arg) {
    printk("What the fuck cmd: %d\n", cmd);
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
        *counter_set = 0x01;
        break;
    default:
        return -EINVAL;
    }
    *counter_data_input = *counter_data_input + 1;
    mdelay(100);
    print_current_status();
    return 0;
}

struct file_operations segcounter_fops = {
    .owner   = THIS_MODULE,
    .open    = segcounter_open,
    .read    = segcounter_read,
    .write   = segcounter_write,
    .release = segcounter_release,
    .ioctl   = segcounter_ioctl
};

int segcounter_init(void) {
    int result;

    result = register_chrdev(SEGCOUNTER_MAJOR, SEGCOUNTER_NAME,  &segcounter_fops);
    if (result < 0) {
        printk(KERN_WARNING"Can't get any major\n");
        return result;
    }

    printk(KERN_INFO"Init Module, 7-Segment Major Number: %d\n", SEGCOUNTER_MAJOR);
    return 0;
}

int segcounter_exit(void) {
    unregister_chrdev(SEGCOUNTER_MAJOR, SEGCOUNTER_NAME);

    printk("driver: %s DRIVER EXIT\n", SEGCOUNTER_NAME);

    return 0;
}

void print_current_status(void) {
    printk("driver: %s OUTPUT: %d\n", SEGCOUNTER_NAME, *counter_data_output);
    printk("driver: %s INPUT: %d\n", SEGCOUNTER_NAME, *counter_data_input);
    printk("driver: %s SET: %d\n", SEGCOUNTER_NAME, *counter_set);
    printk("driver: %s START: %d\n", SEGCOUNTER_NAME, *counter_start);
}

module_init(segcounter_init);

module_exit(segcounter_exit);

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("Dual BSD/GPL");
