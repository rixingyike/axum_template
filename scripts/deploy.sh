#!/bin/bash

PROJECT_NAME=$(basename "$(pwd)")

# 服务器配置
SERVER="Administrator@81.70.152.107"
APP_DIR="c:/work/$PROJECT_NAME"
SERVICE_NAME="axum_service"

# 代码同步
rsync -avz --delete --exclude='.git' --exclude='target' --rsh='ssh' ./ ${SERVER}:${APP_DIR} 

# 远程构建与重启
ssh ${SERVER} << EOF
  cd ${APP_DIR}
  cargo build --release
#   sudo systemctl restart ${SERVICE_NAME}
EOF

echo "Deployment completed!"
