from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
import logging

def create_tables(engine):
    metadata = MetaData()

    contacts_table = Table('contacts', metadata,
        Column('ID', Integer, primary_key=True, autoincrement=False),
        Column('Name', String),
        Column('Tags', String),
        Column('Background', String)
    )

    phone_table = Table('phone', metadata,
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('phone_number', String)
    )

    email_table = Table('email', metadata,
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('email_address', String)
    )

    address_table = Table('address', metadata,
        Column('contact_id', Integer),  # Add foreign key to 'contacts'
        Column('address', String)
    )

    notes_table = Table('notes', metadata,
        Column('note_id', Integer),  # Assuming note_id can be a string
        # Column('note_id', Integer, primary_key=True, autoincrement=False),  # Assuming note_id can be a string
        Column('type', String),  # 'Note' or 'Task'
        Column('contact_id', Integer),  # Foreign key to 'contacts'
        Column('author', String),
        Column('written_date', String),  # You can change this to DateTime if you want to store actual dates
        Column('about', String),
        Column('body', String)
    )

    metadata.create_all(engine)
    logging.info(f"Tables created successfully: {metadata.tables.keys()}")