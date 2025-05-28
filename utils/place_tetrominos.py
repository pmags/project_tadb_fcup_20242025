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
    solution_id: int, 
    puzzle_id: int,
    dx: int, 
    dy:int , 
    orientation:str ='Flat down') -> bool:
    
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
                LOWER(t.letter) = %s;     
    """
    
    try: 
        cur.execute(query, (solution_id, puzzle_id, radians, dx, dy, tetromino.lower()))
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
