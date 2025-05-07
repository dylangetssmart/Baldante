from datetime import datetime
import yaml
import pandas as pd
from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, text
import logging
from _lib.create_tables import create_tables

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

def process_written_date(date_string):
    """ Convert date string to SQL Server compatible format """
    try:
        # Parse the date string into a datetime object
        date_obj = datetime.strptime(date_string, "%B %d, %Y %H:%M")
        # Format the datetime object to the SQL-compatible format (DATETIME(3))
        return date_obj.strftime("%Y-%m-%d %H:%M:%S.000")
    except ValueError:
        logging.warning(f"Warning: Could not parse date: {date_string}")
        return None

def connect_to_sql_server(server, database, username, password):
    connection_string = (
        f'mssql+pyodbc://{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes'
    )
    engine = create_engine(connection_string)
    return engine

def insert_to_sql_server(file_path, engine, table_name, data):
    try:
        df = pd.DataFrame([data])
        df.to_sql(table_name, con=engine, if_exists='append', index=False)
        logging.debug(f"Data inserted into {table_name}: {data}")
    except Exception as e:
        logging.error(f"{file_path} - Error inserting data into {table_name}: {e}")

def process_file(file_path, engine):
    contact_count = 0  # Initialize counter for contacts
    try:
        # Read the YAML file
        with open(file_path, 'r', encoding='utf-8') as file:
            data = yaml.safe_load(file)
    except yaml.YAMLError as exc:
        logging.error(f"Error parsing YAML file {file_path}: {exc}")
        return 
    
    """ Contact Record -----------------------------------------------------------------------------
    id = data[0]['ID']
    name = data[0]['Name']
    tags = data[0]['Tags']
    background = data[3]['Background']
    """
    contact_header = data[0]

    background = None
    if len(data) > 3 and isinstance(data[3], dict) and 'Background' in data[3]:
        background = data[3]['Background']

    contact_data = {
        'id': contact_header.get('ID'),
        'name': contact_header.get('Name'),
        'tags': ', '.join(contact_header.get('Tags', [])) if contact_header.get('Tags') else None,
        'background': background
    }

    insert_to_sql_server(file_path, engine, 'contacts', contact_data)
    contact_count += 1  # Increment counter for each contact inserted

    """ Contact Info  -----------------------------------------------------------------------------
    phone:      data[2]['Contact'][0] = "Phone_numbers"
    email:      data[2]['Contact'][0] = "Email_addresses"
    address:    data[2]['Contact'][0] = "Addresses"
    """
    if len(data) > 2 and 'Contact' in data[2]:
        contact_info = data[2]['Contact']
        phone_numbers = []
        email_addresses = []
        addresses = []

        for item in contact_info:
            # Phone numbers ----------------------------------------------------
            if isinstance(item, list) and 'Phone_numbers' in item[0]:
                phone_numbers = item[1]
                for phone_number in phone_numbers:
                    phone_data = {
                        'contact_id': contact_data['id'],
                        'phone_number': phone_number
                    }
                
                    insert_to_sql_server(file_path, engine, 'phone', phone_data)
                    # logging.debug(f"Inserted phone record: {phone_data}")

            # Email addresses ----------------------------------------------------
            if isinstance(item, list) and 'Email_addresses' in item[0]:
                email_addresses = item[1]
                
                for email_address in email_addresses:
                    email_data = {
                        'contact_id': contact_data['id'],
                        'email_address': email_address
                    }

                    insert_to_sql_server(file_path, engine, 'email', email_data)
                    # logging.debug(f"Inserted email record: {email_data}")

            # Addresses ----------------------------------------------------
            if isinstance(item, list) and 'Addresses' in item[0]:
                raw_addresses = item[1]
                for address in raw_addresses:
                    if isinstance(address, str):
                        formatted_address = address.strip()
                    else:
                        # Format multiline addresses
                        formatted_address = ', '.join([line.strip() for line in address.splitlines()])

                    address_data = {
                        'contact_id': contact_data['id'],
                        'address': formatted_address
                    }
                
                    insert_to_sql_server(file_path, engine, 'address', address_data)
                    # logging.debug(f"Inserted address record: {address_data}")
        
    """ Notes  -----------------------------------------------------------------------------    
    data[4] + contains notes
    loop through data[4] to end of file for entries named 'Note'
    """ 
    notes = data[4:]
    for note in notes:
        if isinstance(note, dict):
            note_key = next(iter(note.keys()))  # 'Note 634287204'
            note_id = note_key.split()[-1].rstrip(':')  # Extract just the ID, e.g., '634287204'
            logging.debug(f"Extracted note_id: {note_id}")  # Debugging: print the note_id

        # Now access the details using the note_key
        note_details = note.get(note_key)  # Access the value associated with the note key
        if note_details is not None:
            written_date_str = note_details[1].get('Written')  # Get the written date string
            if written_date_str:
                written_date = process_written_date(written_date_str)  # Convert to SQL format
            else:
                written_date = None  # Handle missing written_date

            note_data = {
                'note_id': note_id,
                'type': 'Note' if 'Note' in note_key else 'Task',
                'contact_id': contact_data['id'],
                'author': note_details[0].get('Author'),
                'written_date': written_date,
                'about': note_details[2].get('About'),
                'body': note_details[3].get('Body')
            }
            insert_to_sql_server(file_path, engine, 'notes', note_data)
            # logging.debug(f"Inserted note record: {note_data}")
        else:
            logging.warning(f"Warning: No details found for {note_id}")  # Debugging: print warning

    # logging.info(f"Total contacts inserted: {contact_count}")  # Log the total number of contacts inserted

if __name__ == '__main__':
    # Define connection details to your SQL Server
    server = r'dylans\mssqlserver2022'
    database = 'Baldante'
    username = 'dsmith'
    password = 'SAconversion@2024'
    
    # Establish a connection
    engine = connect_to_sql_server(server, database, username, password)

    # Create tables
    create_tables(engine)

    # Process the file and insert data
    # file_path = r'D:\Baldante\trans\Highrise_Backup_10_25_2024\highrise-export-01574-94849\contacts'
    file_path = r'D:\Baldante\highrise\data\Highrise_Backup_5_6_2024\Highrise_Backup_12_4_2024\highrise-export-01574-96183\contacts\45842.013.txt'
    # file_path = r'D:\Baldante\highrise\data\Highrise_Backup_5_6_2024\Highrise_Backup_12_4_2024\highrise-export-01574-96183\contacts\Jared Thompson.txt'
    # file_path = r'D:\Baldante\highrise-export-May03-CorinneMorgan\contacts\Kathleen (goes by Katie) Kiley (Ferriola).txt'
    process_file(file_path, engine)

    # Connection will automatically close when script ends
