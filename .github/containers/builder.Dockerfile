# Base image matches the GitHub Actions runner version for consistency
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    patchelf \
    rpm \
    xdg-utils \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install mold Linker
RUN wget -O- https://github.com/rui314/mold/releases/download/v2.40.4/mold-2.40.4-x86_64-linux.tar.gz | tar -C /usr/local --strip-components=1 --no-overwrite-dir -xzf - && \
    ln -sf /usr/local/bin/mold /usr/bin/ld

# 3. Install Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal

# 4. Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 5. Install pnpm
RUN corepack enable pnpm

# 6. Pre-create generic cache directories to ensure permissions
RUN mkdir -p /github/home/.cargo && chmod 777 /github/home/.cargo