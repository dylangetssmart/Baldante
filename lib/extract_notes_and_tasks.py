import re

def extract_id(entry_key: str) -> str | None:
    """
    Extract the numeric ID from a note or task key string.
    Examples:
        'Note 711840863' -> '711840863'
        'Task recording 711847247' -> '711847247'
    """
    match = re.search(r'(\d+)$', entry_key.strip().rstrip(':'))
    return match.group(1) if match else None


def extract_notes_and_tasks(data: list, contact_id: int = None, company_id: int = None) -> tuple[list, list]:
    """
    Extract notes and tasks from YAML-like data.
    Returns a tuple: (notes_list, tasks_list)
    Each note/task is a dict including id, author, written_date, about, body, and associated contact or company.
    """
    notes = []
    tasks = []

    for item in data:
        if not isinstance(item, dict):
            continue

        entry_key = next(iter(item.keys()))
        entry_id = extract_id(entry_key)
        entry_details = item.get(entry_key)

        if entry_id is None or entry_details is None:
            continue

        # Handle written date safely
        written_date_str = entry_details[1].get('Written') if len(entry_details) > 1 else None
        from lib.process_date import process_date
        written_date = process_date(written_date_str) if written_date_str else None

        base_data = {
            'id': entry_id,
            'author': entry_details[0].get('Author') if len(entry_details) > 0 else None,
            'written_date': written_date,
            'about': entry_details[2].get('About') if len(entry_details) > 2 else None,
            'body': entry_details[3].get('Body') if len(entry_details) > 3 else None,
            'contact_id': contact_id,
            'company_id': company_id
        }

        if entry_key.lower().startswith('note'):
            notes.append(base_data)
        elif entry_key.lower().startswith('task'):
            tasks.append(base_data)

    return notes, tasks
