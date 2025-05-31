# plot_wkt.py
import sys
from shapely import wkt
import matplotlib.pyplot as plt
from shapely.geometry import Polygon, MultiPolygon

def plot_wkt(wkt_string):
    geom = wkt.loads(wkt_string)
    fig, ax = plt.subplots()
    
    def plot_polygon(poly):
        x, y = poly.exterior.xy
        ax.fill(x, y, alpha=0.5, fc='blue', ec='black')
        for interior in poly.interiors:
            ix, iy = interior.xy
            ax.fill(ix, iy, alpha=1.0, fc='white')
    
    if geom.geom_type == 'Polygon':
        plot_polygon(geom)
    elif geom.geom_type == 'MultiPolygon':
        for poly in geom.geoms:
            plot_polygon(poly)
    else:
        print(f'Geometry type {geom.geom_type} not supported.')
        return
    
    ax.set_aspect('equal')
    plt.title('WKT Geometry Plot')
    plt.show()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        wkt_string = sys.argv[1]
        plot_wkt(wkt_string)
    else:
        print("Usage: python plot_wkt.py '<WKT_STRING>'")
