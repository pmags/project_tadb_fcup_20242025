
import sys
from shapely import wkt
import matplotlib.pyplot as plt
from shapely.geometry import Polygon, MultiPolygon, GeometryCollection

def plot_geometry(geom, title=None):
    fig, ax = plt.subplots()

    if isinstance(geom, (Polygon, MultiPolygon)):
        try:
            for polygon in getattr(geom, 'geoms', [geom]):
                x, y = polygon.exterior.xy
                ax.fill(x, y, alpha=0.5, edgecolor='black')
        except Exception as e:
            print("Erro ao desenhar:", e)
    elif isinstance(geom, GeometryCollection):
        for g in geom.geoms:
            plot_geometry(g)
    else:
        print("Tipo de geometria não suportado:", type(geom))

    ax.set_aspect("equal")
    if title:
        plt.title(f"Tetrominó: {title}")
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python3 test_wkt_plot.py '<WKT>' ['<title>']")
        sys.exit(1)

    wkt_string = sys.argv[1]
    title = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        geometry = wkt.loads(wkt_string)
        plot_geometry(geometry, title=title)
    except Exception as e:
        print("Erro ao carregar o WKT:", e)
