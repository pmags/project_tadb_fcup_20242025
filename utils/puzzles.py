import psycopg2
from shapely.geometry import Polygon
from shapely.ops import unary_union
from shapely.wkt import dumps as wkt_dumps
from utils.db import connect_db

## This functions repeat some of the logic built for setup_db. Probably needs to be dry. TODO

def _square(x, y):
    return Polygon([(x, y), (x + 1, y), (x + 1, y + 1), (x, y + 1)])

def _generate_puzzle(puzzle_id:int, width:int, height:int, num_holes:int=0) -> dict:
    """
    Generate a puzzle with the given ID, width, and height.
    The puzzle is a grid of squares.
    """
    import random
    squares = [_square(x, y) for y in range(width) for x in range(height)]
        
    if num_holes > 0:
        random_holes = random.sample(squares, num_holes)
        print(random_holes)
        squares = [s for s in squares if s not in random_holes]
        print(squares)
    
    geom = unary_union(squares)
    
    return {
        'puzzle_id': puzzle_id,
        'squares': squares,
        'geom': wkt_dumps(geom),
        'width': width,
        'height': height
    }
   
    
def _upload_puzzle_to_db(puzzle_id:int, puzzle_name:str, geom:wkt_dumps) -> bool:
    """uplaods the puzzle to the database"""
    conn = connect_db()
    cur = conn.cursor()
    
    try: 
        cur.execute("""
                    INSERT INTO puzzles (id, name, geom)
                    VALUES (%s, %s, ST_GeomFromText(%s, 4326))
                    ON CONFLICT (id) DO UPDATE SET
                        name = EXCLUDED.name,
                        geom = EXCLUDED.geom;
                """, (puzzle_id, puzzle_name, geom))
        
        conn.commit()
        print("✅ Puzzle examples inserted successfully!")
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Error inserting puzzle examples: {e}")
        cur.close()
        conn.close()
        return False  

def puzzle_generator(puzzle_id: int, width: int, height: int, num_holes: int) -> bool:
    """
    Generate a puzzle with the given ID, width, and height.
    The puzzle is a grid of squares.
    
    Args:
        puzzle_id (int): The ID of the puzzle.
        width (int): The width of the puzzle in squares.
        height (int): The height of the puzzle in squares.
    
    Returns:
        Polygon: A Shapely Polygon representing the puzzle.
    """
    try:
        # Generate the puzzle
        new_puzzle = _generate_puzzle(puzzle_id, width, height, num_holes)
        
        # Upload the puzzle to the database
        return _upload_puzzle_to_db(new_puzzle['puzzle_id'], f"Puzzle {new_puzzle['puzzle_id']}", new_puzzle['geom'])
    except Exception as e:
        print(f"Error generating puzzle: {e}")
        return False
    
    