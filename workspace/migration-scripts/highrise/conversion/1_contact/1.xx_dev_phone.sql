USE BaldanteHighriseSA
GO


/*
alter table [sma_MST_ContactNumbers] disable trigger all
delete from [sma_MST_ContactNumbers] 
DBCC CHECKIDENT ('[sma_MST_ContactNumbers]', RESEED, 0);
alter table [sma_MST_ContactNumbers] enable trigger all
*/


---(0)---
INSERT INTO sma_MST_ContactNoType
	(
	ctysDscrptn
   ,ctynContactCategoryID
   ,ctysDefaultTexting
	)
	SELECT
		'Work Phone'
	   ,1
	   ,0
	UNION
	SELECT
		'Work Fax'
	   ,1
	   ,0
	UNION
	SELECT
		'Cell Phone'
	   ,1
	   ,0
	UNION
	-- Other for indv
	SELECT
		'Other'
	   ,1
	   ,0
	UNION
	-- Other for org
	SELECT
		'Other'
	   ,2
	   ,0
	EXCEPT
	SELECT
		ctysDscrptn
	   ,ctynContactCategoryID
	   ,ctysDefaultTexting
	FROM sma_MST_ContactNoType


---(0)----
IF OBJECT_ID(N'dbo.FormatPhone', N'FN') IS NOT NULL
	DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone (@phone VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF LEN(@phone) = 10
		AND ISNUMERIC(@phone) = 1
	BEGIN
		RETURN '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	END
	RETURN @phone;
END;
GO

---
ALTER TABLE [sma_MST_ContactNumbers] DISABLE TRIGGER ALL
---

-- Home Phone
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		i.cinnContactCtg								   AS cnnnContactCtgID
	   ,i.cinnContactID									   AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Home Primary Phone'
				AND ctynContactCategoryID = 1
		)												   
		AS cnnnPhoneTypeID   -- Home Phone 
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Home], 20)) AS cnnsContactNumber
	   ,NULL											   AS cnnsExtension
	   ,1												   AS cnnbPrimary
	   ,NULL											   AS cnnbVisible
	   ,A.addnAddressID									   AS cnnnAddressID
	   ,'Home Phone'									   AS cnnsLabelCaption
	   ,368												   AS cnnnRecUserID
	   ,GETDATE()										   AS cnndDtCreated
	   ,368												   AS cnnnModifyUserID
	   ,GETDATE()										   AS cnndDtModified
	   ,NULL											   AS cnnnLevelNo
	   ,NULL											   AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_IndvContacts] i
		on i.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = i.cinnContactID
			AND A.addnContactCtgID = i.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Home], '') <> ''
GO

-- Work Phone
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		i.cinnContactCtg								   AS cnnnContactCtgID
	   ,i.cinnContactID									   AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Work Phone'
				AND ctynContactCategoryID = 1
		)												   
		AS cnnnPhoneTypeID   -- Home Phone 
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Work], 20)) AS cnnsContactNumber
	   ,NULL											   AS cnnsExtension
	   ,1												   AS cnnbPrimary
	   ,NULL											   AS cnnbVisible
	   ,A.addnAddressID									   AS cnnnAddressID
	   ,'Work Phone'									   AS cnnsLabelCaption
	   ,368												   AS cnnnRecUserID
	   ,GETDATE()										   AS cnndDtCreated
	   ,368												   AS cnnnModifyUserID
	   ,GETDATE()										   AS cnndDtModified
	   ,NULL											   AS cnnnLevelNo
	   ,NULL											   AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_IndvContacts] i
		on i.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = i.cinnContactID
			AND A.addnContactCtgID = i.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Work], '') <> ''
GO

-- Cell Phone
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		i.cinnContactCtg									 AS cnnnContactCtgID
	   ,i.cinnContactID										 AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Cell Phone'
				AND ctynContactCategoryID = 1
		)													 
		AS cnnnPhoneTypeID   -- Home Phone 
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Mobile], 20)) AS cnnsContactNumber
	   ,NULL												 AS cnnsExtension
	   ,1													 AS cnnbPrimary
	   ,NULL												 AS cnnbVisible
	   ,A.addnAddressID										 AS cnnnAddressID
	   ,'Mobile Phone'										 AS cnnsLabelCaption
	   ,368													 AS cnnnRecUserID
	   ,GETDATE()											 AS cnndDtCreated
	   ,368													 AS cnnnModifyUserID
	   ,GETDATE()											 AS cnndDtModified
	   ,NULL												 AS cnnnLevelNo
	   ,NULL												 AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_IndvContacts] i
		on i.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = i.cinnContactID
			AND A.addnContactCtgID = i.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Mobile], '') <> ''
