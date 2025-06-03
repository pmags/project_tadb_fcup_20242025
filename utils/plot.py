import os
import typing as t
from typing_extensions import TypeAlias
from pathlib import Path
from matplotlib.path import Path
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
import matplotlib.patches as patches
from matplotlib import cm
from matplotlib.patches import PathPatch
from shapely.wkt import loads as wkt_loads
from utils.db import connect_db
from shapely.geometry import Polygon, MultiPolygon
import numpy as np

StrPath: TypeAlias = t.Union[str, os.PathLike]

def plot_geometry(ax: Axes, geom: str, title: str, color: str = "Blue", is_solution: bool = False) -> Axes:
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
    
    if isinstance(poly, Polygon):
        # This is needed in order to render puzzles with holes correctly. Previous version only took into account the exterior ring which works for tetrominoes but not for puzzles with holes.
        
        exterior_coords = np.asarray(poly.exterior.coords)
        interior_coords_list = [np.asarray(interior.coords) for interior in poly.interiors]
        
        all_coords = [exterior_coords] + interior_coords_list
        vertices = np.concatenate(all_coords)
            
        codes = []
        for coords in all_coords:
            n = len(coords)
            ring_codes = np.ones(n, dtype=Path.code_type) * Path.LINETO
            ring_codes[0] = Path.MOVETO
            # Ensure the polygon is closed for matplotlib if not already
            if not np.array_equal(coords[0], coords[-1]):
                ring_codes[-1] = Path.CLOSEPOLY
            codes.append(ring_codes)
        all_codes = np.concatenate(codes)
        
        path = Path(vertices, all_codes)
        patch = PathPatch(
            path,
            color=color,
            alpha=0.7)
        
        ax.add_patch(patch)
        ax.set_title(title)
        minx, miny, maxx, maxy = poly.bounds
        if not is_solution:
            ax.set_xlim(minx - 0.5, maxx + 0.5)
            ax.set_ylim(miny - 0.5, maxy + 0.5)
        ax.xaxis.set_major_locator(plt.MultipleLocator(1))
        ax.yaxis.set_major_locator(plt.MultipleLocator(1))
        ax.set_aspect("equal")
        ax.grid(True, color="lightGray", linestyle="--", linewidth=0.5)
        
        return ax
    
    elif isinstance(poly, MultiPolygon):
        # If geometry is a multipolygon, we can handle it similarly
        # we will color then with random from tab10
        
        num_geoms = len(poly.geoms)
        colormap = cm.get_cmap('tab10', num_geoms if num_geoms <= 10 else 10)
        
        for i, geom in enumerate(poly.geoms):
            xs, ys = geom.exterior.xy
            geom_color = colormap(i % colormap.N)
            ax.fill(xs, ys, 
                    color=geom_color, 
                    alpha=0.7)
        
        ax.set_title(title)
        minx, miny, maxx, maxy = poly.bounds
        if not is_solution:
            ax.set_xlim(minx - 0.5, maxx + 0.5)
            ax.set_ylim(miny - 0.5, maxy + 0.5)
        ax.xaxis.set_major_locator(plt.MultipleLocator(1))
        ax.yaxis.set_major_locator(plt.MultipleLocator(1))
        ax.set_aspect("equal")
        ax.grid(True, color="lightGray", linestyle="--", linewidth=0.5)
        
        return ax
    
    else:
        exception_msg = f"Unsupported geometry type: {type(poly)}. Only Polygon and MultiPolygon are supporteds."
        raise TypeError(exception_msg)
              

def plot_solutions(ax: Axes, puzzle_id:int, title: str, solution_id:int = 1) -> Axes:
    """Plots the solution of a given puzzle on the provided matplotlib axis.
    This function fetches the solution for a specific puzzle and solution ID from the database,
    converts the geometries from WKT to shapely polygons, and visualizes the puzzle and its solution
    using colored patches for each tetromino.
        ax (Axes): Matplotlib axis to plot on.
        puzzle_id (int): The ID of the puzzle to visualize.
        title (str): Title for the plot.
        solution_id (int, optional): The ID of the solution to plot. Defaults to 1.
        Axes: The matplotlib axis with the plotted puzzle and solution.
    """
    
    # 1. fetch solution from db
    # 2. ploy as list of polygos by converting the wkt to shapely polygons
    # 3. create patches for each polygon
    # 4. add patches to the axis
    # 5. export axis
    
    conn = connect_db()
    cur = conn.cursor()
    
    overall_min_x, overall_min_y = float('inf'), float('inf')
    overall_max_x, overall_max_y = float('-inf'), float('-inf')
    
    query = """
        SELECT
            solutions.solution_id,
            solutions.puzzle_id,
            ST_AsText(solutions.geom) AS geom,
            ST_AsText(puzzles.geom) AS puzzle_geom
        FROM solutions
        LEFT JOIN puzzles ON solutions.puzzle_id = puzzles.id
        WHERE solution_id = %s AND puzzle_id = %s;
        """
        
    try:
        cur.execute(query, (solution_id, puzzle_id))
        solution = cur.fetchall()
        cur.close()
        conn.close()
    
    except Exception as e:
        print(f"Error fetching solution: {e}")
        return None
    
    # Plot solutions
    # start by plotting puzzle background
    puzzle_ax = plot_geometry(ax, geom=solution[0][3], color="lightgray", title="", is_solution=False)
    
    poly = wkt_loads(solution[0][3])
    minx, miny, maxx, maxy = poly.bounds
    overall_min_x = min(overall_min_x, minx)
    overall_min_y = min(overall_min_y, miny)
    overall_max_x = max(overall_max_x, maxx)
    overall_max_y = max(overall_max_y, maxy)
   
    # plot each solution geometry 
    for solution_id, puzzle_id, geom, puzzle_geom in solution:
        ax = plot_geometry(puzzle_ax, geom=geom, color="blue", title="", is_solution=False)
    
    ax.set_title(title)
    ax.set_xlim(overall_min_x - 0.5, overall_max_x + 0.5)
    ax.set_ylim(overall_min_y - 0.5, overall_max_y + 0.5)
    
    ax.xaxis.set_major_locator(plt.MultipleLocator(1))
    ax.yaxis.set_major_locator(plt.MultipleLocator(1))
    ax.set_aspect("equal")
    ax.grid(True, color="lightGray", linestyle="--", linewidth=0.5)
    
    return ax
    

def export_geometry(ax: Axes, geom: str, color: str, title: str, path: StrPath) -> bool:
    """
    Exports a geometry plot to a file.
    This function creates a new figure and axis, plots the provided geometry with the 
    specified color and title, and then saves the figure to the specified path.
    Parameters
    ----------
    ax : Axes
        Matplotlib axes object (not used in current implementation as a new figure is created)
    geom : str
        Geometry string in WKT or other supported format
    color : str
        Color to use for the geometry
    title : str
        Title of the plot
    path : StrPath
        Path where the plot should be saved
    Returns
    -------
    bool
        True if the plot was successfully saved, False otherwise
    Raises
    ------
    ValueError
        If the path parameter is None
    """
    
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