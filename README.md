# Project TADB FCUP 2024/2025

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/pmags/project_tadb_fcup_20242025)

[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/pmags/project_tadb_fcup_20242025)


## How is the project structured

The project is organized as follows:

```
.
├── .devcontainer/            # Container configuration for development
├── gis_functions/            # C functions for PostGIS integration with YAP
├── solver/            # YAP implementation of solver
├── report/                   # Project report and presentation
│   ├── assets/               # Images and other assets for the report
│   ├── report.html           # HTML version of the report
│   ├── report.pdf            # PDF version of the report (if generated)
│   ├── report.qmd            # Quarto source for the report
│   └── report_files/         # Supporting files for report.html
├── utils/                    # Python modules for utility functions
└── tests/                    # Unit tests
    └── devcontainer/         # Unit tests for dev environment and prolog

```

## How to run the project

quarto install tinytex
quarto render format_test.qmd --to html,pdf

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

