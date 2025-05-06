#!/bin/bash
set -e # Exit immediately if a command fails

echo "Starting custom entrypoint script..."

# Wait for the database service to be available on port 5432
# 'db' is the name of the service in docker-compose
# wait-for-it.sh is a common tool, we will download it in the Dockerfile
/usr/local/bin/wait-for-it.sh db:5432 --timeout=30 --strict -- echo "Database is up - executing setup scripts"

# Execute the database setup script
# Ensure that setup_db.py has been correctly copied to the WORKDIR (/workspace)
if [ -f "setup_db.py" ]; then
    echo "Running setup_db.py..."
    python setup_db.py
    echo "setup_db.py finished."
else
    echo "Error: setup_db.py not found in $(pwd)"
    # You might want to exit here if the setup is critical
    # exit 1
fi


# Execute the plotting script
# Ensure that show_tetrominoes.py has been correctly copied
if [ -f "show_tetrominoes.py" ]; then
    echo "Running show_tetrominoes.py..."
    # Note: matplotlib output might require additional configurations for direct graphical display.
    # Often in a Docker container, a non-interactive backend (e.g., 'Agg') is used,
    # and figures are saved to files, or the devcontainer/VS Code integration is relied upon.
    python show_tetrominoes.py
    echo "show_tetrominoes.py finished."
else
    echo "Warning: show_tetrominoes.py not found in $(pwd). Skipping plotting."
fi


echo "Initial setup and scripts executed. Keeping container alive for development."

# Keep the container alive for the development environment
exec sleep infinity