GO


-- Fax
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		i.cinnContactCtg								  AS cnnnContactCtgID
	   ,i.cinnContactID									  AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Home Primary Fax'
				AND ctynContactCategoryID = 1
		)												  
		AS cnnnPhoneTypeID   -- Home Phone 
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Fax], 20)) AS cnnsContactNumber
	   ,NULL											  AS cnnsExtension
	   ,1												  AS cnnbPrimary
	   ,NULL											  AS cnnbVisible
	   ,A.addnAddressID									  AS cnnnAddressID
	   ,'Fax'											  AS cnnsLabelCaption
	   ,368												  AS cnnnRecUserID
	   ,GETDATE()										  AS cnndDtCreated
	   ,368												  AS cnnnModifyUserID
	   ,GETDATE()										  AS cnndDtModified
	   ,NULL											  AS cnnnLevelNo
	   ,NULL											  AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_IndvContacts] i
		on i.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = i.cinnContactID
			AND A.addnContactCtgID = i.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Fax], '') <> ''
GO


-- Other
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		i.cinnContactCtg									AS cnnnContactCtgID
	   ,i.cinnContactID										AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Other'
				AND ctynContactCategoryID = 1
		)													
		AS cnnnPhoneTypeID   -- Home Phone 
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Other], 20)) AS cnnsContactNumber
	   ,NULL												AS cnnsExtension
	   ,1													AS cnnbPrimary
	   ,NULL												AS cnnbVisible
	   ,A.addnAddressID										AS cnnnAddressID
	   ,'Fax'												AS cnnsLabelCaption
	   ,368													AS cnnnRecUserID
	   ,GETDATE()											AS cnndDtCreated
	   ,368													AS cnnnModifyUserID
	   ,GETDATE()											AS cnndDtModified
	   ,NULL												AS cnnnLevelNo
	   ,NULL												AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_IndvContacts] i
		on i.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = i.cinnContactID
			AND A.addnContactCtgID = i.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Other], '') <> ''
GO

/*
ORG CONTACTS  ###################################################################################################
*/

-- Office Phone
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		o.connContactCtg								   AS cnnnContactCtgID
	   ,o.connContactID									   AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Office Phone'
				AND ctynContactCategoryID = 2
		)												   
		AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Home], 20)) AS cnnsContactNumber
	   ,NULL											   AS cnnsExtension
	   ,1												   AS cnnbPrimary
	   ,NULL											   AS cnnbVisible
	   ,A.addnAddressID									   AS cnnnAddressID
	   ,'Home'											   AS cnnsLabelCaption
	   ,368												   AS cnnnRecUserID
	   ,GETDATE()										   AS cnndDtCreated
	   ,368												   AS cnnnModifyUserID
	   ,GETDATE()										   AS cnndDtModified
	   ,NULL											   AS cnnnLevelNo
	   ,NULL											   AS caseNo
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_OrgContacts] o
		on o.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = o.connContactID
			AND A.addnContactCtgID = o.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Home], '') <> ''
GO

-- HQ/Main Office Phone
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		o.connContactCtg								   AS cnnnContactCtgID
	   ,o.connContactID									   AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'HQ/Main Office Phone'
				AND ctynContactCategoryID = 2
		)												   
		AS cnnnPhoneTypeID
	   ,   -- Office Phone 
		dbo.FormatPhone(LEFT(c.[Phone number - Work], 20)) AS cnnsContactNumber
	   ,NULL											   AS cnnsExtension
	   ,1												   AS cnnbPrimary
	   ,NULL											   AS cnnbVisible
	   ,A.addnAddressID									   AS cnnnAddressID
	   ,'Business'										   AS cnnsLabelCaption
	   ,368												   AS cnnnRecUserID
	   ,GETDATE()										   AS cnndDtCreated
	   ,368												   AS cnnnModifyUserID
	   ,GETDATE()										   AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_OrgContacts] o
		on o.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = o.connContactID
			AND A.addnContactCtgID = o.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Work], '') <> ''
GO

