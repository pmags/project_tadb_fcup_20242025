import os
import typing as t
from typing_extensions import TypeAlias
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
import matplotlib.patches as patches
from shapely.wkt import loads as wkt_loads

StrPath: TypeAlias = t.Union[str, os.PathLike]

def plot_geometry(ax: Axes, geom: str, color: str, title: str) -> Axes:
    """ Plots a postgis geometry on a matplotlib Axes. By ploting into an axis it can then uses with matplotlib subplot to create a grid of plots.
    
    example:
    ```python
    fig, axes = plt.subplots(2, 2, figsize=(10, 10))
    plot_geometry(axes[0, 0], "POINT(1 1)")
    ```

    Args:
        ax (matplotlib.axes.Axes): The Axes object to plot on.
        geom (str): The geometry in Well-Known Text format.
        color (str): The color to use for the geometry.
        title (str): The title for the plot.

    Returns:
        matplotlib.axes.Axes: The Axes object that was plotted on.
    """
    
    poly = wkt_loads(geom)
    patch = patches.Polygon(
        list(poly.exterior.coords), 
        color=color, 
        alpha=0.7
    )
    ax.add_patch(patch)
    ax.set_title(title)
    minx, miny, maxx, maxy = poly.bounds
    ax.set_xlim(minx - 0.5, maxx + 0.5)
    ax.set_ylim(miny - 0.5, maxy + 0.5)
    ax.xaxis.set_major_locator(plt.MultipleLocator(1))
    ax.yaxis.set_major_locator(plt.MultipleLocator(1))
    ax.set_aspect("equal")
    ax.grid(True, color="lightGray", linestyle="--", linewidth=0.5)
    
    return ax

def plot_solutions(solution_id: int, puzzle_id: int, ax:Axes, tite: str) -> Axes:
    
    # 1. fetch solution from db
    # 2. ploy as list of polygos by converting the wkt to shapely polygons
    # 3. create patches for each polygon
    # 4. add patches to the axis
    # 5. export axis
    
    query = """
    SELECT 
        *
    FROM solutions
    WHERE solution_id = %s AND puzzle_id = %s;
    """
    pass
    

def export_geometry(ax: Axes, geom: str, color: str, title: str, path: StrPath) -> bool:
    
    if path is None:
        raise ValueError("Missing path to save the plot.")
        return False
     
    try:
        save_path = Path(path).resolve()
        fig, ax = plt.subplots()
        plot_geometry(ax = ax, geom=geom, color=color, title=title)
        plt.savefig(path)
        plt.close(fig)
        return True

    except Exception as e:
        print(f"Error saving plot to {path}: {e}")
        return False                  
    


if __name__ == "__main__":
    pass # block run as script


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
