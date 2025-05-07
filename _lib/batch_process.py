import os
import logging
from _lib.extract_txt import connect_to_sql_server, create_tables, process_file

logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

def process_all_files(directory, engine):
    # Iterate through all files in the specified directory
    for filename in os.listdir(directory):
        if filename.endswith('.txt'):
            file_path = os.path.join(directory, filename)
            logging.info(f'Processing: {filename}')
            # print(f"Processing file: {file_path}")
            process_file(file_path, engine)

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

    # Define the directory containing the .txt files
    directory = r'D:\Baldante\highrise\data\Highrise_Backup_5_6_2024\Highrise_Backup_12_4_2024\highrise-export-01574-96183\contacts'

    # Process all .txt files in the directory
    process_all_files(directory, engine)

    # Connection will automatically close when script ends