-- Cell
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		o.connContactCtg									 AS cnnnContactCtgID
	   ,o.connContactID										 AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Cell'
				AND ctynContactCategoryID = 2
		)													 
		AS cnnnPhoneTypeID
	   ,   -- Office Phone 
		dbo.FormatPhone(LEFT(c.[Phone number - Mobile], 20)) AS cnnsContactNumber
	   ,NULL												 AS cnnsExtension
	   ,1													 AS cnnbPrimary
	   ,NULL												 AS cnnbVisible
	   ,A.addnAddressID										 AS cnnnAddressID
	   ,'Mobile'											 AS cnnsLabelCaption
	   ,368													 AS cnnnRecUserID
	   ,GETDATE()											 AS cnndDtCreated
	   ,368													 AS cnnnModifyUserID
	   ,GETDATE()											 AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_OrgContacts] o
		on o.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = o.connContactID
			AND A.addnContactCtgID = o.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Mobile], '') <> ''
GO

-- Fax
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		o.connContactCtg								  AS cnnnContactCtgID
	   ,o.connContactID									  AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Office Fax'
				AND ctynContactCategoryID = 2
		)												  
		AS cnnnPhoneTypeID
	   ,   -- Office Phone 
		dbo.FormatPhone(LEFT(c.[Phone number - Fax], 20)) AS cnnsContactNumber
	   ,NULL											  AS cnnsExtension
	   ,1												  AS cnnbPrimary
	   ,NULL											  AS cnnbVisible
	   ,A.addnAddressID									  AS cnnnAddressID
	   ,'Fax'											  AS cnnsLabelCaption
	   ,368												  AS cnnnRecUserID
	   ,GETDATE()										  AS cnndDtCreated
	   ,368												  AS cnnnModifyUserID
	   ,GETDATE()										  AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_OrgContacts] o
		on o.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = o.connContactID
			AND A.addnContactCtgID = o.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Fax], '') <> ''
GO

-- Other
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		o.connContactCtg									AS cnnnContactCtgID
	   ,o.connContactID										AS cnnnContactID
	   ,(
			SELECT
				ctynContactNoTypeID
			FROM sma_MST_ContactNoType
			WHERE ctysDscrptn = 'Other'
				AND ctynContactCategoryID = 2
		)													
		AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(LEFT(c.[Phone number - Other], 20)) AS cnnsContactNumber
	   ,NULL												AS cnnsExtension
	   ,1													AS cnnbPrimary
	   ,NULL												AS cnnbVisible
	   ,A.addnAddressID										AS cnnnAddressID
	   ,'Other'												AS cnnsLabelCaption
	   ,368													AS cnnnRecUserID
	   ,GETDATE()											AS cnndDtCreated
	   ,368													AS cnnnModifyUserID
	   ,GETDATE()											AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_OrgContacts] o
		on o.saga = convert(varchar,c.[Highrise ID])
	JOIN [sma_MST_Address] A
		ON A.addnContactID = o.connContactID
			AND A.addnContactCtgID = o.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(c.[Phone number - Other], '') <> ''
GO



---(Appendix) Finally, only one phone number as primary---
UPDATE [sma_MST_ContactNumbers]
SET cnnbPrimary = 0
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [sma_MST_ContactNumbers]
	WHERE cnnnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM [dbo].[sma_MST_ContactCtg]
			WHERE ctgsDesc = 'Individual'
		)
) A
WHERE A.RowNumber <> 1
AND A.ContactNumberID = cnnnContactNumberID


UPDATE [sma_MST_ContactNumbers]
SET cnnbPrimary = 0
FROM (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY cnnnContactID ORDER BY cnnnContactNumberID) AS RowNumber
	   ,cnnnContactNumberID AS ContactNumberID
	FROM [sma_MST_ContactNumbers]
	WHERE cnnnContactCtgID = (
			SELECT
				ctgnCategoryID
			FROM [dbo].[sma_MST_ContactCtg]
			WHERE ctgsDesc = 'Organization'
		)
) A
WHERE A.RowNumber <> 1
AND A.ContactNumberID = cnnnContactNumberID

---
ALTER TABLE [sma_MST_ContactNumbers] ENABLE TRIGGER ALL
--- 

