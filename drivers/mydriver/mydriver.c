#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

#include "mydriver.h"

static int __init mydriver_init(void)
{
    pr_info("%s: module loaded\n", MYDRIVER_NAME);
    return 0;
}

static void __exit mydriver_exit(void)
{
    pr_info("%s: module unloaded\n", MYDRIVER_NAME);
}

module_init(mydriver_init);
module_exit(mydriver_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("A70Q Kernel");
MODULE_DESCRIPTION("A70Q loadable kernel module test");
MODULE_VERSION("1.0");
