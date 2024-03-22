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
CHATID="-4064889762"
export CHATID API_BOT TYPE_KERNEL

# Kernel build config
TYPE="AOSP"
DEVICE="Redmi note 8"
KERNEL_NAME="X-Derm"
DEFCONFIG="fury-perf_defconfig"
AnyKernel="https://github.com/RooGhz720/Anykernel3"
AnyKernelbranch="master"
HOSST="Fchelz"
USEER="root"
ID="1"
MESIN="Git Workflows"


# setup telegram env
export WAKTU=$(date +"%T")
export TGL=$(date +"%d-%m-%Y")
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"


tg_sticker() {
   curl -s -X POST "https://api.telegram.org/bot$API_BOT/sendSticker" \
        -d sticker="$1" \
        -d chat_id=$CHATID
}

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=markdown" \
        -d text="$1"
}

tg_post_build() {
        #Show the Checksum alongwith caption
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=markdown"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to build , check <code>error.log</code>"
}

function clean() {
    echo -e "\n"
    echo -e "$red << cleaning up >> \n$white"
    echo -e "\n"
    rm -rf out
}

function build_kernel() {
    echo -e "\n"
    echo -e "$yrllow << building kernel >> \n$white"
    echo -e "\n"

    make -j$(nproc --all) O=out ARCH=arm64 fury-perf_defconfig
    make -j$(nproc --all) ARCH=arm64 O=out \
                          CROSS_COMPILE=aarch64-linux-gnu- \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                          CROSS_COMPILE_COMPAT=arm-linux-gnueabi Image.gz-dtb dtbo.img
                          
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
clean
build_kernel
cd /out/arch/arm64/boot/
tg_post_build dtbo.img "$CHATID"
exit

DATE=$(date +"%Y%m%d-%H%M%S")
KERVER=$(make kernelversion)
KOMIT=$(git log --pretty=format:'"%h : %s"' -2)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

export IMG="$MY_DIR"/out/arch/arm64/boot/Image.gz-dtb
export dtbo="$MY_DIR"/out/arch/arm64/boot/dtbo.img
export dtb="$MY_DIR"/out/arch/arm64/boot/dtb.img


        if [ -f "$IMG" ]; then
                echo -e "$green << selesai dalam $(($Diff / 60)) menit and $(($Diff % 60)) detik >> \n $white"
        else
                echo -e "$red << Gagal dalam membangun kernel!!! , cek kembali kode anda >>$white"
                tg_post_msg "GAGAL!!! uploading log"
                tg_error "error.log" "$CHATID"
                tg_post_msg "done" "$CHATID"
                rm -rf out
                rm -rf testing.log
                rm -rf error.log
                exit 1
        fi

TEXT1="
*Build Completed Successfully*
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
* Device* : \`$DEVICE\`
* Code name* : \`Ginkgo | Willow\`
* Variant Build* : \`$TYPE\`
* Time Build* : \`$(($Diff / 60)) menit\`
* Branch Build* : \`$BRANCH\`
* System Build* : \`$MESIN\`
* Date Build* : \`$TGL\` \`$WAKTU\`
* Last Commit* : \`$KOMIT\`
* Author* : @fchelz
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━"

        if [ -f "$IMG" ]; then
                echo -e "$green << cloning AnyKernel from your repo >> \n $white"
                git clone --depth=1 "$AnyKernel" --single-branch -b "$AnyKernelbranch" zip
                echo -e "$yellow << making kernel zip >> \n $white"
                cp -r "$IMG" zip/
                cp -r "$dtbo" zip/
                cp -r "$dtb" zip/
                cd zip
                export ZIP="$KERNEL_NAME"-"$TYPE"-"$TGL"
                zip -r9 "$ZIP" * -x .git README.md LICENSE *placeholder
                curl -sLo zipsigner-3.0.jar https://github.com/Magisk-Modules-Repo/zipsigner/raw/master/bin/zipsigner-3.0-dexed.jar
                java -jar zipsigner-3.0.jar "$ZIP".zip "$ZIP"-signed.zip
                tg_post_msg "$TEXT1" "$CHATID"
                tg_post_build "$ZIP"-signed.zip "$CHATID"
                cd ..
                rm -rf error.log
                rm -rf out
                rm -rf zip
                rm -rf testing.log
                exit
        fi
