
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

SQL = """
SELECT name, geom
FROM tetrominoes
LIMIT 10;
"""

# === Connect to DB and fetch geometries ===
conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()

cur.execute(SQL)
rows = cur.fetchall()

fig, ax = plt.subplots()
for name, geom in rows:
    shapely_geom = wkb.loads(geom.tobytes())

    if isinstance(shapely_geom, (Polygon, MultiPolygon)):
        if isinstance(shapely_geom, Polygon):
            polys = [shapely_geom]
        else:
            polys = shapely_geom.geoms

        for poly in polys:
            x, y = poly.exterior.xy
            ax.fill(x, y, alpha=0.5, label=name)

plt.axis("equal")
plt.legend()
plt.title("Tetrominoes from PostGIS")
plt.show()

cur.close()
conn.close()
