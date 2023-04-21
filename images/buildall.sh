
# todo modify the mamba forge so that it doesnt require pulling latest from github every time
# use docker pull condaforge/mambaforge
cd ssh && ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04  -r /home/z/work/dokcred
cd ../mamba && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh
cd ../torch && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba
cd ../face && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch
