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
# RUN apt-get update && apt-get install -y \
#     swi-prolog \
#     swi-prolog-x \
#     swi-prolog-doc \
#     swi-prolog-compiler \
#     swi-prolog-ssl \
#     swi-prolog-swi \
#     libpl-doc

# Setup Python
RUN pip install --no-cache-dir psycopg2-binary shapely matplotlib

# Download the wait-for-it.sh script, which is used to wait for dependent services (e.g., databases) to be ready
RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

# Set the working directory inside the container to /workspace
# This is where the application code and scripts will be executed
WORKDIR /workspace

# Copy the database setup script (setup_db.py) and visualization script (show_tetrominoes.py)
# from the 'sql' folder in the build context to the container's working directory
COPY setup/setup_db.py .
COPY python/show_tetrominoes.py .

# Copy the entrypoint script, which will be executed when the container starts
COPY entrypoint.sh .

# Make the entrypoint script executable so it can be run as a command
RUN chmod +x entrypoint.sh

# Set the entrypoint script as the default command to run when the container starts
CMD ["/workspace/entrypoint.sh"]
