#!/bin/bash

# script for installing & benchmarking RKNPU2
# make sure to `chmod +x` this file to execute

# install prerequisites & set envs for compilation
sudo apt update
sudo apt install cmake python3-rknnlite2 rknpu2-rk3588
export PATH=$PATH:/home/vicharak/.local/bin
export GCC_COMPILER=/usr/bin/aarch64-linux-gnu

# start by cloning the source
git clone https://github.com/airockchip/rknn-toolkit2.git
cd rknn-toolkit2/rknn-toolkit2/

# install necessary packages
pip install -r packages/arm64/arm64_requirements_cp310.txt 
pip install packages/arm64/rknn_toolkit2-2.3.0-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl 

# needed to do this manually, not sure if an "official" method exists
cd ../rknpu2/
sudo cp runtime/Linux/librknn_api/aarch64/librknnrt.so /usr/lib/
sudo cp runtime/Linux/librknn_api/include/* /usr/local/include/

# build and install the benchmark
cd examples/rknn_benchmark/
chmod +x build-linux.sh 
./build-linux.sh -t rk3588 -a aarch64 -b Release
sudo cp install/rknn_benchmark_Linux/rknn_benchmark /usr/bin/

# run benchmark against an RKNN model
cd ../../../rknn-toolkit-lite2/examples/resnet18/
rknn_benchmark resnet18_for_rk3588.rknn 
