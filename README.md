# Project TADB FCUP 2024/2025



## Data Structure & table creation 
3 tables:
• A table to represent the seven tetrominoes, with additonal atributes that assigns a color and a lePer to a tetromino, as in the picture above;
• A table to represent puzzles;
• A table to represent solutions of each puzzle of the previous table (the way solutions are represented can have very diﬀerent approaches).

## Data Construction

• Pieces representation & construction in DB

• Puzzles representation  & construction in DB (at least 5 examples - creativity is a criteria too)

• Puzzle Solutions representation  & construction in DB


## Prolog-YAP/PostGIS integration using libpq C API (functions that are needed next)

### predicates implementation that are useful to solve the puzzles
• st_diﬀerence
• st_translate
• st_rotate

### logic term representation of the data fetched from the three tables


## Puzzles solutions calculation (using prolog)
the algorithm using backtracking mechanismo:
1. find the peices/positins combinations (16 figures is the summary)
2. for each of the 16 figures:
   2.1. choose one
   2.2. position it
   2.3. calculate the polygon diference resulting from this figure and positioning
   2.4. backtrack with the remaining figures and polygon
   2.5. if the remaining space has spaces smaller then 4 grid cells, it is not a solution


## Plotting of puzzles using Matplotlib in python (initial - in dark - and solution ones - in color)


## Final Remarks & comments
4 page report.
presentation.

## APPENDIX

### APPENDIX A - DEVContainer Env

Project Structure:
* devcontainer.json
* Dockerfile
* docker-compose.yml
* c2postgres_example   # C code that runs postgres queris example
* app.py   # Python code
* requirements.txt   # Python dependencies
* create_db.sql   # script to create database
* populate_db.sql  # script to populate database
* 


Dockerfile:
This is the development environment with tools for:
* Python 3
* PostgreSQL C headers
* GCC
* Optionally, SWI-Prolog/YAP

DATA:
* POSTGRES_USER: postgres
* POSTGRES_DB: postgres
* POSTGRES_PASSWORD: postgres

After setup: 
* Open project in VS Code
* Run “Dev Containers: Reopen in Container”
* You're in a full dev environment:
   * Run Python + Postgres code
   * postgres sql client: $ psql -h db -U postgres
   * Compile C with _gcc -lpq your.c_
   * Connect to Postgres using _libpq_ in C and _psycopg2_ in Python
   * Use Prolog/YAP if needed via CLI

Tasks:
1. create database
   psql -h db -U postgres -d postgres -f create_db.sql
2. populate databaase
   psql -h db -U postgres -d postgres -f populate_db.sql
3. compile the main.c program (that runs an example query using C to target postgres database db)
   gcc -o c2postgres_example c2postgres_example.c -lpq

   
