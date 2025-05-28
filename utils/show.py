import psycopg2
import time
import matplotlib.pyplot as plt
from shapely.wkt import loads as wkt_loads
import matplotlib.patches as patches

def plot_single_tetromino(letter, color, geom_wkt):
    poly = wkt_loads(geom_wkt)
    fig, ax = plt.subplots()
    patch = patches.Polygon(list(poly.exterior.coords), color=color, alpha=0.7)
    ax.add_patch(patch)
    ax.set_title(f"Tetromino {letter}")
    ax.set_xlim(-1, 6)
    ax.set_ylim(-1, 6)
    ax.set_aspect('equal')
    ax.grid(True)
    plt.draw()
    plt.pause(1)  # Mostra per 1 secondo
    plt.close()

def show_tetrominoes():
    conn = psycopg2.connect("dbname=postgres user=postgres password=postgres")
    cur = conn.cursor()
    cur.execute("SELECT letter, color, ST_AsText(geom) FROM tetrominoes ORDER BY letter")
    tetrominoes = cur.fetchall()
    conn.close()

    for letter, color, geom in tetrominoes:
        plot_single_tetromino(letter, color, geom)

if __name__ == "__main__":
    show_tetrominoes()
