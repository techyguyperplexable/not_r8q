#!/bin/bash
LLVM_PATH="/home/skye/bomb/clang/bin/"
SD_PATH="/home/skye/bomb/clangsd/bin/"

KERNEL_NAME="not_kernel-ACID🧪-"

HOST_BUILD_ENV="ARCH=arm64 \
                CC=${SD_PATH}clang \
                CROSS_COMPILE=${SD_PATH}aarch64-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1 \
                PATH=$LLVM_PATH:$SD_PATH:$PATH"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

KERNEL_BUILD_ENV="ARCH=arm64 \
                  CROSS_COMPILE=${SD_PATH}aarch64-linux-gnu- \
                  LLVM=1 \
                  LLVM_IAS=1 \
                  PATH=$LLVM_PATH:$SD_PATH:$PATH"

DTBO_OUT="/home/skye/bomb/out/arch/arm64/boot"
DTB_OUT="/home/skye/bomb/out/arch/arm64/boot/dts/vendor/qcom"
IMAGE="/home/skye/bomb/out/arch/arm64/boot/Image"
OUT_DIR="/home/skye/bomb/out"
ANYKERNEL_DIR="/home/skye/bomb/AnyKernel3/r8q"

echo "*****************************************"
echo "*****************************************"

rm -rf "$OUT_DIR/arch/arm64/boot/Image"
rm -rf "$ANYKERNEL_DIR/dtb"
rm -rf "$OUT_DIR/dtbo.img"
rm -rf .version .local
make O="$OUT_DIR" $HOST_BUILD_ENV not_defconfig

echo "*****************************************"
echo "*****************************************"

# Build Device Tree Blob//Overlay

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $KERNEL_BUILD_ENV \
     CC="${SD_PATH}clang --target=aarch64-linux-gnu" dtbo.img

cp "$DTBO_OUT/dtbo.img" "$ANYKERNEL_DIR/dtbo.img"
cat "$DTB_OUT"/*.dtb > "$ANYKERNEL_DIR/dtb"

# Build Kernel Image

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $KERNEL_BUILD_ENV \
     CC="${SD_PATH}clang --target=aarch64-linux-gnu" Image

echo "**Build outputs**"
ls "$OUT_DIR/arch/arm64/boot"
echo "**Build outputs**"

cp "$IMAGE" "$ANYKERNEL_DIR/Image"

# Package Kernel

cd "$ANYKERNEL_DIR" || exit 1
rm -f *.zip

zip -r9 "${KERNEL_NAME}$(date +"%Y%m%d")+r8q.zip" .

echo "The bomb has been planted."

