#!/bin/bash
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

#set -x

cleanup() {
    printf "Received ERR/INT....Exiting build.sh\n"
    exit 1
}

trap cleanup INT ERR

build_kernel_only () {
    if [ "${RECOMPILE_KERNEL}" == "1" ]; then
        echo "rebuilding build"
    else
        echo "re-using previous build"
    fi

    RECOMPILE_KERNEL=$RECOMPILE_KERNEL bash $PWD/build/kernel/build_trout_kernel.sh
}

build_platform_only () {
    source build/envsetup.sh
    lunch kalama_gvm_gy
    time m
}

build_ghgvm-pilsplitter () {

    pushd $PWD/device/common/kalama_gvm_gy  > /dev/null

    bash ghgvm-pilsplitter.sh

    popd > /dev/null
}

if ! build_kernel_only; then
    printf "Error building kernel...ending build\n"
    exit 1
fi

if ! build_platform_only; then
    printf "Error building platform...ending build\n"
    exit 1
fi

# Disabled until proper component are integrated in the manifest
# if ! build_ghgvm-pilsplitter; then
#     printf "Error building pilsplitter...ending build\n"
#     exit 1
# fi
