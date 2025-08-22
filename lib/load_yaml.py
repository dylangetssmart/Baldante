import os
import yaml
from lib.setup_logger import setup_logger

script_name = os.path.splitext(os.path.basename(__file__))[0]
logger = setup_logger(__name__, log_file=f"{script_name}.log")

def load_yaml(file_path, console=None):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return yaml.safe_load(file)
    except yaml.YAMLError as exc:
        logger.warning(f"Error parsing YAML file {file_path}: {exc}")
        if console:
            console.print(f"[red]Error parsing YAML file {file_path}[/red]")
        return None
