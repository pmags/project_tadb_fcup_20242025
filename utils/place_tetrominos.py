# Following convetion to describe each tetromino orientation and placement
# Flat down 	
# Flat left 	
# Flat up 	
# Flat right 
# tetris.wiki/Tetromino

import psycopg2
from utils.db import connect_db

def place_tetrominoes(
    tetromino: str,
    var_id: int,
    solution_id: int, 
    puzzle_id: int,
    dx: int, 
    dy:int , 
    orientation:str ='Flat down') -> bool:
    
    """Places a tetromino in the database with the specified parameters.
    Args:
        tetromino (str): The letter representing the tetromino (e.g., 'I', 'O', 'T', 'S', 'Z', 'J', 'L').
        solution_id (int): The ID of the solution to which this tetromino belongs.
        puzzle_id (int): The ID of the puzzle in which the tetromino is placed.
        dx (int): The x-coordinate offset for placing the tetromino.
        dy (int): The y-coordinate offset for placing the tetromino.
        orientation (str): The orientation of the tetromino. Defaults to 'Flat down'.
    Returns:
        bool: True if the tetromino was successfully placed, False otherwise.
    """ 
    
    conn = connect_db()
    cur = conn.cursor()
    
    match orientation:
        case 'Flat down':
            radians = 0
        case 'Flat left':
            radians = 90
        case 'Flat up':
            radians = 180
        case 'Flat right':
            radians = 270
        case _:
            print(f"Unknown orientation: {orientation}")
            cur.close()
            conn.close()
            return False
    
    query = """
    INSERT INTO solutions (solution_id, puzzle_id, tetromino_id, geom)
            SELECT
                %s AS solution_id,
                %s AS puzzle_id, 
                t.id,
                ST_Translate(
                    ST_Rotate(t.geom, RADIANS(%s), ST_MakePoint(0,0)), 
                    %s, 
                    %s
                )
            FROM
                tetrominoes AS t
            WHERE
                LOWER(t.letter) = %s
                AND var_id = %s;     
    """
    
    try: 
        cur.execute(query, (solution_id, puzzle_id, radians, dx, dy, tetromino.lower(), var_id))
        conn.commit()
        cur.close()
        conn.close()
        return True

    
    except psycopg2.Error as e:
        print(f"Error placing I tetrominoes: {e}")
        cur.close()
        conn.close()
        return False
    
if __name__ == "__main__":
    pass
