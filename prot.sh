#!/bin/bash
echo $HOME
if ! [ -d "$HOME/proton" ]; then
echo "proton clang not found! Cloning..."
if ! git clone -q https://github.com/kdrag0n/proton-clang.git --depth=1 -b master ~/proton; then ## ini Clang nya tools untuk membangun/compile kernel nya (tidak semua kernel mendukung clang)
echo "Cloning failed! Aborting..."
exit 1
fi
fi
echo "isi sekarang: "
ls
echo "isi home: "
ls $HOME
echo "isi home/proton: "
ls $HOME/proton

export PATH="$HOME/toolchains/proton-clang/bin:$PATH"
echo $PATH
export KBUILD_COMPILER_STRING="$($HOME/toolchains/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
clang --version
