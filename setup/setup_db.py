import psycopg2
import time
from shapely.geometry import Polygon
from shapely.ops import unary_union
from shapely.wkt import dumps as wkt_dumps

def square(x, y):
    return Polygon([(x, y), (x + 1, y), (x + 1, y + 1), (x, y + 1)])

def get_tetrominoes():
    tetrominoes = {
        'I': [square(0, 0), square(1, 0), square(2, 0), square(3, 0)],
        'O': [square(0, 0), square(1, 0), square(0, 1), square(1, 1)],
        'T': [square(0, 0), square(1, 0), square(2, 0), square(1, 1)],
        'J': [square(0, 0), square(0, 1), square(1, 1), square(2, 1)],
        'L': [square(2, 0), square(0, 1), square(1, 1), square(2, 1)],
        'S': [square(1, 0), square(2, 0), square(0, 1), square(1, 1)],
        'Z': [square(0, 0), square(1, 0), square(1, 1), square(2, 1)],
    }
    return tetrominoes

def wait_for_db():
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

def setup_db():
    wait_for_db()

    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="postgres",
        host="db"
    )
    cur = conn.cursor()

    
    cur.execute("""
    CREATE EXTENSION IF NOT EXISTS postgis;

    CREATE TABLE IF NOT EXISTS tetrominoes (
        id SERIAL PRIMARY KEY,
        letter CHAR(1),
        color TEXT,
        geom geometry(POLYGON, 4326)
    );

    CREATE TABLE IF NOT EXISTS puzzles (
        id SERIAL PRIMARY KEY,
        name TEXT,
        geom geometry(POLYGON, 4326)
    );

    CREATE TABLE IF NOT EXISTS solutions (
        id SERIAL PRIMARY KEY,
        puzzle_id INT REFERENCES puzzles(id),
        tetromino_id INT REFERENCES tetrominoes(id),
        geom geometry(POLYGON, 4326)
    );
    """)

    # === Inserisce i tetromini ===
    colors = {
        'I': 'cyan', 'O': 'yellow', 'T': 'purple',
        'J': 'blue', 'L': 'orange', 'S': 'green', 'Z': 'red'
    }

    tetrominoes = get_tetrominoes()
    for letter, squares in tetrominoes.items():
        poly = unary_union(squares)
        wkt = wkt_dumps(poly)
        cur.execute("""
            INSERT INTO tetrominoes (letter, color, geom)
            VALUES (%s, %s, ST_GeomFromText(%s, 4326))
            ON CONFLICT DO NOTHING;
        """, (letter, colors[letter], wkt))

    
    puzzle = unary_union([square(x, y) for y in range(4) for x in range(7)])
    cur.execute("""
        INSERT INTO puzzles (name, geom)
        VALUES (%s, ST_GeomFromText(%s, 4326))
        ON CONFLICT DO NOTHING;
    """, ("Puzzle 1", wkt_dumps(puzzle)))

    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    setup_db()
