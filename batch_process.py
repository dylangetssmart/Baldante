import os
from extract_txt import connect_to_sql_server, create_tables, process_file

def process_all_files(directory, engine):
    # Iterate through all files in the specified directory
    for filename in os.listdir(directory):
        if filename.endswith('.txt'):
            file_path = os.path.join(directory, filename)
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
    directory = r'D:\Baldante\trans\Highrise_Backup_10_25_2024\highrise-export-01574-94849\contacts'

    # Process all .txt files in the directory
    process_all_files(directory, engine)

    # Connection will automatically close when script ends
