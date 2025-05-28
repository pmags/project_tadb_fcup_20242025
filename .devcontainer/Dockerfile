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
RUN apt-get update && git clone https://github.com/vscosta/yap-6.3 \
    && cd yap-6.3 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

# Install OS packages in one shot, non-interactive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      postgresql-client \
      python3-psycopg2 \
      python3-shapely \
      python3-matplotlib \
      build-essential 

#activate env for python
RUN python -m venv /env \
    && /env/bin/python -m pip install --upgrade pip setuptools wheel

RUN apt-get update && apt-get install -y yap libyap-dev
    

ENV VIRTUAL_ENV=/env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
