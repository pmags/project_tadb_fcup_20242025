# Notas sobre Projeto TABD 2025

# Maio 2025

# ROTEIRO DO PROJETO

1. usar postgres  
2. usar api com C do postgres (libpq C library)  
3. implementar o st\_translate e st\_rotate no prolog, usando a implementacao dispoinvel no postgres\_PostGIS  
4. slgoritmo de resolucao do puzzle:  
   1. é  como se fossem 16 peças (depois de explorar as rotacoes possiveis)  
   2. saber se uma solucao é viavel ou nao tem a ver com ver se ha buracos ‘menores’ que 4 quadrados-base \- nesse caso, nao ha solucao  
   3. o algoritmo passa por:  
      1. escolher uma peça  
      2. encaixa-la  
      3. executar novamente com o restante poligono (é o resultado da diferenca com a peça escolhida e colocada) e as restantes peças  
      4. termina quando nao há mais peças para  colocar

dependencias a instalar:

* usar script para setup de env.

# TETROMINOES

1. ## Definitions

   

   ### **Polyminoes**

     
   Tetrominoes are a subset of \*\*polyominoes\*\*, which are shapes made by connecting equal-sized squares. Since tetrominoes are made of exactly \*\*four squares\*\*, they have \*\*seven possible shapes\*\* when considering rotations and reflections.   
     
   However, if we expand to \*\*higher-order polyominoes\*\*, we unlock many more possibilities:  
     
   \#\#\# \*\*All Possible Shapes Based on Square Count\*\*  
   1\. \*\*Monominoes (1 square)\*\* → Just a single square.  
   2\. \*\*Dominoes (2 squares)\*\* → A single \*\*2-block\*\* strip.  
   3\. \*\*Trominoes (3 squares)\*\* → Only \*\*two distinct shapes\*\* (straight and L-shaped).  
   4\. \*\*Tetrominoes (4 squares)\*\* → \*\*Seven distinct shapes\*\*.  
   5\. \*\*Pentominoes (5 squares)\*\* → \*\*Twelve distinct shapes\*\*.  
   6\. \*\*Hexominoes (6 squares)\*\* → \*\*Thirty-five distinct shapes\*\*.  
   7\. \*\*Heptominoes (7 squares)\*\* → \*\*108 distinct shapes\*\*.  
   8\. \*\*Octominoes (8 squares)\*\* → \*\*369 distinct shapes\*\*.  
     
   Each higher-order polyomino follows combinatorial rules for how squares connect \*\*without holes or disconnections\*\*.  
     
   

   ### **Tetraminoes**

   

   There are \*\*seven distinct tetrominoes\*\*, each composed of four connected squares. Here’s a breakdown of all of them, along with their \*\*geometry representations\*\* in a geospatial database:  
     
   \#\#\# \*\*1. I-Tetromino (Straight Line)\*\*  
   \- \*\*Shape\*\*: Four squares in a row.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 2 0, 3 0, 3 1, 0 1, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*2. O-Tetromino (Square)\*\*  
   \- \*\*Shape\*\*: A 2x2 square.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 2 0, 2 2, 0 2, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*3. T-Tetromino\*\*  
   \- \*\*Shape\*\*: Three squares in a row with one in the center below.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 2 0, 1 1, 0 1, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*4. L-Tetromino\*\*  
   \- \*\*Shape\*\*: Three squares in a row, one square extending downward.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 2 0, 2 1, 0 1, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*5. J-Tetromino\*\*  
   \- \*\*Shape\*\*: Mirrored L-Tetromino.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 2 0, 0 1, 2 1, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*6. S-Tetromino\*\*  
   \- \*\*Shape\*\*: Two squares stacked diagonally, forming a slope.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 1 1, 2 1, 2 2, 0 2, 0 0))  
     \`\`\`  
     
   \#\#\# \*\*7. Z-Tetromino\*\*  
   \- \*\*Shape\*\*: Mirrored S-Tetromino.  
   \- \*\*WKT Representation\*\*:  
     \`\`\`  
     POLYGON ((0 0, 1 0, 1 1, \-1 1, \-1 2, 0 2, 0 0))  
     \`\`\`  
     
     
   

2. ## Full Set of Tetrominoes with Rotations

   ### **Rotation**

   Tetrominoes can be rotated \*\*clockwise (CW)\*\* or \*\*counterclockwise (CCW)\*\* in increments of \*\*90°, 180°, and 270°\*\*. 

   

   Each rotation transforms the tetromino’s shape while keeping its four squares intact. Here's how all seven tetrominoes behave across different rotations:

   

   

   

   \#\#\# \*\*Rotation Matrices for Tetromino Transformation\*\*

   

   To rotate a tetromino mathematically, we apply a rotation matrix to each of its coordinates:

   

   \- \*\*90° Counterclockwise\*\*:

     \\\[

     R\_{90} \= \\begin{bmatrix} 0 & \-1 \\\\ 1 & 0 \\end{bmatrix}

     \\\]

   

   \- \*\*180°\*\*:

     \\\[

     R\_{180} \= \\begin{bmatrix} \-1 & 0 \\\\ 0 & \-1 \\end{bmatrix}

     \\\]

   

   \- \*\*270° Counterclockwise (or 90° Clockwise)\*\*:

     \\\[

     R\_{270} \= \\begin{bmatrix} 0 & 1 \\\\ \-1 & 0 \\end{bmatrix}

     \\\]

   ### **Set of rotations**

   \#\#\#\# \*\*1. I-Tetromino (Line)\*\*

   \- \*\*0°\*\* → \`\[(0,0), (1,0), (2,0), (3,0)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (1,1), (1,2)\]\`

   \- \*\*180°\*\* → \`\[(0,2), (1,2), (2,2), (3,2)\]\`

   \- \*\*270°\*\* → \`\[(2,-1), (2,0), (2,1), (2,2)\]\`

   

   \#\#\#\# \*\*2. O-Tetromino (Square)\*\*

   \- \*\*All rotations are identical\*\* → \`\[(0,0), (1,0), (0,1), (1,1)\]\`

   

   \#\#\#\# \*\*3. T-Tetromino\*\*

   \- \*\*0°\*\* → \`\[(0,0), (1,0), (2,0), (1,1)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (1,1), (2,0)\]\`

   \- \*\*180°\*\* → \`\[(0,1), (1,1), (2,1), (1,0)\]\`

   \- \*\*270°\*\* → \`\[(0,0), (1,-1), (1,0), (1,1)\]\`

   

   \#\#\#\# \*\*4. L-Tetromino\*\*

   \- \*\*0°\*\* → \`\[(0,0), (1,0), (2,0), (2,1)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (1,1), (2,-1)\]\`

   \- \*\*180°\*\* → \`\[(0,1), (1,1), (2,1), (0,0)\]\`

   \- \*\*270°\*\* → \`\[(0,0), (0,1), (0,2), (1,2)\]\`

   

   \#\#\#\# \*\*5. J-Tetromino\*\*

   \- \*\*0°\*\* → \`\[(0,0), (1,0), (2,0), (0,1)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (1,1), (2,1)\]\`

   \- \*\*180°\*\* → \`\[(2,1), (1,1), (0,1), (2,0)\]\`

   \- \*\*270°\*\* → \`\[(0,-1), (0,0), (0,1), (1,-1)\]\`

   

   \#\#\#\# \*\*6. S-Tetromino\*\*

   \- \*\*0°\*\* → \`\[(0,0), (1,0), (1,1), (2,1)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (0,0), (0,1)\]\`

   \- \*\*180°\*\* → \`\[(0,0), (1,0), (1,1), (2,1)\]\`

   \- \*\*270°\*\* → \`\[(1,-1), (1,0), (0,0), (0,1)\]\`

   

   \#\#\#\# \*\*7. Z-Tetromino\*\*

   \- \*\*0°\*\* → \`\[(0,1), (1,1), (1,0), (2,0)\]\`

   \- \*\*90°\*\* → \`\[(1,-1), (1,0), (2,0), (2,1)\]\`

   \- \*\*180°\*\* → \`\[(0,1), (1,1), (1,0), (2,0)\]\`

   \- \*\*270°\*\* → \`\[(1,-1), (1,0), (2,0), (2,1)\]\`

   ### 

   ### **Set of distinct figures using tetrominoes with rotations**

   **Distinct *figures*** (not just shape types), considering **rotation differences as distinct**, the count changes.

   Let’s go through each tetromino, treating **each unique rotation** that produces a different orientation (not equivalent under rotation or translation) as a distinct figure.

   1\. I-Tetromino

* 0° (horizontal) ≠ 90° (vertical)  
  **2 distinct figures**

  2\. O-Tetromino

* All rotations look the same.  
  **1 distinct figure**

  3\. T-Tetromino

* 0°, 90°, 180°, 270° all look different  
  **4 distinct figures**

  4\. L-Tetromino

* 4 distinct orientations  
  **4 distinct figures**


  5\. J-Tetromino

* 4 distinct orientations  
   **4 distinct figures**

  6\. S-Tetromino

* 0° and 180° are the same  
* 90° and 270° are the same  
   **2 distinct figures**

  7\. Z-Tetromino

* Same pattern as S  
   **2 distinct figures**

  Total Count of Distinct Figures (by rotation):

  `I: 2`

  `O: 1`

  `T: 4`

  `L: 4`

  `J: 4`

  `S: 2`

  `Z: 2`

  `-------------`

  `Total: 19 distinct figures`


  

  ### **Representation in PostGIS:**


\-- SQL script to insert the 19 distinct Tetromino shapes into a PostGIS table

\-- 1\. Create the table  
CREATE TABLE tetromino\_shapes (  
    id SERIAL PRIMARY KEY,  
    name TEXT NOT NULL,  
    rotation INTEGER NOT NULL,  
    shape GEOMETRY(POLYGON, 4326\)  
);

\-- 2\. Insert the 19 distinct shapes  
INSERT INTO tetromino\_shapes (name, rotation, shape) VALUES

\-- I-Tetromino (1 shape)  
('I', 0, ST\_GeomFromText('POLYGON((0 0, 0 1, 4 1, 4 0, 0 0))', 4326)),

\-- O-Tetromino (1 shape)  
('O', 0, ST\_GeomFromText('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))', 4326)),

\-- T-Tetromino (4 rotations)  
('T', 0, ST\_GeomFromText('POLYGON((0 0, 0 1, 1 2, 2 2, 3 1, 3 0, 0 0))', 4326)),  
('T', 90, ST\_GeomFromText('POLYGON((1 \-1, 1 2, 2 1, 2 0, 1 \-1))', 4326)),  
('T', 180, ST\_GeomFromText('POLYGON((0 1, 0 2, 3 2, 3 1, 2 0, 1 0, 0 1))', 4326)),  
('T', 270, ST\_GeomFromText('POLYGON((0 \-1, 0 1, 1 2, 2 1, 2 \-1, 0 \-1))', 4326)),

\-- L-Tetromino (4 rotations)  
('L', 0, ST\_GeomFromText('POLYGON((0 0, 0 1, 3 1, 3 2, 1 2, 1 0, 0 0))', 4326)),  
('L', 90, ST\_GeomFromText('POLYGON((1 \-1, 1 2, 2 2, 3 0, 3 \-1, 1 \-1))', 4326)),  
('L', 180, ST\_GeomFromText('POLYGON((0 0, 2 0, 2 1, 1 1, 1 2, 0 2, 0 0))', 4326)),  
('L', 270, ST\_GeomFromText('POLYGON((0 0, 0 3, 1 3, 2 1, 2 0, 0 0))', 4326)),

\-- J-Tetromino (4 rotations)  
('J', 0, ST\_GeomFromText('POLYGON((0 0, 0 2, 1 2, 3 1, 3 0, 0 0))', 4326)),  
('J', 90, ST\_GeomFromText('POLYGON((1 \-1, 1 2, 3 2, 3 1, 2 1, 2 \-1, 1 \-1))', 4326)),  
('J', 180, ST\_GeomFromText('POLYGON((0 1, 0 2, 3 2, 3 0, 2 0, 2 1, 0 1))', 4326)),  
('J', 270, ST\_GeomFromText('POLYGON((0 \-1, 0 0, 2 0, 2 2, 1 2, 1 \-1, 0 \-1))', 4326)),

\-- S-Tetromino (1 shape)  
('S', 0, ST\_GeomFromText('POLYGON((0 0, 0 1, 1 1, 1 2, 3 2, 3 1, 2 1, 2 0, 0 0))', 4326)),

\-- Z-Tetromino (1 shape)  
('Z', 0, ST\_GeomFromText('POLYGON((0 1, 0 2, 2 2, 2 1, 3 1, 3 0, 1 0, 1 1, 0 1))', 4326));

3. ## Function to rotate a tetraminoe in POSTGIS

     
     
   SELECT ST\_Rotate(geom, pi()/2) FROM tetrominoes;  
     
   This rotates by \*\*90° counterclockwise\*\*.  
   

	

4. ## Representation of a puzzle

   ### **Grid-Based Representation of a Puzzle**

   Since tetrominoes fit into a \*\*grid system\*\*, the puzzle can be stored as a \*\*2D array\*\*, where numbers represent different tetrominoes:

   

   puzzle \= \[

       \[1, 1, 0, 0\],

       \[1, 1, 2, 2\],

       \[0, 3, 3, 2\],

       \[4, 4, 3, 2\]

   \]

   ### **Geospatial Representation of a puzzle**

   

   If storing a \*\*tetromino puzzle\*\* in a \*\*spatial database\*\* like PostGIS, you can define the full board as a \*\*MULTIPOLYGON\*\*:

   

   

   INSERT INTO puzzles (id, geom)

   VALUES (1, 

   ST\_GeomFromText('MULTIPOLYGON(

       ((0 0, 1 0, 1 1, 0 1, 0 0)), 

       ((2 0, 3 0, 3 1, 2 1, 2 0))

   )', 4326));

   

   Each polygon represents a \*\*tetromino piece\*\*.

   

## 5\. Puzzles with 1 of each tetraminoe, with 1 or 2 holes only

## 

Creating \*\*puzzles with one of each tetromino\*\* while allowing only \*\*one or two holes\*\* is an interesting tiling problem\! Here’s how you can represent and solve them:

### **Grid-Based Representation**

You can define a \*\*4x5 or 5x4 grid\*\*, ensuring each tetromino fits once while leaving 1-2 empty cells (holes). Example:  
\`\`\`  
T I I Z  
T J O Z  
T J O O  
L J S S  
L L S X  
\`\`\`  
\- \*\*X\*\* represents a \*\*hole\*\*.  
\- Each letter represents a different \*\*tetromino type\*\*.

### **Geospatial Representation**

In \*\*PostGIS\*\*, you can store the puzzle as a \*\*MULTIPOLYGON\*\*, with a separate polygon for each tetromino:  
\`\`\`sql  
INSERT INTO puzzles (id, geom)  
VALUES (1,   
ST\_GeomFromText('MULTIPOLYGON(  
    ((0 0, 1 0, 1 1, 0 1, 0 0)), \-- O-Tetromino  
    ((2 0, 3 0, 3 1, 2 1, 2 0)), \-- L-Tetromino  
    ((0 2, 1 2, 1 3, 0 3, 0 2))  \-- Hole  
)', 4326));  
\`\`\`  
Each tetromino is stored separately, ensuring \*\*1-2 gaps\*\* remain.

## 6\. Solver for Tetromino Puzzles

To find valid solutions:  
\- Use \*\*backtracking\*\* to place each tetromino.  
\- Ensure \*\*no overlapping\*\* and only \*\*1-2 empty spaces\*\*.  
\- Check \*\*rotation possibilities\*\* to fit the shapes.

To generate valid \*\*tetromino puzzles with exactly one of each tetromino and 1-2 holes\*\*, we need an algorithm that ensures:

* All 7 tetrominoes\*\* are placed    
* No overlaps\*\* between pieces    
* Exactly 1 or 2 empty cells\*\*    
* Valid grid sizes\*\*, such as \*\*4×5\*\* or \*\*5×4\*\*


  ### **Algorithm Approach**

  1\. \*\*Define Tetromino Shapes\*\* in a grid-based format.

  2\. \*\*Randomly Arrange Tetrominoes\*\* within a fixed-sized board.

  3\. \*\*Check for Overlapping\*\* using a collision detection method.

  4\. \*\*Leave 1-2 Empty Spaces\*\* in the puzzle.

  5\. \*\*Validate the Final Configuration\*\* before outputting a puzzle.

  ### **Exemplo de Algoritmo Recursivo**

  resolver\_puzzle(\[\], \_Grid).

  resolver\_puzzle(\[Peca|Resto\], Grid) :-

      colocar(Peca, Grid, NovoGrid),

      resolver\_puzzle(Resto, NovoGrid).

  Este código é apenas ilustrativo; a função `colocar/3` seria responsável por verificar colisões, ajustar rotações e atualizar o grid.

  ### **Python Code to Generate a Puzzle**

  Here’s an approach using backtracking


  import random


  \# Tetromino Shapes (4x5 board example)

  tetrominoes \= {

      "I": \[(0, 0), (1, 0), (2, 0), (3, 0)\],

      "O": \[(0, 0), (0, 1), (1, 0), (1, 1)\],

      "T": \[(0, 0), (1, 0), (2, 0), (1, 1)\],

      "L": \[(0, 0), (1, 0), (2, 0), (2, 1)\],

      "J": \[(0, 0), (1, 0), (2, 0), (0, 1)\],

      "S": \[(0, 0), (1, 0), (1, 1), (2, 1)\],

      "Z": \[(0, 1), (1, 1), (1, 0), (2, 0)\]

  }


  \# Grid size (4x5)

  grid \= \[\[None\] \* 5 for \_ in range(4)\]


  def place\_tetromino(name, shape):

      """Try to place a tetromino randomly in the grid."""

      for \_ in range(100):  \# Try multiple placements

          x\_offset \= random.randint(0, 3\)

          y\_offset \= random.randint(0, 4\)

          temp\_positions \= \[(x \+ x\_offset, y \+ y\_offset) for x, y in shape\]


          if all(0 \<= x \< 4 and 0 \<= y \< 5 and grid\[x\]\[y\] is None for x, y in temp\_positions):

              for x, y in temp\_positions:

                  grid\[x\]\[y\] \= name

              return True

      return False


  \# Place all tetrominoes

  placed\_tetrominoes \= 0

  for name, shape in tetrominoes.items():

      if place\_tetromino(name, shape):

          placed\_tetrominoes \+= 1


  \# Ensure exactly 1 or 2 holes remain

  empty\_cells \= \[(x, y) for x in range(4) for y in range(5) if grid\[x\]\[y\] is None\]

  while len(empty\_cells) \> 2:

      x, y \= empty\_cells.pop()

      grid\[x\]\[y\] \= random.choice(list(tetrominoes.keys()))  \# Fill randomly


  \# Print the final puzzle

  for row in grid:

      print(" ".join(cell if cell else "X" for cell in row))


  How It Works

  \*Randomly places each tetromino\*\*  

  \*Avoids overlaps\*\*  

  \*Leaves 1-2 gaps (X) for holes\*\*  

  \*Ensures a valid puzzle structure\*\*

