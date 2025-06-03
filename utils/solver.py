import subprocess
import os

def run_yap_solver(puzzle_id):
    """
    Runs the YAP Prolog solver for a given puzzle ID.

    Args:
        puzzle_id (int): The ID of the puzzle to solve.
    """
    project_root = "/workspaces/project_tadb_fcup_20242025"
    solver_app_path = os.path.join(project_root, "solver", "solver_app.pl")

    # Construct the goal string for YAP
    # This will call test_solver with the specified puzzle_id and then halt.
    goal_string = f"test_solver({puzzle_id}), halt."

    # Command to run the YAP script
    # -l loads the file
    # -g executes the goal
    command = ["yap", "-l", solver_app_path, "-g", goal_string]

    print(f"Executing YAP command: {' '.join(command)}")

    try:
        # Execute the command
        # It's good practice to set the working directory if your Prolog script uses relative paths
        # that depend on where it's located (e.g., for consult/1).
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
            cwd=project_root  # Set current working directory to project root
        )
        print(f"YAP script for puzzle {puzzle_id} executed successfully.")
        print("STDOUT:")
        print(process.stdout)
        #if process.stderr:
        #    print("STDERR:")
        #    print(process.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error executing YAP script for puzzle {puzzle_id}: {e}")
        print("STDOUT:")
        print(e.stdout)
        #print("STDERR:")
        #print(e.stderr)
    except FileNotFoundError:
        print("Error: 'yap' command not found. Make sure YAP Prolog is installed and in your PATH.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    # Example: Run the solver for puzzle ID 1
    puzzle_to_solve = 1
    run_yap_solver(puzzle_to_solve)