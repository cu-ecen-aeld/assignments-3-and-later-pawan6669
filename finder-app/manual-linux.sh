#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

HOME=$(pwd)
OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
PATH=/home/pawan/toolchains/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin:${PATH}

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

if [ ! -d ${OUTDIR} ]; then
	echo "The output directory could not be created. Exiting"
	exit 1
fi

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    	#Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
# if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
#     cd linux-stable
#     echo "Checking out version ${KERNEL_VERSION}"
#     git checkout ${KERNEL_VERSION}
	
#     echo "Checked out the kernel. Cleaning it"
#     # TODO: Add your kernel build steps here
#     make -j4 ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} mrproper

#     echo  "Configuring the kernel"
#     make -j4 ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} defconfig

#     echo  "Building the kernel Image"
#     make -j4 ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE} all

#     echo "Compiling the kernel modules"
#     make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

#     echo "Compiling the device tree"
#     make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

# fi

echo "Adding the Image in outdir"

cp -f ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image  ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
# if [ -d "${OUTDIR}/rootfs" ]
# then
# 	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
#     sudo rm  -rf ${OUTDIR}/rootfs
# fi

# # TODO: Create necessary base directories
# mkdir -p ${OUTDIR}/rootfs
# cd ${OUTDIR}/rootfs
# mkdir -p  bin dev etc home lib lib64 proc sbin sys tmp usr var
# mkdir -p  usr/bin  usr/lib/  usr/sbin
# mkdir -p  var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    echo "BUsyBox is not present. Building it now"
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
else
    echo "Busybox is present. Going to it"
    cd busybox
fi

# TODO: Make and install busybox
echo "Installing BusyBox"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


echo "Library dependencies"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp -f /home/pawan/toolchains/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6  ${OUTDIR}/rootfs/usr/lib/ 
cp -f /home/pawan/toolchains/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2  ${OUTDIR}/rootfs/usr/lib/
cp -f /home/pawan/toolchains/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6  ${OUTDIR}/rootfs/usr/lib/
cp -f /home/pawan/toolchains/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1  ${OUTDIR}/rootfs/usr/lib/


# TODO: Make device nodes
cd ${OUTDIR}/rootfs
#mknod -m 666 dev/null c 1 5
#mknod -m 666 dev/console c 1 5


# TODO: Clean and build the writer utility
cd $HOME
make clean
make all


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp -f finder-app/writer  ${OUTDIR}/rootfs/
cp -f finder-app/finder.sh  ${OUTDIR}/rootfs/
cp -f finder-app/finder-test.sh ${OUTDIR}/rootfs/
cp -f conf/username.txt  ${OUTDIR}/rootfs/
cp -f conf/assignment.txt ${OUTDIR}/rootfs/
cp -f finder-app/autorun-qemu.sh  ${OUTDIR}/rootfs/


cd ${OUTDIR}
# TODO: Chown the root directory
chown root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f initramfs.cpio