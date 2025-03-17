#!/bin/bash

# 服务名称（默认等于当前项目的根目录名称）
SERVICE_NAME=$(basename "$(pwd)")
echo $SERVICE_NAME

# 可执行文件路径（假设可执行文件在 target/release 目录下）
EXECUTABLE_PATH="$(pwd)/target/release/$SERVICE_NAME.exe"

# 检查服务是否存在
service_exists() {
    sc query "$SERVICE_NAME" > /dev/null 2>&1
    return $?
}

# 检查服务是否正在运行
service_running() {
    status=$(sc query "$SERVICE_NAME" | grep "STATE" | awk '{print $4}')
    if [[ "$status" == "RUNNING" ]]; then
        return 0
    else
        return 1
    fi
}

# 注册服务（包括恢复配置）
register_service() {
    echo "Registering service: $SERVICE_NAME..."
    sc create "$SERVICE_NAME" binPath= "$EXECUTABLE_PATH" start= auto
    if [[ $? -eq 0 ]]; then
        echo "Service registered successfully."

        # 配置服务恢复选项：失败后 5 秒重启，重置失败计数时间为 60 秒
        sc failure "$SERVICE_NAME" reset= 60 actions= restart/5000
        if [[ $? -eq 0 ]]; then
            echo "Service recovery options configured successfully."
        else
            echo "Failed to configure service recovery options."
            exit 1
        fi
    else
        echo "Failed to register service."
        exit 1
    fi
}

# 启动服务
start_service() {
    echo "Starting service: $SERVICE_NAME..."
    sc start "$SERVICE_NAME"
    if [[ $? -eq 0 ]]; then
        echo "Service started successfully."
    else
        echo "Failed to start service."
        exit 1
    fi
}

# 停止服务
stop_service() {
    echo "Stopping service: $SERVICE_NAME..."
    sc stop "$SERVICE_NAME"
    if [[ $? -eq 0 ]]; then
        echo "Service stopped successfully."
    else
        echo "Failed to stop service."
        exit 1
    fi
}

# 卸载服务
uninstall_service() {
    echo "Uninstalling service: $SERVICE_NAME..."
    sc delete "$SERVICE_NAME"
    if [[ $? -eq 0 ]]; then
        echo "Service uninstalled successfully."
    else
        echo "Failed to uninstall service."
        exit 1
    fi
}

# 主逻辑
case "$1" in
    start)
        if ! service_exists; then
            register_service
        fi
        if service_running; then
            stop_service
        fi
        start_service
        ;;
    stop)
        if service_exists; then
            stop_service
        else
            echo "Service $SERVICE_NAME does not exist."
        fi
        ;;
    uninstall)
        if service_exists; then
            stop_service
            uninstall_service
        else
            echo "Service $SERVICE_NAME does not exist."
        fi
        ;;
    *)
        # 默认行为：启动服务
        if ! service_exists; then
            register_service
        fi
        if service_running; then
            stop_service
        fi
        start_service
        ;;
esac

echo "Operation completed."