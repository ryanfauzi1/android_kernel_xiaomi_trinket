#!/bin/bash
# Copyright cc 2023 sirnewbies

# setup color
red='\033[0;31m'
green='\e[0;32m'
white='\033[0m'
yellow='\033[0;33m'

MY_DIR=$(pwd)
KERN_IMG="${MY_DIR}/out/arch/arm64/boot/Image-gz.dtb"
KERN_IMG2="${MY_DIR}/out/arch/arm64/boot/Image.gz"
API_BOT="6787166379:AAGXuTzT49V0DdAzLiRB4Lj3PUsVQWkIiJM"
CHATID="-1002045739350"
export CHATID API_BOT TYPE_KERNEL


# setup telegram env
export WAKTU=$(date +"%T")
export TGL=$(date +"%d-%m-%Y")
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"


tg_post_build() {
        #Show the Checksum alongwith caption
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=markdown"
}


function clin() {
    echo -e "\n"
    echo -e "$red << cleaning up >> \n$white"
    echo -e "\n"
    make O=out clean && make O=out mrproper
    rm -rf ${MY_DIR}/out
}

function build_kernel() {
    echo -e "\n"
    echo -e "$yrllow << building kernel >> \n$white"
    echo -e "\n"

    make -j$(nproc --all) O=out ARCH=arm64 fury-perf_defconfig
    make -j$(nproc --all) ARCH=arm64 O=out \
                          CC=clang LD=ld.lld \
                          CROSS_COMPILE=aarch64-linux-gnu- \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi-
                          
    if [ -e "$KERN_IMG" ] || [ -e "$KERN_IMG2" ]; then
        echo -e "\n"
        echo -e "$green << compile kernel success! >> \n$white"
        echo -e "\n"
    else
        echo -e "\n"
        echo -e "$red << compile kernel failed! >> \n$white"
        echo -e "\n"
    fi
}

# execute
clin
build_kernel
cd ${MY_DIR}/out/arch/arm64/boot/
tg_post_build dtbo.img "$CHATID"
tg_post_build Image.gz "$CHATID"
