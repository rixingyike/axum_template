#!/bin/bash

# 获取项目根目录名称
# PROJECT_NAME=$(basename "$(pwd)")

cargo build --release

echo "Build completed!"