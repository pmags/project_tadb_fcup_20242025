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


### The instructions below should produce an installation of YAP under Linux:
    
sudo apt-get install git cmake build-essential swig libgmp-dev mpi-default-dev libgecode-dev libxml2-dev libraptor2-dev openjdk-11-jre openjdk-11-jdk libreadline-dev
git clone https://github.com/vscosta/yap-6.3
cd yap-6.3 ./configure --prefix=/usr
make
sudo make install

## Install yap

https://moodle2425.up.pt/pluginfile.php/251307/mod_resource/content/1/yap_install_instructions_under_linux.txt


psql -h localhost -U postgres -d postgres

pip install -r requirements.txt

https://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS3UbuntuPGSQLApt
