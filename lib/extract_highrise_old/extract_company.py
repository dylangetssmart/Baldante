import os
from lib.insert_sql import insert_to_sql_server
from lib.extract_notes_and_tasks import extract_notes_and_tasks
from lib.load_yaml import load_yaml

def extract_company(file_path, engine, logger, progress=None):
    """Extract company details, notes, and tasks from YAML file."""

    data = load_yaml(file_path)
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
        insert_to_sql_server(file_path, engine, "company", company_data)
        logger.info(f"Inserted company: {company_data['name']}")
    except Exception as e:
        logger.error(f"FAIL: insert company from {file_path}: {e}")
        
        if progress:
            progress.console.print(f"[red]Company insert failed: {file_path}: {e}[/red]")

    # Notes and Tasks
    notes, tasks = extract_notes_and_tasks(data, company_id=company_data['id'])

    for note in notes:
        try:
            insert_to_sql_server(file_path, engine, 'notes', note)
            logger.info(f"Inserted note ID {note['id']} for company ID {company_data['id']}")
        except Exception as e:
            logger.error(f"FAIL: insert note ID {note['id']} from {file_path}: {e}")

            if progress:
                progress.console.print(f"[red]Note insert failed: {file_path}: {e}[/red]")

    for task in tasks:
        try:
            insert_to_sql_server(file_path, engine, 'tasks', task)
            logger.info(f"Inserted task ID {task['id']} for company ID {company_data['id']}")
        except Exception as e:
            logger.error(f"FAIL: insert task ID {task['id']} from {file_path}: {e}")

            if progress:
                progress.console.print(f"[red]Task insert failed: {file_path}: {e}[/red]")
