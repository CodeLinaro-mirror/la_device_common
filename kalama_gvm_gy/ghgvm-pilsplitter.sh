#!/bin/sh

# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear
#

###############################################################################################
# This is the script to generate split PIL bins for Gunyah hypervisor                         #
# Need to run this script from the device/qcom/kalama_gvm_gy directory                         #
# Before running this script full android build should be done and below directory is present #
# device/qcom/msmnile-kernel with dtbs and Image present in the directory                     #
###############################################################################################

PWD=`pwd`;
#echo "$PWD"
PIL_PATH="$PWD"
#echo "$PIL_PATH"
ROOT_DIR="$PWD/../../../"
#echo "$ROOT_DIR"
MKDTBOIMGPY_PATH=$ROOT_DIR/system/libufdt/utils/src
#echo "$MKDTBOIMGPY_PATH"
IMG_PATH="$PWD/../kalama-kernel"
#echo "$IMG_PATH"
cd $IMG_PATH
OUTPATH="$PWD/../../../out/target/product/kalama_gvm_gy"
#echo "$OUTPATH"
if [[ -z "${QCPATH}" ]]; then
	echo "ERROR: QCPATH is empty and must be set for all vendor references"
	exit 1
fi
#echo "$QCPATH"
SECURITY_PROFILE_PATH="$QCPATH/securemsm/security_profiles"
cd $OUTPATH
# Create scratch folder to copy the images for creating split PIL images
if [ -d "$OUTPATH/scratch" ]
then
	rm -Rf scratch
fi
mkdir scratch

# Create dtb.img with DT table structure
# ref: https://source.android.com/docs/core/architecture/dto/partitions
DTB_FILE_LIST=$(find $IMG_PATH/dtbs -name "*.dtb" | sort)
if [ -z "${DTB_FILE_LIST}" ]; then
	echo "No *.dtb files found in $IMG_PATH/dtbs"
	exit 1
else
	echo "Creating the dtb.img from $DTB_FILE_LIST"
	python3 $MKDTBOIMGPY_PATH/mkdtboimg.py create $OUTPATH/scratch/dtb.img $DTB_FILE_LIST
fi

cp $IMG_PATH/Image $OUTPATH/scratch/
cp $OUTPATH/ramdisk.img $OUTPATH/scratch/
cp $QCPATH/guest-bootloader/FVMAIN_COMPACT.Fv $OUTPATH/scratch/
cd $OUTPATH/scratch

python3 $PIL_PATH/image_header.py trustedvm-boot.elf Image,0x0 \
	dtb.img,0x3000000 ramdisk.img,0x3100000 --32

$QCPATH/sectools/Linux/sectools secure-image trustedvm-boot.elf \
	--image-id ABL \
	--security-profile $SECURITY_PROFILE_PATH/kailua_tz_security_profile.xml \
	--sign --signing-mode TEST \
	--outfile trustedvm_signed-boot.elf

$QCPATH/sectools/Linux/sectools secure-image trustedvm_signed-boot.elf --inspect

if [ -d "$OUTPATH/scratch/boot" ]
then
	rm -Rf boot
fi
mkdir boot
python3 $PIL_PATH/pil-splitter.py trustedvm_signed-boot.elf boot/trustedvm

echo "Creating the vm-boot.img"
$ROOT_DIR/out/host/linux-x86/bin/mkuserimg_mke2fs $OUTPATH/scratch/boot \
	$OUTPATH/vm-boot.img ext4 / 70000000
