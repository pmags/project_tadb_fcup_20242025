
# pre-req:


#sudo apt update

# Instala Python + pip + venv (caso ainda não tenha)
# sudo apt install -y python3 python3-pip python3-venv

# Instala bibliotecas de desenvolvimento necessárias para psycopg2
# sudo apt install -y python3-psycopg2 libpq-dev

# Instala Matplotlib
# sudo apt install -y python3-matplotlib

# Instala Shapely
# sudo apt install -y python3-shapely

import psycopg2
from shapely import wkb
from shapely.geometry import MultiPolygon, Polygon
import matplotlib.pyplot as plt

# Conexão com o PostgreSQL
conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="postgres",
    host="db",      # nome do serviço no docker-compose, por exemplo
    port="5432"
)

# Nome da tabela e coluna geom
TABLE_NAME = "sua_tabela"
GEOM_COLUMN = "geom"

def fetch_geometries():
    cur = conn.cursor()
    cur.execute(f"SELECT {GEOM_COLUMN} FROM {TABLE_NAME};")
    geometries = []

    for row in cur.fetchall():
        # PostGIS retorna o geom como bytes (WKB). Se estiver em hex, use hex=True
        geom = wkb.loads(row[0], hex=False)
        geometries.append(geom)

    cur.close()
    return geometries

def plot_geometries(geometries):
    fig, ax = plt.subplots()

    for geom in geometries:
        if isinstance(geom, Polygon):
            polygons = [geom]
        elif isinstance(geom, MultiPolygon):
            polygons = list(geom.geoms)
        else:
            continue  # Ignora outros tipos

        for poly in polygons:
            x, y = poly.exterior.xy
            ax.fill(x, y, alpha=0.6, edgecolor='black')

            for interior in poly.interiors:
                x_int, y_int = interior.xy
                ax.fill(x_int, y_int, color='white', edgecolor='black')

    ax.set_aspect('equal')
    plt.title("Visualização de MultiPolygons do PostGIS")
    plt.xlabel("Longitude")
    plt.ylabel("Latitude")
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    geoms = fetch_geometries()
    plot_geometries(geoms)
    conn.close()
