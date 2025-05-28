FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

ENV PYTHONUNBUFFERED 1

# Setup C
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \ 
    build-essential \ 
    cmake \ 
    gcc \ 
    g++ \ 
    gdb \ 
    swig \ 
    libgmp-dev \ 
    mpi-default-dev \ 
    libgecode-dev \ 
    libxml2-dev \ 
    libraptor2-dev \ 
    openjdk-11-jre \ 
    openjdk-11-jdk \ 
    libreadline-dev \
    libpq-dev \
    git \
    make \
    autoconf \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \ 
    texlive-latex-recommended

# Setup YAP
# RUN apt-get update && git clone https://github.com/vscosta/yap-6.3 \
#     && cd yap-6.3 \
#     && ./configure --prefix=/usr \
#     && make \
#     && sudo make install

# Setup YAP
RUN apt-get update && apt-get install -y \
    build-essential \
    libgmp-dev \
    libreadline-dev \
    libpq-dev \
    libxext-dev \
    libxpm-dev \
    libxt-dev \
    libice-dev \
    libsm-dev \
    libx11-dev \
    libxmu-dev \
    libxaw7-dev \
    zlib1g-dev \
    libffi-dev \
    libtool \
    pkg-config \
    git \
    sudo \
    && git clone https://github.com/vscosta/yap-6.3 \
    && cd yap-6.3 \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && sudo make install

    