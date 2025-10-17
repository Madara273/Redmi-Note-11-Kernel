# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause

obj-$(CONFIG_RTW88_CORE)	+= rtw88.o
rtw88-y	+= main.o \
	led.o \
	mac80211.o \
	util.o \
	debug.o \
	tx.o \
	rx.o \
	mac.o \
	phy.o \
	coex.o \
	efuse.o \
	fw.o \
	ps.o \
	sec.o \
	bf.o \
	regd.o \
	sar.o

rtw88-$(CONFIG_PM)		+= wow.o

obj-$(CONFIG_RTW88_8703B)	+= rtw8703b.o rtw8703b_tables.o
obj-$(CONFIG_RTW88_8723CS)	+= rtw8723cs.o
obj-$(CONFIG_RTW88_8723D)	+= rtw8723d.o rtw8723d_table.o
obj-$(CONFIG_RTW88_8723DE)	+= rtw8723de.o
obj-$(CONFIG_RTW88_8723DS)	+= rtw8723ds.o
obj-$(CONFIG_RTW88_8723DU)	+= rtw8723du.o
obj-$(CONFIG_RTW88_8723X)	+= rtw8723x.o

obj-$(CONFIG_RTW88_8812AU)	+= rtw8812au.o
obj-$(CONFIG_RTW88_8821A)	+= rtw8821a.o rtw8821a_table.o
obj-$(CONFIG_RTW88_8812A)	+= rtw8812a.o rtw8812a_table.o
obj-$(CONFIG_RTW88_88XXA)	+= rtw88xxa.o
obj-$(CONFIG_RTW88_8821AU)	+= rtw8821au.o
obj-$(CONFIG_RTW88_8814A)	+= rtw8814a.o rtw8814a_table.o
obj-$(CONFIG_RTW88_8814AU)	+= rtw8814au.o
obj-$(CONFIG_RTW88_8814AE)	+= rtw8814ae.o

obj-$(CONFIG_RTW88_8821C)	+= rtw8821c.o rtw8821c_table.o
obj-$(CONFIG_RTW88_8821CE)	+= rtw8821ce.o
obj-$(CONFIG_RTW88_8821CS)	+= rtw8821cs.o
obj-$(CONFIG_RTW88_8821CU)	+= rtw8821cu.o

obj-$(CONFIG_RTW88_8822B)	+= rtw8822b.o rtw8822b_table.o
obj-$(CONFIG_RTW88_8822BE)	+= rtw8822be.o
obj-$(CONFIG_RTW88_8822BS)	+= rtw8822bs.o
obj-$(CONFIG_RTW88_8822BU)	+= rtw8822bu.o
obj-$(CONFIG_RTW88_8822C)	+= rtw8822c.o rtw8822c_table.o
obj-$(CONFIG_RTW88_8822CE)	+= rtw8822ce.o
obj-$(CONFIG_RTW88_8822CS)	+= rtw8822cs.o
obj-$(CONFIG_RTW88_8822CU)	+= rtw8822cu.o

obj-$(CONFIG_RTW88_PCI)		+= rtwpci.o
rtwpci-objs			:= pci.o

obj-$(CONFIG_RTW88_SDIO)	+= rtwsdio.o
rtwsdio-objs			:= sdio.o

obj-$(CONFIG_RTW88_USB)		+= rtwusb.o
rtwusb-objs			:= usb.o
