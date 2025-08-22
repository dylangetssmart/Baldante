
# Baldante Highrise

- Highrise data lives in the `\contacts` folder.
- Files named with numbers hold Notes and Tasks
- Files named with actual names are Contacts
  - "Company" node holds a link to the Note/Task file
  - Can also contain Tasks and Notes



![alt text](image.png)



---

SELECT * FROM [Baldante].[dbo].[contacts] -- WHERE id = 334359479

SELECT * FROM [Baldante].[dbo].[phone] -- where contact_id = 334359479

SELECT * FROM [Baldante].[dbo].[email] -- where contact_id = 334359479

SELECT * FROM [Baldante].[dbo].[address]


----

-- Drop the foreign key constraint first if it exists
ALTER TABLE phone DROP CONSTRAINT IF EXISTS FK_phone_contact;
ALTER TABLE email DROP CONSTRAINT IF EXISTS FK_email_contact;
ALTER TABLE address DROP CONSTRAINT IF EXISTS FK_address_contact;
ALTER TABLE contacts DROP CONSTRAINT IF EXISTS FK_phone_contact;

DROP TABLE IF EXISTS phone;
DROP TABLE IF EXISTS email;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS contacts;





