
### APPENDIX A - DEVContainer Env

Project Structure:
* devcontainer.json
* Dockerfile
* docker-compose.yml
* main.c   # C code
* app.py   # Python code
* requirements.txt   # Python dependencies


Dockerfile:
This is the development environment with tools for:
* Python 3
* PostgreSQL C headers
* GCC
* Optionally, SWI-Prolog/YAP

After setup: 
* Open project in VS Code
* Run “Dev Containers: Reopen in Container”
* You're in a full dev environment:
   * Run Python + Postgres code
   * Compile C with _gcc -lpq your.c_
   * Connect to Postgres using _libpq_ in C and _psycopg2_ in Python
   * Use Prolog/YAP if needed via CLI


