# Dynamic resources
_Fig. 9. Elastic DL job convergence with multi-dimensional parallelism under dynamic GPU changes_

First, we explore the benefits of supporting elasticity in DL jobs with multi-dimensional parallelism, scaling across all parallelism dimensions when the GPU allocation changes.
In this experiment, we train DL jobs with the GPT-3 XL model on the on-premise 16-GPU cluster. The job runtime and elastic scaling events are derived based on Microsoft’s Philly trace: over the runtime of 538 mins, we scale based on the average every 35 mins. During a scaling event, we change the number of GPUs for a job between 16, 8, and 4 GPUs.

# 修改配置
## hosts.txt
改成你想要的节点，```/etc/hosts```配置好了写别名也行
```
g0011
g0012
g0013
g0017
```
  
## run.sh
配置节点卡数，建议是每个宿主机只起一个容器实例
```
    echo -gpu-per-host 8
    echo -gpu-per-container 8
```
配置网卡
内网ip在哪就写哪，比如我这里是bond0就写bond0
```
    echo -detect-self-ip bond0
```

## 数据集也不说放哪了
补充nccl环境
```
conda install \
    -c nvidia/label/cuda-12.4.0/linux-64 \
    -c conda-forge \
    -c pytorch \
    cuda-nvrtc \
    cuda-cudart \
    cuda-version=12.4 \
    cuda-nvcc \
    cuda-cudart-dev \
    cuda-nvtx \
    libcusparse-dev \
    libcublas-dev \
    libcusolver-dev \
    libcurand-dev \
    cuda-nvvm-tools \
    "numpy<2" -y
conda install \
    -c nvidia/label/cuda-12.4.0/linux-64 \
    -c conda-forge \
    -c pytorch \
    cuda-cccl \
    cuda-cccl_linux-64 \
    cuda-crt-dev_linux-64 \
    cuda-crt-tools \
    cuda-cudart-dev_linux-64 \
    cuda-cudart-static_linux-64 \
    cuda-cudart_linux-64 \
    cuda-driver-dev_linux-64 \
    cuda-nvcc \
    cuda-nvcc-dev_linux-64 \
    cuda-nvcc-impl \
    cuda-nvcc-tools \
    cuda-nvcc_linux-64 \
    cuda-nvvm-dev_linux-64 \
    cuda-nvvm-impl \
    cuda-nvvm-tools \
    cuda-opencl \
    cuda-version=12.4
conda install conda-forge::cudnn=8
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$CONDA_PREFIX/lib:$LIBRARY_PATH
```

```bash
export PATH=/usr/local/go/bin:/root/go/bin:$PATH
```

# Run
```sh
./run.sh
```

## Note
The dynamic resources experiment runs for about 24 hours
