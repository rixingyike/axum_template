#!/bin/bash

# 获取项目根目录名称
PROJECT_NAME=$(basename "$(pwd)")

# 获取当前系统平台
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TARGET="x86_64-unknown-linux-gnu"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TARGET="x86_64-apple-darwin"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    TARGET="x86_64-pc-windows-msvc"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# 编译函数
build_for_platform() {
    echo "Building for current platform (target: $TARGET)..."

    # 使用 cross 编译
    cross build --release --target $TARGET

    # 复制生成的文件到目标位置
    local source_file="target/$TARGET/release/$PROJECT_NAME"
    if [[ "$TARGET" == "x86_64-pc-windows-msvc" ]]; then
        source_file="$source_file.exe"
    fi

    local dest_file="target/release/$PROJECT_NAME"
    mkdir -p "target/release"
    cp "$source_file" "$dest_file"

    echo "Output: $dest_file"
}

# 执行编译
build_for_platform

echo "Build completed!"