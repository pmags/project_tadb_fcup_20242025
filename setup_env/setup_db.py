import sys
sys.path.append("/workspaces/project_tadb_fcup_20242025")

import psycopg2
import time
from shapely.geometry import Polygon
from shapely.ops import unary_union
from shapely.wkt import dumps as wkt_dumps
from utils import show_tetrominoes
from utils.db import connect_db
from utils.place_tetrominos import place_tetrominoes

# private methods
def _square(x, y):
    return Polygon([(x, y), (x + 1, y), (x + 1, y + 1), (x, y + 1)])

def _get_tetrominoes():
    tetrominoes = [
        {'letter': 'I', 'var_id': 1, 'squares': [_square(0, 0), _square(1, 0), _square(2, 0), _square(3, 0)]}, 
        {'letter': 'I', 'var_id': 2, 'squares': [_square(0, 0), _square(0, 1), _square(0, 2), _square(0, 3)]},
        
        {'letter': 'O', 'var_id': 1, 'squares': [_square(0, 0), _square(1, 0), _square(0, 1), _square(1, 1)]},
        
        
        {'letter': 'T', 'var_id': 1, 'squares': [_square(0, 1), _square(1, 1), _square(2, 1), _square(1, 0)]},
        {'letter': 'T', 'var_id': 2, 'squares': [_square(1, 0), _square(1, 1), _square(1, 2), _square(0, 1)]},
        {'letter': 'T', 'var_id': 3, 'squares': [_square(0, 1), _square(1, 1), _square(2, 1), _square(1, 0)]},
        {'letter': 'T', 'var_id': 4, 'squares': [_square(1, 0), _square(1, 1), _square(1, 2), _square(2, 1)]},
        
        {'letter': 'J', 'var_id': 1, 'squares': [_square(0,2), _square(0,1), _square(1,1), _square(2,1)]},
        {'letter': 'J', 'var_id': 2, 'squares': [_square(2,2), _square(1,2), _square(1,1), _square(1,0)]},
        {'letter': 'J', 'var_id': 3, 'squares': [_square(2,0), _square(2,1), _square(1,1), _square(0,1)]},
        {'letter': 'J', 'var_id': 4, 'squares': [_square(0,0), _square(1,0), _square(1,1), _square(1,2)]},
        
        {'letter': 'L', 'var_id': 1, 'squares': [_square(2,2), _square(2,1), _square(1,1), _square(0,1)]},
        {'letter': 'L', 'var_id': 2, 'squares': [_square(2,0), _square(1,0), _square(1,1), _square(1,2)]},
        {'letter': 'L', 'var_id': 3, 'squares': [_square(0,0), _square(0,1), _square(1,1), _square(2,1)]},
        {'letter': 'L', 'var_id': 4, 'squares': [_square(0,2), _square(1,2), _square(1,1), _square(1,0)]},    
        
        {'letter': 'S', 'var_id': 1, 'squares': [_square(2,2), _square(1,2), _square(1,1), _square(0,1)]},
        {'letter': 'S', 'var_id': 2, 'squares': [_square(1,2), _square(1,1), _square(2,1), _square(2,0)]},
        
        {'letter': 'Z', 'var_id': 1, 'squares': [_square(0,2), _square(1,2), _square(1,1), _square(2,1)]},
        {'letter': 'Z', 'var_id': 2, 'squares': [_square(2,2), _square(2,1), _square(1,1), _square(1,0)]}
    ]
    return tetrominoes

def _wait_for_db():
    while True:
        try:
            conn = psycopg2.connect(
                dbname="postgres",
                user="postgres",
                password="postgres",
                host="db"  # importante: deve essere il nome del servizio docker-compose
            )
            conn.close()
            print("✅ Database disponibile!")
            break
        except psycopg2.OperationalError:
            print("⏳ Attesa del database...")
            time.sleep(1)

def connect_db(dbname: str = "postgres", user: str = "postgres", password: str = "postgres", host: str = "db" ) -> psycopg2.extensions.connection:
    return psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host
    )

