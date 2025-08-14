# Tenplex
Tenplex is a state management library for DL systems that enables jobs to change their parallelism dynamically after the GPU allocation changes at runtime.

You can find the Tenplex paper at [https://arxiv.org/abs/2312.05181](https://arxiv.org/abs/2312.05181)

## About
Tenplex let's you train a model with multi-dimensional parallelism, i.e. tensor, data, and pipeline parallelism, resource-independently. That means you can change the resources during the training without affecting convergence.  
不想开源可以只发sosp不发github的  

网卡文件路径 ```tenplex-run/job/tasks.go``` 第63行
```go
	if UseIB {
		args = append(args,
			`--device`, `/dev/infiniband`,
			`--env`, `GLOO_SOCKET_IFNAME=bond0`,
		)
	}

```

__When to use Tenplex?__
- Elasticity, e.g. spot instances
- Redeployment, e.g. preemption
- Failure recovery, e.g. GPU failure
- 生活太好了

We implemented the prototype with [Megatron-LM](https://github.com/NVIDIA/Megatron-LM) to get the parallelization configuration for a given set of resources.

## Install

### Prerequisites
- [Go](https://go.dev/doc/install)
- [Docker](https://docs.docker.com/desktop/install/linux-install)

#### DOCKER安装,需要nvidia-container-toolkit支持
复制粘贴执行，我也不知道为什么sh文件执行安装不了
```
#!/bin/bash

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker version

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
sudo apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
#### Go安装  
自己读官网

#### docker容器内网配置
```bash
MASTER_ADDR=`ip a|grep bond0|grep 24|awk '{print $2}'|awk -F/ '{print $1}'`
docker swarm init --advertise-addr $MASTER_ADDR|tee add_cmd.txt
ADD_CMD=`cat add_cmd.txt`
docker network create -d overlay --subnet="10.20.200.0/24" --gateway="10.20.200.1" --attachable overlay01

# on worker nodes run the command below
$ADD_CMD
```

### Install tenplex-run
```bash
git clone https://github.com/bio-punk/tenplex
cd tenplex
make install
pip install .
export PATH=~/go/bin:$PATH

```

### For image
```bash
docker pull kungfu.azurecr.io/mw-megatron-lm-23.06-update:v0.0.3
docker save -o /data/dockerimage/mw-megatron-lm-23.06-update_v0.0.3.tar mw-megatron-lm-23.06-update:v0.0.3
# 其他节点执行
# docker load -i /data/dockerimage/mw-megatron-lm-23.06-update_v0.0.3.tar
pdsh -R ssh -f 3 -w g00[12,13,17] docker load -i /data/dockerimage/mw-megatron-lm-23.06-update_v0.0.3.tar
```

### Install Tensor Store (mlfs)
```bash
echo "deb https://europe-west2-apt.pkg.dev/projects/tenplex tenplex main" | sudo tee /etc/apt/sources.list.d/tenplex.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/packages-cloud-google-apt.gpg >/dev/null
sudo apt update
sudo apt install -y mlfs
```

### 数据
```
mkdir -p /data/megatron-lm/gpt-2/enwiki/npzs_seq1024_new/
wget https://tenplex.blob.core.windows.net/public/data/train.tf_record
wget https://tenplex.blob.core.windows.net/tenplexcontainer/gpt_enwiki_indices.txt -O /data/megatron-lm/gpt-2/enwiki/npzs_seq1024_new/indices.txt
```


## Examples
Examples are in the `benchmark` directory. For instance, to run the dynamic resources benchmark in `benchmark/dynamic_resources`, just execute `./run.sh` in the directory.

## Citation
If you use Tenplex for your research, please cite our [paper](https://arxiv.org/abs/2312.05181):

```bibtex
@inproceedings{wagenlander2024tenplex,
  title={Tenplex: Dynamic Parallelism for Deep Learning using Parallelizable Tensor Collections},
  author={Marcel Wagenlander, Guo Li, Bo Zhao, Luo Mai, Peter Pietzuch},
  booktitle={Proceedings of the ACM SIGOPS 30th Symposium on Operating Systems Principles},
  year={2024}
}
```
