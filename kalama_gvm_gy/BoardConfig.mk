SYSTEM_DLKM_SRC := device/common/kalama-kernel
TARGET_KERNEL_PATH := $(SYSTEM_DLKM_SRC)/Image
KERNEL_MODULES_PATH := $(SYSTEM_DLKM_SRC)

-include device/google/trout/trout_arm64/BoardConfig.mk

