import os
import logging

# Highrise functions
from highrise.parse_data.create_highrise_tables import create_tables
from .parse_notes_tasks_emails import parse_notes_tasks_emails

# Utility functions
from lib.utility.create_engine import main as create_engine
from lib.utility.insert_sql import insert_to_sql_server
from lib.utility.insert_helpers import insert_entities
from lib.utility.load_yaml import load_yaml

# Logging and utility functions
from lib.utility.insert_sql import insert_to_sql_server
from lib.utility.insert_helpers import insert_entities
from lib.utility.load_yaml import load_yaml

logger = logging.getLogger(__name__)

def extract_company(file_path, engine, progress=None):
    """Extract company details, notes, and tasks from YAML file."""

    data = load_yaml(file_path, console=progress.console if progress else None)
    if not data:
        return 

    if not isinstance(data, list) or len(data) < 1:
        logger.warning(f"No valid company data found in {file_path}")
        return

    # --- Company record ---
    company_header = data[0]
    company_data = {
        "id": company_header.get("ID"),
        "name": company_header.get("Name"),
        "filename": os.path.basename(file_path)
    }

    try:
        insert_to_sql_server(file_path, engine, "company", company_data, console=progress.console if progress else None)
        logger.info(f"Inserted company: {company_data['name']}")
    except Exception as e:
        logger.error(f"FAIL: insert company from {file_path}: {e}")
        
        if progress:
            progress.console.print(f"[red]Company insert failed: {file_path}: {e}[/red]")

    # Notes, Tasks, Emails
    notes, tasks, emails = parse_notes_tasks_emails(data, company_id=company_data['id'])
    # logger.debug(f"company: {company_data['id']} | {notes} | {tasks} | {emails}")

    for n in notes:
        try:
            insert_to_sql_server(file_path, engine, 'notes', n, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Note insert failed for contact {company_data['id']}: {e}")
    for t in tasks:
        try:
            insert_to_sql_server(file_path, engine, 'tasks', t, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Task insert failed for contact {company_data['id']}: {e}")

    for e in emails:
        try:
            insert_to_sql_server(file_path, engine, 'emails', e, console=progress.console if progress else None)
        except Exception as e:
            logger.error(f"Email insert failed for contact {company_data['id']}: {e}")

    # insert_entities(file_path, engine, notes, "notes", "note", company_data['id'], progress)
    # insert_entities(file_path, engine, tasks, "tasks", "task", company_data['id'], progress)
    # insert_entities(file_path, engine, emails, "emails", "email", company_data['id'], progress)

    
if __name__ == '__main__':
   
    import argparse
    parser = argparse.ArgumentParser(description="Process SQL files and save results to an Excel file.")
    parser.add_argument("-s", "--server", required=True, help="SQL Server")
    parser.add_argument("-d", "--database", required=True, help="Database")
    parser.add_argument("-i", "--input", required=True, help="Path to the input folder containing SQL files.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable DEBUG logging to console")
    
    args = parser.parse_args()

    # Configure logging so DEBUG messages are visible when requested
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(level=log_level, format='%(levelname)s %(name)s: %(message)s')

    engine = create_engine(server=args.server, database=args.database)

    create_tables(engine)

    extract_company(args.input, engine, progress=None)