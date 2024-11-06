import yaml
import pandas as pd
from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, text

# Function to connect to SQL Server using SQLAlchemy
def connect_to_sql_server(server, database, username, password):
        
    connection_string = (
        f'mssql+pyodbc://{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes'
    )
    engine = create_engine(connection_string)
    return engine

# Function to create the 'contacts' and 'phone' tables if they don't exist
def create_tables(engine):
    metadata = MetaData()

    # Define the 'contacts' table
    contacts_table = Table('contacts', metadata,
        Column('ID', Integer, primary_key=True, autoincrement=False),
        Column('Name', String),
        Column('Tags', String)
    )

    # Define the 'phone' table
    phone_table = Table('phone', metadata,
        # Column('id', Integer, primary_key=True, autoincrement=False),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        # Column('contact_id', Integer, ForeignKey('contacts.ID')),  # Add foreign key to 'contacts'
        Column('phone_number', String)
    )

    # Define the 'phone' table
    email_table = Table('email', metadata,
        # Column('id', Integer, primary_key=True, autoincrement=False),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        # Column('contact_id', Integer, ForeignKey('contacts.ID')),  # Add foreign key to 'contacts'
        Column('email_address', String)
    )

    # Define the 'phone' table
    address_table = Table('address', metadata,
        # Column('id', Integer, primary_key=True, autoincrement=False),
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        # Column('contact_id', Integer, ForeignKey('contacts.ID')),  # Add foreign key to 'contacts'
        Column('address', String)
    )

    # Define the 'notes' table
    notes_table = Table('notes', metadata,
        Column('note_id', Integer, primary_key=True),  # Assuming note_id can be a string
        Column('contact_id', Integer),  # Foreign key to 'contacts'
        # Column('contact_id', Integer, ForeignKey('contacts.ID')),  # Foreign key to 'contacts'
        Column('author', String),
        Column('written_date', String),  # You can change this to DateTime if you want to store actual dates
        Column('about', String),
        Column('body', String)
    )

    # Create both tables in the database (if they don't already exist)
    metadata.create_all(engine)

# Function to insert data into SQL Server using SQLAlchemy
def insert_to_sql_server(engine, table_name, data):
    # df = pd.DataFrame([data])
    # df.to_sql(table_name, con=engine, if_exists='append', index=False)

    try:
        # Convert the data to a DataFrame
        df = pd.DataFrame([data])
        # Insert the data into the SQL table
        df.to_sql(table_name, con=engine, if_exists='append', index=False)
        print(f"Data inserted into {table_name}: {data}")
    except Exception as e:
        print(f"Error inserting data into {table_name}: {e}")

    # # Enable IDENTITY_INSERT for the table
    # with engine.connect() as conn:
    #     conn.execute(text(f"SET IDENTITY_INSERT {table_name} ON"))
    #     print("identity")
    #     # Insert the data into the SQL table
    #     df.to_sql(table_name, con=engine, if_exists='append', index=False)

    #     # Disable IDENTITY_INSERT for the table
    #     conn.execute(text(f"SET IDENTITY_INSERT {table_name} OFF"))

# # Function to insert phone numbers into the 'phone' table
# def insert_phone_numbers(engine, contact_id, phone_numbers):
#     metadata = MetaData()

#     # Define the 'phone' table for use
#     phone_table = Table('phone', metadata, autoload_with=engine)

#     # Insert phone numbers into the 'phone' table
#     with engine.connect() as conn:
#         for phone in phone_numbers:
#             conn.execute(phone_table.insert().values(contact_id=contact_id, phone_number=phone))
    
#     print(f"Inserted {len(phone_numbers)} phone numbers for contact ID {contact_id}.")

# def parse_phone_numbers(phone_data: str):