def _create_db_and_tables() -> bool:
    
    conn = connect_db()
    cur = conn.cursor()
    
    try:   
        cur.execute("""
        CREATE EXTENSION IF NOT EXISTS postgis;

        DROP TABLE IF EXISTS tetrominoes CASCADE;
        CREATE TABLE IF NOT EXISTS tetrominoes (
            id SERIAL PRIMARY KEY,
            letter CHAR(1),
            var_id INT,
            color TEXT,
            geom geometry(POLYGON, 4326)
        );

        DROP TABLE IF EXISTS puzzles CASCADE;
        CREATE TABLE IF NOT EXISTS puzzles (
            id SERIAL PRIMARY KEY,
            name TEXT,
            geom geometry(POLYGON, 4326)
        );

        DROP TABLE IF EXISTS solutions CASCADE;
        CREATE TABLE IF NOT EXISTS solutions (
            id SERIAL PRIMARY KEY,
            solution_id INT,
            puzzle_id INT REFERENCES puzzles(id),
            tetromino_id INT REFERENCES tetrominoes(id),
            geom geometry(MULTIPOLYGON, 4326)
        );
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("✅ Database schemas created successfully!")
        return True
    
    except Exception as e:
        print(f"Error found during creation of initial tables schema {e}")
        cur.close()
        conn.close()
        return False    
    
def _insert_tetrominoes_into_db() -> bool:
    
    conn = connect_db()
    cur = conn.cursor()
    
    try:
        colors = {
            'I': 'cyan', 'O': 'yellow', 'T': 'purple',
            'J': 'blue', 'L': 'orange', 'S': 'green', 'Z': 'red'
        }
        
        tetrominoes = _get_tetrominoes()
        #for letter, squares in tetrominoes.items():
        for item in tetrominoes:
            letter = item['letter']
            squares = item['squares']
            var_id = item['var_id']
            
            poly = unary_union(squares)
            wkt = wkt_dumps(poly)
            cur.execute("""
                INSERT INTO tetrominoes (letter, var_id, color, geom)
                VALUES (%s, %s, %s, ST_GeomFromText(%s, 4326))
                ON CONFLICT DO NOTHING;
            """, (letter, var_id, colors[letter], wkt))
        conn.commit()
        print("✅ Tetrominoes inserted successfully!")
        cur.close()
        conn.close()
        return True
    
    except psycopg2.Error as e:
        print(f"Error connecting to the database: {e}")
        cur.close()
        conn.close()
        return False

def _insert_puzzle_examples_into_db() -> bool:
    
    conn = connect_db()
    cur = conn.cursor()
    
    try:
        # Generates 3 different puzzle examples
        puzzle1_geom = unary_union([_square(x, y) for y in range(6) for x in range(5)])
        puzzle2_geom = unary_union([_square(x, y) for y in range(3) for x in range(10)])
        puzzle3_geom = unary_union([_square(x, y) for y in range(8) for x in range(4)])
        
        puzzles_list = [
            (1, "Example puzzle (5x6)", wkt_dumps(puzzle1_geom)), 
            (2, "Example puzzle (10x3)", wkt_dumps(puzzle2_geom)), 
            (3, "Example puzzle (4x8)", wkt_dumps(puzzle3_geom))    
        ]
        
        for id, name, geom in puzzles_list:
            cur.execute("""
                INSERT INTO puzzles (id, name, geom)
                VALUES (%s, %s, ST_GeomFromText(%s, 4326))
                ON CONFLICT DO NOTHING;
            """, (id, name, geom))
        
        conn.commit()
        print("✅ Puzzle examples inserted successfully!")
        cur.close()
        conn.close()
        return True
    
    except psycopg2.Error as e:
        print(f"Error inserting puzzle examples into the database: {e}")
        cur.close()
        conn.close()
        return False

def _insert_puzzle_example_solutions_into_db() -> bool:
    
    ## First puzzle example
    try:
        place_tetrominoes(tetromino='I', var_id = 1, solution_id= 1, puzzle_id= 1, dx= 5, dy= 0, orientation = 'Flat left')  # I tetromino
        place_tetrominoes(tetromino='O', var_id = 1, solution_id= 1, puzzle_id= 1, dx= 3, dy= 4, orientation = 'Flat down')  # O tetromino
        place_tetrominoes(tetromino='T', var_id = 4, solution_id= 1, puzzle_id= 1, dx= -1, dy= 0, orientation = 'Flat down')  # T tetromino
        place_tetrominoes(tetromino='J', var_id = 3, solution_id= 1, puzzle_id= 1, dx= 0, dy= 4, orientation = 'Flat down')  # J tetromino
        place_tetrominoes(tetromino='L', var_id = 1, solution_id= 1, puzzle_id= 1, dx= 1, dy= -1, orientation = 'Flat down')  # L tetromino
        place_tetrominoes(tetromino='S', var_id = 2, solution_id= 1, puzzle_id= 1, dx= -1, dy= 2, orientation = 'Flat down')  # S tetromino 
        place_tetrominoes(tetromino='Z', var_id = 2, solution_id= 1, puzzle_id= 1, dx= 1, dy= 1, orientation = 'Flat down')  # Z tetromino
           
    except Exception as e:
        print(f"Error inserting puzzle solutions into the database: {e}")
        return False

    ## Second puzzle example
    try:
        place_tetrominoes(tetromino='I',var_id = 1,solution_id= 1, puzzle_id= 2, dx= 1, dy= 0, orientation = 'Flat down')  # I tetromino
        place_tetrominoes(tetromino='O',var_id = 1,solution_id= 1, puzzle_id= 2, dx= 8, dy= 0, orientation = 'Flat down')  # O tetromino
        place_tetrominoes(tetromino='T',var_id = 4,solution_id= 1, puzzle_id= 2, dx= -1, dy= 0, orientation = 'Flat down')  # T tetromino
        place_tetrominoes(tetromino='J',var_id = 1,solution_id= 1, puzzle_id= 2, dx= 5, dy= -1, orientation = 'Flat down')  # J tetromino
        place_tetrominoes(tetromino='L',var_id = 3,solution_id= 1, puzzle_id= 2, dx= 4, dy= 1, orientation = 'Flat down')  # L tetromino
        place_tetrominoes(tetromino='S',var_id = 1,solution_id= 1, puzzle_id= 2, dx= 6, dy= 0, orientation = 'Flat down')  # S tetromino 
        place_tetrominoes(tetromino='Z',var_id = 1,solution_id= 1, puzzle_id= 2, dx= 1, dy= 0, orientation = 'Flat down')  # Z tetromino
    
    except Exception as e:
        print(f"Error inserting puzzle solutions into the database: {e}")
        return False

    ## Third puzzle example
    try:
        place_tetrominoes(tetromino='I',var_id = 2,solution_id= 1, puzzle_id= 3, dx= 1, dy= 2, orientation = 'Flat down')  # I tetromino
        place_tetrominoes(tetromino='O',var_id = 1,solution_id= 1, puzzle_id= 3, dx= 2, dy= 4, orientation = 'Flat down')  # O tetromino
        place_tetrominoes(tetromino='T',var_id = 4,solution_id= 1, puzzle_id= 3, dx= -1, dy= 0, orientation = 'Flat down')  # T tetromino
        place_tetrominoes(tetromino='J',var_id = 2,solution_id= 1, puzzle_id= 3, dx=-1, dy= 5, orientation = 'Flat down')  # J tetromino
        place_tetrominoes(tetromino='L',var_id = 1,solution_id= 1, puzzle_id= 3, dx= 1, dy= -1, orientation = 'Flat down')  # L tetromino
        place_tetrominoes(tetromino='S',var_id = 1,solution_id= 1, puzzle_id= 3, dx= 1, dy= 5, orientation = 'Flat down')  # S tetromino 
        place_tetrominoes(tetromino='Z',var_id = 2,solution_id= 1, puzzle_id= 3, dx= 1, dy= 1, orientation = 'Flat down')  # Z tetromino
        
    
    except Exception as e:
        print(f"Error inserting puzzle solutions into the database: {e}")
        return False

    print("✅ Example solutions uploaded successfully!")
    return True

# main method
def setup_db():
    
    _wait_for_db()
    
    # Create initial tables (uses default postgres database)
    if not _create_db_and_tables():
        print("❌ Failed to create DB and tables. Aborting setup.")
        return
    
    # Insert tetrominoes
    if not _insert_tetrominoes_into_db():
        print("❌ Failed to insert tetrominoes. Aborting setup.")
        return
    
    # Insert initial puzzle examples
    if not _insert_puzzle_examples_into_db():
        print("❌ Failed to insert puzzle examples. Aborting setup.")
        return
    
    # Insert initial puzzle solutions
    if not _insert_puzzle_example_solutions_into_db():
        print("❌ Failed to insert puzzle solutions. Aborting setup.")
        return
    
    print("✅ Database setup completed.")

if __name__ == "__main__":
    setup_db()
