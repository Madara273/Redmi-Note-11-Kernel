/*
 * CAN mode switch interface.
 *
 * Provides a sysfs interface (/sys/kernel/can_switch/can_mode) to dynamically
 * switch between two CAN line discipline drivers:
 *   - MODE_SLCAN (0)
 *   - MODE_HLCAN (1)
 *
 * Writing a new mode value stops the currently active driver,
 * initializes the selected one, and updates the active CAN mode.
 * If initialization fails, the previous mode is restored.
 *
 * Initialized at an early stage of kernel subsystem initialization,
 * allowing mode switching at runtime without rebooting.
 *
 * Author: Madara 273 <ravenhoxs@gmail.com>
 */

#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/mutex.h>

#define MODE_SLCAN	0
#define MODE_HLCAN	1

int can_mode = MODE_SLCAN;
EXPORT_SYMBOL(can_mode);

extern void slcan_do_exit(void);
extern int slcan_do_init(void);
extern void hlcan_do_exit(void);
extern int hlcan_do_init(void);

static DEFINE_MUTEX(can_mode_lock);
static struct kobject *can_kobj;

/*
 * Show the current CAN mode via sysfs.
 */
static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%d\n", can_mode);
}

/*
 * Handle writing a new CAN mode via sysfs.
 * Valid values: 0 = SLCAN, 1 = HLCAN.
 */
static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
	int val;
	int ret_init;

	if (kstrtoint(buf, 10, &val) != 0 || (val != MODE_SLCAN && val != MODE_HLCAN))
		return -EINVAL;

	mutex_lock(&can_mode_lock);

	if (val == can_mode) {
		mutex_unlock(&can_mode_lock);
		return count;
	}

	/* Shutdown the currently active mode */
	if (can_mode == MODE_SLCAN)
		slcan_do_exit();
	else
		hlcan_do_exit();

	/* Initialize the new mode */
	if (val == MODE_SLCAN)
		ret_init = slcan_do_init();
	else
		ret_init = hlcan_do_init();

	if (ret_init != 0) {
		int restore_ret;

		pr_err("CAN mode switch failed to init mode %d\n", val);

		/* Restore the previous mode if switching failed */
		if (can_mode == MODE_SLCAN)
			restore_ret = slcan_do_init();
		else
			restore_ret = hlcan_do_init();

		if (restore_ret != 0)
			pr_err("CAN mode restore failed for mode %d\n", can_mode);

		mutex_unlock(&can_mode_lock);
		return -EIO;
	}

	can_mode = val;
	pr_info("CAN mode switched to %d\n", can_mode);

	mutex_unlock(&can_mode_lock);
	return count;
}

static struct kobj_attribute mode_attr = __ATTR(can_mode, 0664, mode_show, mode_store);

/*
 * Initialize the sysfs interface for CAN mode switching.
 */
static int __init can_switch_init(void)
{
	int ret;

	can_kobj = kobject_create_and_add("can_switch", kernel_kobj);
	if (!can_kobj)
		return -ENOMEM;

	ret = sysfs_create_file(can_kobj, &mode_attr.attr);
	if (ret) {
		kobject_put(can_kobj);
		return ret;
	}

	pr_info("CAN switch sysfs interface initialized\n");
	return 0;
}

subsys_initcall(can_switch_init);
