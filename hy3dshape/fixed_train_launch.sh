#!/bin/bash
# Fixed script to properly launch distributed training with DeepSpeed

export CUDA_VISIBLE_DEVICES=0,1
export num_gpu_per_node=2
export node_num=1
export node_rank=0
export master_ip=127.0.0.1  # Use localhost for single-node training

# Configuration
# Use FP16 config for better compatibility with Turing GPUs
export config=configs/hunyuandit-mini-overfitting-flowmatching-dinol518-fp16-lr1e4-4096.yaml
export output_dir=output_folder/dit/overfitting_depth_16_token_4096_lr1e4

# Set environment variables for distributed training
export MASTER_ADDR=$master_ip
export MASTER_PORT=12348
export WORLD_SIZE=$num_gpu_per_node
export NODE_RANK=$node_rank

# NCCL environment variables
export NCCL_IB_TIMEOUT=24
export NCCL_NVLS_ENABLE=0
export NCCL_DEBUG=WARN

# Create output directory and copy config
if test -d "$output_dir"; then
    cp $config $output_dir
else
    mkdir -p "$output_dir"
    cp $config $output_dir
fi

echo "--- Training Configuration ---"
echo "node_num: $node_num"
echo "node_rank: $node_rank"
echo "num_gpu_per_node: $num_gpu_per_node"
echo "master_ip: $master_ip"
echo "config: $config"
echo "output_dir: $output_dir"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "------------------------------"

# Use torchrun for proper distributed launching
torchrun \
    --nproc_per_node=$num_gpu_per_node \
    --nnodes=$node_num \
    --node_rank=$node_rank \
    --master_addr=$master_ip \
    --master_port=12348 \
    main.py \
    --num_nodes $node_num \
    --num_gpus $num_gpu_per_node \
    --config $config \
    --output_dir $output_dir \
    --deepspeed