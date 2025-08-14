#!/bin/bash
set -e

. $(pwd)/../common.sh

hosts() {
    cat $(pwd)/hosts.txt | grep -v '#'
}

common_flags() {
    base_flags

    echo -framework "megatron-lm"
    echo -model "gpt"
    echo -model-size "xl"
    echo -dataset "enwiki"
    echo -batch-size 128
    echo -micro-batch-size 8
    echo -precision "fp16"
    echo -index-url "/data/megatron-lm/gpt-2/enwiki/npzs_seq1024_new/indices.txt"
    echo -hosts "$(join $(hosts))"
    echo -gpu-per-host 8
    echo -gpu-per-container 8
    echo -seq-length 1024
    echo -time-based
    echo -detect-self-ip bond0
    echo -seed 1234
    echo -no-shuffle
}

tenplex_flags() {
    common_flags
    echo -jobid dyn-res-tenplex
    echo -para-config "tenplex-para-config.json"
    echo -schedule-file "tenplex-schedule.json"
    echo -logdir logs-dyn-res-tenplex
}

tenplex_dp_flags() {
    common_flags
    echo -jobid dyn-res-tenplex-dp
    echo -para-config "pytorch-para-config.json"
    echo -schedule-file "pytorch-schedule.json"
    echo -logdir logs-dyn-res-tenplex-dp
}

pytorch_flags() {
    common_flags
    echo -jobid dyn-res-tde
    echo -para-config "pytorch-para-config.json"
    echo -schedule-file "pytorch-schedule.json"
    echo -no-tenplex
    echo -logdir logs-dyn-res-tde
}

export PATH=/usr/local/go/bin:/root/go/bin:$PATH

# set -x
tenplex-run $(tenplex_flags) 2>&1 | tee dyn-res-tenplex.log
# exit
python extract_metrics.py -t dyn-res-tenplex
# exit
tenplex-run $(tenplex_dp_flags) 2>&1 | tee dyn-res-tenplex-dp.log 
python extract_metrics.py -t dyn-res-tenplex-dp

mkdir -p /data/tensorboard
sudo rm -fr /data/tensorboard/*
tenplex-run $(pytorch_flags) 2>&1 | tee dyn-res-tde.log
python extract_metrics.py -t dyn-res-tde

python plot.py
