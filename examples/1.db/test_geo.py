from shapely.geometry import box
from shapely.ops import unary_union
from shapely.wkt import dumps as wkt_dumps

# Create square polygons
squares = [box(0, 0, 1, 1), box(0.5, 0.5, 1.5, 1.5)]

# Union them into a single geometry
poly = unary_union(squares)

# Convert to WKT
wkt = wkt_dumps(poly)

print(wkt)

# Output: POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0), (0.5 0.5, 0.5 1.5, 1.5 1.5, 1.5 0.5, 0.5 0.5))

