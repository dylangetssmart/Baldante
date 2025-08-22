# Baldante Highrise

## Installation
1. Create python virtual enviroment
2. Install dependencies from `requirements.txt`

```bash
py -m venv .venv
.\.venv\scripts\active
pip install -r requirements.txt
```

## Notes

- Highrise data lives in the `\contacts` folder.
- Files named with numbers hold Notes and Tasks
- Files named with actual names are Contacts
  - "Company" node holds a link to the Note/Task file
  - Can also contain Tasks and Notes

![alt text](image.png)

## Tables

- select * from Baldante..contacts
- select * from Baldante..address
- select * from Baldante..phone
- select * from Baldante..email
- select * from Baldante..company
- select * from Baldante..notes
- select * from Baldante..tasks