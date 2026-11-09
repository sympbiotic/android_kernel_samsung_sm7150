#!/bin/sh

KERNEL_DIR=$(pwd)
DEVICE="$1"
DEVICE2="$2"
SOC="$3"

build_kernel() {
    echo "-----------------------------------------------"
    echo "Beginning kernel compilation for $DEVICE..."
    echo "-----------------------------------------------"

    export ARCH=arm64
    mkdir out

    export PATH=$(pwd)/llvm-22/bin:$PATH

    KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"
    BUILD_VAR="-j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"

    cat arch/arm64/configs/sdmmagpie_defconfig arch/arm64/configs/$DEVICE.config > arch/arm64/configs/temp_defconfig

    echo "
CONFIG_THINLTO=y
# CONFIG_LTO_NONE is not set
CONFIG_LTO_CLANG=y
    " >> arch/arm64/configs/temp_defconfig

    make $BUILD_VAR temp_defconfig
    rm arch/arm64/configs/temp_defconfig
}

build_dtb() {
    echo "-----------------------------------------------"
    echo "Building dtb..."
    echo "-----------------------------------------------"
    make $BUILD_VAR
    make $BUILD_VAR dtbs
}

build_dtbo() {
    echo "-----------------------------------------------"
    echo "Building dtbo.img..."
    echo "-----------------------------------------------"
    DTBO_FILES=$(find $(pwd)/out/arch/arm64/boot/dts/samsung/ -name sm*150-sec-$DEVICE-eur-overlay-*.dtbo)
    $(pwd)/tools/mkdtimg create $(pwd)/out/dtbo.img --page_size=4096 ${DTBO_FILES}
}
ls -la out/arch/arm64/boot/
prepare_ak3() {
    cd AnyKernel3/

    # Find whichever kernel image the build produced
    KIMG=""
    for f in Image.gz-dtb Image.gz Image; do
        if [ -f "$KERNEL_DIR/out/arch/arm64/boot/$f" ]; then
            KIMG="$f"
            break
        fi
    done

    if [ -z "$KIMG" ]; then
        echo "ERROR: no kernel image found in out/arch/arm64/boot/"
        ls -la "$KERNEL_DIR/out/arch/arm64/boot/"
        exit 1
    fi

    echo "Using kernel image: $KIMG"
    cp "$KERNEL_DIR/out/arch/arm64/boot/$KIMG" "$KIMG"
    cp "$KERNEL_DIR/out/dtbo.img" dtbo.img
    cp "$KERNEL_DIR/out/arch/arm64/boot/dts/qcom/$SOC.dtb" dtb

    sed -i "s/^device\.name1=.*/device.name1=${DEVICE}/" anykernel.sh
    sed -i "s/^device\.name2=.*/device.name2=${DEVICE2}/" anykernel.sh

    # Package the flashable zip
    zip -r9 "$KERNEL_DIR/out/PrimeKernel-$DEVICE.zip" . -x ".git*" -x "README.md" -x "*.placeholder"

    cd "$KERNEL_DIR"
}
}

build_kernel
build_dtb
build_dtbo
prepare_ak3
