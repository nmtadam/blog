I enjoy writing open source software targeted at emerging storage and memory hardware. In particular, I have an affinity for operating systems and we have a well known open source operating system available, Linux!. When I started my kernel development journey I enjoyed running the kernel on bare metal. This worked for awhile, but as I started working on larger server class systems I realized booting a server can be quite time consuming. To remedy this situation I chatted with other kernel developers and they recommended using QEMU for kernel development. 

The following [link](https://www.collabora.com/news-and-blog/blog/2017/01/16/setting-up-qemu-kvm-for-kernel-development/) got me started. This was great and KVM made booting up a newly compiled kernel extremely quick, but the next step was to figure out how to pass nvme SSDs to QEMU guests. This is how I got started with VFIO Passthrough. VFIO passthrough allows one to pass hardware to guests. This gives one the ability to write kernel software for emerging HW without needing to reboot a system. In this blog post I will detail how to pass HW to a guest including scripts one can use.

# Prerequisites

You will need iommu support. I am using an x86_64 server so see the following grub option.

```
nmtadam@bgt-140510-bm01:~$ cat /etc/default/grub | grep iommu
GRUB_CMDLINE_LINUX="intel_iommu=on"
```

In addition, be sure that the vfio-pci module is present on your system.

# Finding a NVME SSD to pass through

The first step in passing HW to a guest is identifying the HW you wish to pass. 

```
nmtadam@bgt-140510-bm01:~$ lspci | grep "Non"
db:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller PM173X
```

In this example I list the NVMe SSDs on my host system. I am interested in passing the SSD listed to qemu. The next step is to get some information we will need in order to bind the device to vfio driver.

```
nmtadam@bgt-140510-bm01:~$ sudo lspci -n -s db:00.0
db:00.0 0108: 144d:a824
```

This output shows you the vendor ID and device code.

# Module Binding

The nvme driver typically binds to NVMe SSDs (surprise!), but we need to get the vfio driver to bind to the device. We will need to unbind the device from the nvme driver.

```
nmtadam@bgt-140510-bm01:~$ echo 0000:db:00.0 | sudo tee /sys/bus/pci/devices/0000\:db\:00.0/driver/unbind
```

After that we must bind the device to the vfio driver

```
nmtadam@bgt-140510-bm01:~$ echo 144d a824 | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
144d a824
```

# QEMU config

The last step is to pass the proper options to qemu

`-device vfio-pci,host=db:00.0
`

# Run QEMU

The last step is to run qemu with your newly passed device. 

Here is the output of lspci in my guest

```
root@bgt-140510-bm01:~# lspci | grep "Non"
00:07.0 Non-Volatile memory controller: Samsung Electronics Co Ltd Device a824
```




