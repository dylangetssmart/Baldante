USE BaldanteSA
GO
/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/


---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0				 AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)				 
		AS notnNoteTypeID
	   
	   ,concat(
		COALESCE('Author:' + n.author, '') + CHAR(13),
		COALESCE('About:' + n.about, '') + CHAR(13)
	   ) AS notmDescription
	   	   ,concat(
		COALESCE('Author:' + n.author, '') + CHAR(13),
		COALESCE('About:' + n.about, '') + CHAR(13)
	   ) AS notmPlainText


	 --      ISNULL('Account Number: ' + NULLIF(CAST(Account_Number AS VARCHAR(MAX)), '') + CHAR(13), '') +
  --  ISNULL('Cancel: ' + NULLIF(CAST(Cancel AS VARCHAR(MAX)), '') + CHAR(13), '') +    
  --  ISNULL('CM Reviewed: ' + NULLIF(CAST(CM_Reviewed AS VARCHAR(MAX)), '') + CHAR(13), '') +
  --  ISNULL('Date Paid: ' + NULLIF(CAST(Date_Paid AS VARCHAR(MAX)), '') + CHAR(13), '') +
  --  ISNULL('For Dates From: ' + NULLIF(CAST(For_Dates_From AS VARCHAR(MAX)), '') + CHAR(13), '') +
  --  ISNULL('OI Checked: ' + NULLIF(CAST(OI_Checked AS VARCHAR(MAX)), '') + CHAR(13), '')
  --                                          as dissComments

		--END				 AS notmDescription
	   
	   
	 --  ,CASE
		--	WHEN ISNULL(date_of_majority, '') = ''
		--		THEN 'Date of Majority : N/A'
		--	ELSE 'Date of Majority : ' + CONVERT(VARCHAR, date_of_majority)
		--END				 AS notmPlainText


	   ,i.cinnContactCtg AS notnContactCtgID
	   ,i.cinnContactID	 AS notnContactId
	   ,'Normal'		 AS notsPriority
	   ,0				 AS notnFormID
	   ,368				 AS notnRecUserID
	   ,GETDATE()		 AS notdDtCreated
	   ,NULL			 AS notnModifyUserID
	   ,NULL			 AS notdDtModified
	FROM Baldante..notes n
	JOIN sma_MST_IndvContacts i
		ON i.saga = n.contact_id

----(2)----
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0				 AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)				 
		AS notnNoteTypeID
	   ,CASE
			WHEN ISNULL(minor, '') = ''
				THEN 'Minor : N'
			ELSE 'Minor : ' + CONVERT(VARCHAR, minor)
		END				 AS notmDescription
	   ,CASE
			WHEN ISNULL(minor, '') = ''
				THEN 'Minor : N'
			ELSE 'Minor : ' + CONVERT(VARCHAR, minor)
		END				 AS notmPlainText
	   ,I.cinnContactCtg AS notnContactCtgID
	   ,I.cinnContactID	 AS notnContactId
	   ,'Normal'		 AS notsPriority
	   ,0				 AS notnFormID
	   ,368				 AS notnRecUserID
	   ,GETDATE()		 AS notdDtCreated
	   ,NULL			 AS notnModifyUserID
	   ,NULL			 AS notdDtModified
	FROM TestNeedles.[dbo].[party] P
	JOIN sma_MST_IndvContacts I
		ON I.saga = P.party_id


---(3)--- 
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0		  AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)		  
		AS notnNoteTypeID
	   ,PN.note	  AS notmDescription
	   ,PN.note	  AS notmPlainText
	   ,IOC.CTG	  AS notnContactCtgID
	   ,IOC.CID	  AS notnContactId
	   ,'Normal'  AS notsPriority
	   ,0		  AS notnFormID
	   ,368		  AS notnRecUserID
	   ,GETDATE() AS notdDtCreated
	   ,NULL	  AS notnModifyUserID
	   ,NULL	  AS notdDtModified
	FROM TestNeedles.[dbo].[provider_notes] PN
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = PN.name_id

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---



