import psycopg2
import time
import matplotlib.pyplot as plt
from shapely.wkt import loads as wkt_loads
import matplotlib.patches as patches
import os  # Import the os module to manage directories

# Set a non-interactive backend for Matplotlib, suitable for saving figures to files
# This is important because in a non-GUI environment (like a standard Docker container),
# interactive backends would cause errors or simply do nothing.
plt.switch_backend('Agg')

def plot_single_tetromino(letter, color, geom_wkt, output_dir):
    """Plots a single tetromino and saves it as an image file."""
    poly = wkt_loads(geom_wkt)
    fig, ax = plt.subplots()

    patch = patches.Polygon(list(poly.exterior.coords), color=color, alpha=0.7)
    ax.add_patch(patch)

    ax.set_title(f"Tetromino {letter}")
    # Adjust the limits to ensure the entire tetromino is visible
    # These limits might need to be adjusted based on the exact shapes
    minx, miny, maxx, maxy = poly.bounds
    ax.set_xlim(minx - 0.5, maxx + 0.5)
    ax.set_ylim(miny - 0.5, maxy + 0.5)
    ax.set_aspect('equal')
    ax.grid(True)

    # Construct the file name
    filename = f"Tetromino_{letter}.png"
    filepath = os.path.join(output_dir, filename)

    # Save the figure instead of displaying it
    plt.savefig(filepath)
    print(f"Plot for Tetromino {letter} saved in {filepath}")

    # Close the figure to free up memory
    plt.close(fig)  # Close the specific figure

def show_tetrominoes():
    """Fetches tetromino data from the database and plots/saves each one."""
    # Define the directory where renders will be saved
    render_dir = "renders"

    # Create the 'renders' directory if it doesn't exist
    # os.makedirs also creates intermediate directories if necessary
    # exist_ok=True avoids an error if the directory already exists
    os.makedirs(render_dir, exist_ok=True)
    print(f"Output directory '{render_dir}' ensured.")

    conn = None  # Initialize conn to None
    try:
        # Connect to the database (the hostname 'db' works thanks to docker-compose)
        # Add a connection timeout in case the DB is not ready
        conn = psycopg2.connect(
            dbname="postgres",
            user="postgres",
            password="postgres",
            host="db",
            connect_timeout=10  # Connection timeout in seconds
        )
        cur = conn.cursor()

        # Check if the table exists before querying
        cur.execute("SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tetrominoes');")
        table_exists = cur.fetchone()[0]

        if not table_exists:
            print("Error: the 'tetrominoes' table does not exist in the database.")
            print("Ensure that the setup_db.py script has been executed correctly.")
            return  # Exit the function if the table does not exist

        print("'Tetrominoes' table found. Fetching data...")
        cur.execute("SELECT letter, color, ST_AsText(geom) FROM tetrominoes ORDER BY letter")
        tetrominoes = cur.fetchall()

        if not tetrominoes:
             print("No tetrominoes found in the 'tetrominoes' table.")
             return

        print(f"Found {len(tetrominoes)} tetrominoes. Starting plotting and saving...")

        # Loop through the found tetrominoes and plot/save each one
        for letter, color, geom in tetrominoes:
            plot_single_tetromino(letter, color, geom, render_dir)

        print("Plotting and saving completed.")

    except psycopg2.OperationalError as e:
        print(f"Database connection or operation error: {e}")
        print("Ensure that the 'db' service is running and accessible.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Ensure the database connection is closed
        if conn:
            cur.close()
            conn.close()
            print("Database connection closed.")


if __name__ == "__main__":
    # Add a small delay at the start of the main script
    # to give the DB service an additional moment to stabilize
    # even though wait-for-it.sh should already handle it.
    # time.sleep(2)
    show_tetrominoes()
