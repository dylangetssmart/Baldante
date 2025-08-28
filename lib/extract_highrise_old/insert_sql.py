import pandas as pd
import os
from lib.setup_logger import setup_logger

script_name = os.path.splitext(os.path.basename(__file__))[0]
logger = setup_logger(__name__, log_file=f"{script_name}.log")

def insert_to_sql_server(file_path, engine, table_name, data):
    try:
        df = pd.DataFrame([data])
        df.to_sql(table_name, con=engine, if_exists='append', index=False)
        # logger.info(f"Data inserted into {table_name}")
        logger.debug(f"Data inserted into {table_name}: {data}")  # Debugging: print the data inserted
    except Exception as e:
        logger.error(f"{file_path} - Error inserting data into {table_name}: {e}")