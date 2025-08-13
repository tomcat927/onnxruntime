# Dockerfile for musllinux_aarch64 ONNX Runtime build
FROM alpine:latest

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    python3 \
    py3-pip \
    protobuf-dev \
    linux-headers \
    openblas-dev \
    bash \
    curl \
    unzip \
    tar

# Install Python dependencies
RUN pip3 install --upgrade pip setuptools wheel numpy

# Set working directory
WORKDIR /workspace

# Clone ONNX Runtime (or use your fork)
RUN git clone --recursive https://github.com/microsoft/onnxruntime.git

# Set environment variables for musllinux_aarch64
ENV ONNXRUNTIME_BUILD_DIR="/workspace/onnxruntime/build"
ENV CMAKE_TOOLCHAIN_FILE="/workspace/onnxruntime/cmake/linux_musl.toolchain.cmake"
ENV CMAKE_ARGS="-DONNX_CUSTOM_PROTOC_EXECUTABLE=/usr/bin/protoc -DPython_EXECUTABLE=/usr/bin/python3"

# Build ONNX Runtime
RUN mkdir -p ${ONNXRUNTIME_BUILD_DIR} && \
    cd ${ONNXRUNTIME_BUILD_DIR} && \
    cmake \
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
        -DONNXRUNTIME_ENABLE_PYTHON=ON \
        -DPYTHON_EXECUTABLE=/usr/bin/python3 \
        -DONNXRUNTIME_BUILD_WHEEL=ON \
        -DONNXRUNTIME_TARGET_PLATFORM=musllinux_aarch64 \
        ${CMAKE_ARGS} \
        .. && \
    make -j$(nproc) && \
    make wheel

# Copy the generated wheel to /output
RUN mkdir -p /output && \
    find ${ONNXRUNTIME_BUILD_DIR}/_dist -name "*.whl" -exec cp {} /output \;
