# log_setup.py
import logging
import os

def setup_logger(name=__name__, log_file=None, level=logging.DEBUG):
    logs_dir = "workspace\\logs"
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.propagate = False

    if not logger.handlers:
        os.makedirs(logs_dir, exist_ok=True)

        # File handler
        file_handler = logging.FileHandler(os.path.join(logs_dir, log_file), encoding='utf-8')
        file_handler.setLevel(logging.INFO)
        file_formatter = logging.Formatter(
            "%(asctime)s - %(levelname)s - %(filename)s - %(funcName)s - %(lineno)d - %(message)s"
        )
        file_handler.setFormatter(file_formatter)

        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setStream(open(console_handler.stream.fileno(), 'w', encoding='utf-8', closefd=False)) 
        console_handler.setLevel(logging.ERROR)
        console_formatter = logging.Formatter(
            "%(levelname)s - %(filename)s - %(funcName)s - %(lineno)d - %(message)s"
        )
        console_handler.setFormatter(console_formatter)

        logger.addHandler(file_handler)
        logger.addHandler(console_handler)

    return logger
