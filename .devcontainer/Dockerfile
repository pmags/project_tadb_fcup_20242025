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
    libpq-dev

# Setup YAP
RUN apt-get update && git clone https://github.com/vscosta/yap-6.3 \
    && cd yap-6.3 \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

# Setup SWI-Prolog
RUN apt-get update && apt-get install -y \
    swi-prolog \
    swi-prolog-x \
    swi-prolog-doc \
    swi-prolog-compiler \
    swi-prolog-ssl \
    swi-prolog-swi \
    libpl-doc

# Setup Python
RUN pip install --no-cache-dir psycopg2-binary shapely matplotlib 

WORKDIR /workspace
COPY setup_db.py .

CMD ["python", "setup_db.py"]