----------------------
---(Other phones for Individual)--
----(1)-- 
--INSERT INTO [sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.cinnContactCtg			  AS cnnnContactCtgID
--	   ,C.cinnContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Home Vacation Phone'
--				AND ctynContactCategoryID = 1
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(other_phone1) AS cnnsContactNumber
--	   ,other1_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title1				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_IndvContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.cinnContactID
--			AND A.addnContactCtgID = C.cinnContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(N.other_phone1, '') <> ''


----(2)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.cinnContactCtg			  AS cnnnContactCtgID
--	   ,C.cinnContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Home Vacation Phone'
--				AND ctynContactCategoryID = 1
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(other_phone2) AS cnnsContactNumber
--	   ,other2_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title2				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_IndvContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.cinnContactID
--			AND A.addnContactCtgID = C.cinnContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(N.other_phone2, '') <> ''

----(3)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.cinnContactCtg			  AS cnnnContactCtgID
--	   ,C.cinnContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Home Vacation Phone'
--				AND ctynContactCategoryID = 1
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(other_phone3) AS cnnsContactNumber
--	   ,other3_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title3				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_IndvContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.cinnContactID
--			AND A.addnContactCtgID = C.cinnContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(N.other_phone3, '') <> ''


----(4)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.cinnContactCtg			  AS cnnnContactCtgID
--	   ,C.cinnContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Home Vacation Phone'
--				AND ctynContactCategoryID = 1
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(other_phone4) AS cnnsContactNumber
--	   ,other4_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title4				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_IndvContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.cinnContactID
--			AND A.addnContactCtgID = C.cinnContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(N.other_phone4, '') <> ''


----(5)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.cinnContactCtg			  AS cnnnContactCtgID
--	   ,C.cinnContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Home Vacation Phone'
--				AND ctynContactCategoryID = 1
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(other_phone5) AS cnnsContactNumber
--	   ,other5_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title5				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_IndvContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.cinnContactID
--			AND A.addnContactCtgID = C.cinnContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(N.other_phone5, '') <> ''




----(Org 1)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.connContactCtg			  AS cnnnContactCtgID
--	   ,C.connContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Office Phone'
--				AND ctynContactCategoryID = 2
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Office Phone 
--		dbo.FormatPhone(other_phone1) AS cnnsContactNumber
--	   ,other1_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title1				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_OrgContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.connContactID
--			AND A.addnContactCtgID = C.connContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(other_phone1, '') <> ''

----(Org 2)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.connContactCtg			  AS cnnnContactCtgID
--	   ,C.connContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Office Phone'
--				AND ctynContactCategoryID = 2
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Office Phone 
--		dbo.FormatPhone(other_phone2) AS cnnsContactNumber
--	   ,other2_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title2				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_OrgContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.connContactID
--			AND A.addnContactCtgID = C.connContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(other_phone2, '') <> ''

----(Org 3)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.connContactCtg			  AS cnnnContactCtgID
--	   ,C.connContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Office Phone'
--				AND ctynContactCategoryID = 2
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Office Phone 
--		dbo.FormatPhone(other_phone3) AS cnnsContactNumber
--	   ,other3_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title3				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_OrgContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.connContactID
--			AND A.addnContactCtgID = C.connContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(other_phone3, '') <> ''

----(Org 4)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.connContactCtg			  AS cnnnContactCtgID
--	   ,C.connContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Office Phone'
--				AND ctynContactCategoryID = 2
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Office Phone 
--		dbo.FormatPhone(other_phone4) AS cnnsContactNumber
--	   ,other4_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title4				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_OrgContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.connContactID
--			AND A.addnContactCtgID = C.connContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(other_phone4, '') <> ''


----(Org 5)--
--INSERT INTO [dbo].[sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		C.connContactCtg			  AS cnnnContactCtgID
--	   ,C.connContactID				  AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Office Phone'
--				AND ctynContactCategoryID = 2
--		)							  
--		AS cnnnPhoneTypeID
--	   ,   -- Office Phone 
--		dbo.FormatPhone(other_phone5) AS cnnsContactNumber
--	   ,other5_ext					  AS cnnsExtension
--	   ,0							  AS cnnbPrimary
--	   ,NULL						  AS cnnbVisible
--	   ,A.addnAddressID				  AS cnnnAddressID
--	   ,phone_title5				  AS cnnsLabelCaption
--	   ,368							  AS cnnnRecUserID
--	   ,GETDATE()					  AS cnndDtCreated
--	   ,368							  AS cnnnModifyUserID
--	   ,GETDATE()					  AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM [JoelBieberNeedles].[dbo].[names] N
--	JOIN [sma_MST_OrgContacts] C
--		ON C.saga = N.names_id
--	JOIN [sma_MST_Address] A
--		ON A.addnContactID = C.connContactID
--			AND A.addnContactCtgID = C.connContactCtg
--			AND A.addbPrimary = 1
--	WHERE ISNULL(other_phone5, '') <> ''
