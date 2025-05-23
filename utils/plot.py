# import psycopg2
# import matplotlib.pyplot as plt
# from shapely.wkt import loads as wkt_loads
# import matplotlib.patches as patches

# def plot_shapes():
#     conn = psycopg2.connect("dbname=giuseppepitruzzella user=giuseppepitruzzella password=postgres")
#     cur = conn.cursor()

#     # Carica tetromini
#     cur.execute("SELECT letter, color, ST_AsText(geom) FROM tetrominoes")
#     tetrominoes = cur.fetchall()

#     # Carica puzzle
#     cur.execute("SELECT name, ST_AsText(geom) FROM puzzles LIMIT 1")
#     puzzle = cur.fetchone()
#     conn.close()

#     fig, ax = plt.subplots()
    
#     # Disegna puzzle (contorno nero)
#     puzzle_shape = wkt_loads(puzzle[1])
#     ax.plot(*puzzle_shape.exterior.xy, color='black', linewidth=2, label=puzzle[0])

#     # Disegna tetromini
#     for letter, color, geom_wkt in tetrominoes:
#         shape = wkt_loads(geom_wkt)
#         patch = patches.Polygon(list(shape.exterior.coords), color=color, alpha=0.6, label=letter)
#         ax.add_patch(patch)

#     ax.set_title("Tetromini + Puzzle")
#     ax.set_aspect('equal')
#     ax.set_xlim(-1, 8)
#     ax.set_ylim(-1, 5)
#     ax.grid(True)
#     plt.legend()
#     plt.show()

# if __name__ == "__main__":
#     plot_shapes()
