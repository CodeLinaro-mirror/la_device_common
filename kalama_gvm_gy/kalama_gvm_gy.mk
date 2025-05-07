$(shell rm WORKSPACE)
$(shell ln -s build/bazel/bazel.WORKSPACE WORKSPACE)

include device/google/trout/aosp_trout_arm64.mk

PRODUCT_NAME := kalama_gvm_gy
PRODUCT_DEVICE := kalama_gvm_gy
PRODUCT_BRAND := qti
PRODUCT_MODEL := kalama_gvm_gy for arm64