# Function to process the YAML file and extract contact and phone information
def process_file(file_path, engine):
    try:
        # Read the YAML file
        with open(file_path, 'r', encoding='utf-8') as file:
            data = yaml.safe_load(file)
    except yaml.YAMLError as exc:
        print(f"Error parsing YAML file {file_path}: {exc}")
        return 
    
    """ Contact Record -----------------------------------------------------------------------------
    id = data[0]['ID']
    name = data[0]['Name']
    tags = data[0]['Tags']
    """
    contact_header = data[0]
    contact_header_data = {
        'id': contact_header.get('ID'),
        'name': contact_header.get('Name'),
        'tags': ', '.join(contact_header.get('Tags', [])) if contact_header.get('Tags') else None
    }

    insert_to_sql_server(engine, 'contacts', contact_header_data)

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
                        'contact_id': contact_header_data['id'],
                        'phone_number': phone_number
                    }
                
                insert_to_sql_server(engine, 'phone', phone_data)
                # print(f"Inserted phone record: {phone_data}")

            # Email addresses ----------------------------------------------------
            if isinstance(item, list) and 'Email_addresses' in item[0]:
                email_addresses = item[1]
                
                for email_address in email_addresses:
                    email_data = {
                        'contact_id': contact_header_data['id'],
                        'email_address': email_address
                    }

                    insert_to_sql_server(engine, 'email', email_data)
                    # print(f"Inserted email record: {email_data}")

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
                        'contact_id': contact_header_data['id'],
                        'address': formatted_address
                    }
                
                    insert_to_sql_server(engine, 'address', address_data)
                    # print(f"Inserted address record: {address_data}")
        

    """ Notes  -----------------------------------------------------------------------------    
    data[4] + contains notes
    loop through data[4] to end of file for entries named 'Note'
    """ 
    notes = data[4:]
    for note in notes:
        if isinstance(note, dict) and 'Note' in note:
            note_id = list(note.keys()[0].split()[1].rstrip(':'))
            note_details = note['Note']
            note_data = {
                'note_id': note_id,
                'contact_id': contact_header_data['ID'],
                'author': note_details[0].get('Author'),
                'written_date': note_details[1].get('Written'),
                'about': note_details[2].get('About'),
                'body': note_details[3].get('Body')
            }
            insert_to_sql_server(engine, 'notes', note_data)
            # print(f"Inserted note record: {note_data}")


    # if len(data) > 3 and 'Note' in data[4]:
    #     contact_info = data[2]['Contact']
    #     phone_numbers = []
    #     email_addresses = []
    #     addresses = []

    #     for item in contact_info:
    
    # if len(data) > 4:
    #     notes = data[4:]  # Start from data[4] to include all subsequent notes
    #     for note in notes:
    #         if isinstance(note, list) and note.startswith('Note'):
    #             note_id = note.split()[1].rstrip(':')  # Extract the note ID
    #             author = None
    #             written_date = None
    #             about = None
    #             body = None

    #             # Extract the relevant details from the note
    #             for line in notes[notes.index(note) + 1:]:
    #                 if line.startswith('Author:'):
    #                     author = line.split('Author:')[1].strip()
    #                 elif line.startswith('Written:'):
    #                     written_date = line.split('Written:')[1].strip().strip('"')
    #                 elif line.startswith('About:'):
    #                     about = line.split('About:')[1].strip()
    #                 elif line.startswith('Body:'):
    #                     body = line.split('Body:')[1].strip()

    #                 # Break when reaching the next note
    #                 if isinstance(line, str) and line.startswith('Note'):
    #                     break
                
    #             # Prepare data for the notes table
    #             note_data = {
    #                 'note_id': note_id,
    #                 'contact_id': contact_header_data['id'],
    #                 'author': author,
    #                 'written_date': written_date,
    #                 'about': about,
    #                 'body': body
    #             }
                
    #             # Insert note data into the SQL Server table
    #             insert_to_sql_server(engine, 'notes', note_data)  # Assuming a 'notes' table exists
    #             print(f"Inserted note record: {note_data}")


    # # Assuming the entire file represents a single contact
    # if isinstance(data, list) and len(data) > 0:
    #     contact = data[0]  # Get the first (and only) contact

    #     # Extract ID and Name
    #     person_data = {
    #         'ID': contact.get('ID'),
    #         'Name': contact.get('Name')
    #     }

    #     # Insert contact data into the 'contacts' table
    #     insert_to_sql_server(engine, 'contacts', person_data)
    #     print(f"Inserted contact record: {person_data}")

    #     # Extract and insert phone numbers
    #     if len(data) > 2 and 'Contact' in data[2]:
    #         contact_info = data[2]['Contact']
    #         phone_numbers = contact_info[1][1]  # Assuming this is the list of phone numbers
    #         insert_phone_numbers(engine, person_data['ID'], phone_numbers)
    #     else:
    #         print("No phone numbers found for this contact.")
    # else:
    #     print("No valid contact data found.")


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
    file_path = r'D:\Baldante\trans\Highrise_Backup_10_25_2024\highrise-export-01574-94849\contacts'
    # file_path = r'D:\Baldante\trans\Highrise_Backup_10_25_2024\highrise-export-01574-94849\contacts\Dylan Valladares.txt'
    # file_path = r'D:\Baldante\highrise-export-May03-CorinneMorgan\contacts\Kathleen (goes by Katie) Kiley (Ferriola).txt'
    process_file(file_path, engine)

    # Connection will automatically close when script ends
