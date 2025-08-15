#!/bin/bash

KDIR="$(readlink -f .)"

# Clang (SD Clang)
CL_PATH="$HOME/toolchain/clangsd/bin"
GCC64_PATH="$HOME/toolchain/gcc64/bin"
export PATH="$GCC64_PATH:$CL_PATH:$PATH"

KERNEL_NAME="not_kernel-CYHTM-"

HOST_BUILD_ENV="ARCH=arm64 \
                CC=${CL_PATH}/clang \
                CROSS_COMPILE=$GCC64_PATH/aarch64-buildroot-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1"

KERNEL_MAKE_ENV="CONFIG_BUILD_ARM64_DT_OVERLAY=y"

KERNEL_BUILD_ENV="ARCH=arm64 \
                  CROSS_COMPILE=$GCC64_PATH/aarch64-buildroot-linux-gnu- \
                  LLVM=1 \
                  LLVM_IAS=1

OUT_DIR="$KDIR/out"
DTBO_OUT="$OUT_DIR/arch/arm64/boot"
DTB_OUT="$OUT_DIR/arch/arm64/boot/dts/vendor/qcom"
IMAGE="$OUT_DIR/arch/arm64/boot/Image"
ANYKERNEL_DIR="$KDIR/AnyKernel3/r8q"

echo "*****************************************"
echo "*****************************************"

rm -f "$OUT_DIR/arch/arm64/boot/Image"
rm -f "$ANYKERNEL_DIR/dtb"
rm -f "$OUT_DIR/dtbo.img"
rm -f .version .local
make O="$OUT_DIR" $HOST_BUILD_ENV not_defconfig

echo "*****************************************"
echo "*****************************************"

# Build Device Tree Blob//Overlay

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $KERNEL_BUILD_ENV \
     CC="${CL_PATH}/clang" dtbo.img

cp "$DTBO_OUT/dtbo.img" "$ANYKERNEL_DIR/dtbo.img"
cat "$DTB_OUT"/*.dtb > "$ANYKERNEL_DIR/dtb"

# Build Kernel Image

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $KERNEL_BUILD_ENV \
     CC="${CL_PATH}/clang" Image

echo "**Build outputs**"
ls "$OUT_DIR/arch/arm64/boot"
echo "**Build outputs**"

cp "$IMAGE" "$ANYKERNEL_DIR/Image"

# Package Kernel

cd "$ANYKERNEL_DIR" || exit 1
rm -f *.zip

zip -r9 "${KERNEL_NAME}$(date +"%Y%m%d")+r8q.zip" .

echo "The bomb has been planted."
