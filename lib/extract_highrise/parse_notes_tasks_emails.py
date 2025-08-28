import re
from .process_date import process_date

def extract_id(entry_key: str) -> str | None:
    """
    Extract the numeric ID from a note or task key string.
    Examples:
        'Note 711840863' -> '711840863'
        'Task recording 711847247' -> '711847247'
        'Email 744140388' -> '744140388'
    """
    match = re.search(r'(\d+)$', entry_key.strip().rstrip(':'))
    return match.group(1) if match else None


# def parse_notes_tasks_emails(data: list, contact_id: int = None, company_id: int = None) -> tuple[list, list]:
#     """
#     Extract notes and tasks from YAML-like data.
#     Returns a tuple: (notes, tasks, emails)
#     Each note/task/email is a dict including id, author, written_date, about, body, and associated contact or company.
#     """
#     notes = []
#     tasks = []
#     emails = []

#     for item in data:
#         if not isinstance(item, dict):
#             continue

#         entry_key = next(iter(item.keys()))
#         entry_id = extract_id(entry_key)
#         entry_details = item.get(entry_key)

#         if entry_id is None or entry_details is None:
#             continue

#         # Handle written date safely
#         written_date_str = entry_details[1].get('Written') if len(entry_details) > 1 else None
#         written_date = process_date(written_date_str) if written_date_str else None

#         base_data = {
#             'id': entry_id,
#             'author': entry_details[0].get('Author') if len(entry_details) > 0 else None,
#             'written_date': written_date,
#             'about': entry_details[2].get('About') if len(entry_details) > 2 else None,
#             'body': entry_details[3].get('Body') if len(entry_details) > 3 else None,
#             'contact_id': contact_id,
#             'company_id': company_id
#         }

#         if entry_key.lower().startswith('note'):
#             notes.append(base_data)
#         elif entry_key.lower().startswith('task'):
#             tasks.append(base_data)
#         elif entry_key.lower().startswith('email'):
#             emails.append(base_data)

#     return notes, tasks, emails

import re
from .process_date import process_date

def extract_id(entry_key: str) -> str | None:
    """Extract the numeric ID from a note, task, or email key string."""
    match = re.search(r'(\d+)$', entry_key.strip().rstrip(':'))
    return match.group(1) if match else None


def parse_notes_tasks_emails(data: list, contact_id: int = None, company_id: int = None):
    notes, tasks, emails = [], [], []

    for item in data:
        if not isinstance(item, dict):
            continue

        entry_key = next(iter(item.keys()))
        entry_id = extract_id(entry_key)
        entry_details = item.get(entry_key)

        if entry_id is None or not isinstance(entry_details, list):
            continue

        # Flatten list of small dicts into one dict
        merged = {}
        for detail in entry_details:
            if isinstance(detail, dict):
                merged.update(detail)

        written_date = process_date(merged.get("Written"))

        if entry_key.lower().startswith("note"):
            notes.append({
                "id": entry_id,
                "author": merged.get("Author"),
                "written_date": written_date,
                "about": merged.get("About"),
                "body": merged.get("Body"),
                "contact_id": contact_id,
                "company_id": company_id,
            })

        elif entry_key.lower().startswith("task"):
            tasks.append({
                "id": entry_id,
                "author": merged.get("Author"),
                "written_date": written_date,
                "about": merged.get("About"),
                "body": merged.get("Body"),
                "contact_id": contact_id,
                "company_id": company_id,
            })

        elif entry_key.lower().startswith("email"):
            emails.append({
                "id": entry_id,
                "author": merged.get("Author"),
                "written_date": written_date,
                "about": merged.get("About"),
                "subject": merged.get("Subject"),   # only emails
                "body": merged.get("Body"),
                "contact_id": contact_id,
                "company_id": company_id,
            })

    return notes, tasks, emails
