# Use official musllinux_aarch64 base image (recommended)
FROM quay.io/pypa/musllinux_1_1_aarch64:latest

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3-dev \
    python3-pip \
    protobuf-compiler \
    libopenblas-dev \
    bash \
    curl \
    unzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --upgrade pip setuptools wheel numpy

# Set working directory
WORKDIR /workspace

# Clone ONNX Runtime (or use your fork)
RUN git clone --recursive https://github.com/microsoft/onnxruntime.git

# Set environment variables
ENV ONNXRUNTIME_BUILD_DIR="/workspace/onnxruntime/build"
ENV CMAKE_ARGS="-DONNX_CUSTOM_PROTOC_EXECUTABLE=/usr/bin/protoc -DPython_EXECUTABLE=/usr/bin/python3"

# Build ONNX Runtime for musllinux_aarch64
RUN mkdir -p ${ONNXRUNTIME_BUILD_DIR} && \
    cd ${ONNXRUNTIME_BUILD_DIR} && \
    cmake \
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
