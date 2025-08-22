import os
import logging
import re
from lib.create_tables import create_tables
from lib.create_engine import main as create_engine
from lib.extract_contact import extract_contact
from lib.extract_company import extract_company
from lib.setup_logger import setup_logger

from rich.prompt import Confirm
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn, TimeElapsedColumn, TaskProgressColumn
from rich.console import Console

console = Console()

script_name = os.path.splitext(os.path.basename(__file__))[0]
logger = setup_logger(__name__, log_file=f"{script_name}.log")

# logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

def process_all_files(directory, engine):
    # Get all .txt files
    all_files = [f for f in os.listdir(directory) if f.endswith('.txt')]
    total_files = len(all_files)

    if total_files == 0:
        logger.info(f"No .txt files found in {directory}")
        return

    # Confirm with the user
    if not Confirm.ask(
        f"Import all .txt files in {directory} --> {engine.url.host}.{engine.url.database}?"
    ):
        logger.info(f"Execution skipped for {directory}.")
        return

    # Use Rich Progress
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        "•",
        TimeElapsedColumn(),
        "•",
        TextColumn("{task.completed}/{task.total} files"),
        console=console,
        transient=False
    ) as progress:
        task = progress.add_task(f"[cyan]Processing files...", total=total_files)

        for filename in all_files:
            file_path = os.path.join(directory, filename)

            progress.update(task, description=f"[cyan]Processing {filename}")
            
            try:
                if re.match(r'^\d', filename):
                    # File starts with a digit -> company
                    extract_company(file_path, engine, logger=logger)
                else:
                    # File is contact
                    extract_contact(file_path, engine)
            except Exception as e:
                logger.error(f"Error processing {filename}: {e}")

            progress.advance(task)

        progress.update(task, description="[green]Processing Complete")


if __name__ == '__main__':
    # Define connection details to your SQL Server
    # server = r'dylans\mssqlserver2022'
    # database = 'Baldante'
    # username = 'dsmith'
    # password = 'SAconversion@2024'
    
    # # Establish a connection
    # engine = connect_to_sql_server(server, database, username, password)

    # # Create tables
    # create_tables(engine)

    # # Define the directory containing the .txt files
    # directory = r'D:\Baldante\highrise\data\Highrise_Backup_5_6_2024\Highrise_Backup_12_4_2024\highrise-export-01574-96183\contacts'

    # # Process all .txt files in the directory
    # process_all_files(directory, engine)


    """CLI entry point"""
    import argparse
    parser = argparse.ArgumentParser(description="Process SQL files and save results to an Excel file.")
    parser.add_argument("-s", "--server", required=True, help="SQL Server")
    parser.add_argument("-d", "--database", required=True, help="Database")
    parser.add_argument("-i", "--input", required=True, help="Path to the input folder containing SQL files.")
    
    args = parser.parse_args()
    engine = create_engine(server=args.server, database=args.database)

    # Create tables
    create_tables(engine)

    # Process the file and insert data
    # file_path = r'D:\Baldante\highrise\data\Highrise_Backup_5_6_2024\Highrise_Backup_12_4_2024\highrise-export-01574-96183\contacts\45842.013.txt'
    # extract_contact(file_path, engine)

    options = {
        'server': args.server,
        'database': args.database,
        'input': args.input
    }

    # Process all .txt files in the directory
    process_all_files(args.input, engine)