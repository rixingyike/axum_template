#!/bin/bash

# 服务器配置
SERVER="user@example.com"
APP_DIR="/var/www/axum_app"
SERVICE_NAME="axum_service"

# 代码同步
rsync -avz --delete --exclude='.git' --exclude='target' ./ ${SERVER}:${APP_DIR}

# 远程构建与重启
ssh ${SERVER} << EOF
  cd ${APP_DIR}
  cargo build --release
  sudo systemctl restart ${SERVICE_NAME}
EOF

echo "Deployment completed!"
