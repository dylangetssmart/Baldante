USE BaldanteHighriseSA

-- Create junction table
DROP TABLE IF EXISTS conversion.ContactTags;

CREATE TABLE conversion.ContactTags (
	id INT IDENTITY PRIMARY KEY
   ,contact_id INT NOT NULL
   ,tag NVARCHAR(255) NOT NULL
);

/*
if STRING_SPLIT is invalid:

SELECT compatibility_level
FROM sys.databases
WHERE name = 'BaldanteHighriseSA';

ALTER DATABASE BaldanteHighriseSA SET COMPATIBILITY_LEVEL = 160;
*/

INSERT INTO conversion.ContactTags
	(
	contact_id
   ,tag
	)
	SELECT
		c.id
	   ,TRIM(value) AS Tag
	FROM Baldante..contacts AS c
	CROSS APPLY STRING_SPLIT(c.tags, ',')
	WHERE ISNULL(c.tags, '') <> '';

SELECT
	*
FROM conversion.ContactTags ct
SELECT @@VERSION;

delete from sma_MST_CaseTags

-- Create tags
INSERT INTO [dbo].[sma_MST_CaseTags]
	(
	[Name]
   ,[LimitTagGroups]
   ,[IsActive]
   ,[CreateUserID]
   ,[DtCreated]
   ,[ModifyUserID]
   ,[dDtModified]
	)
	SELECT distinct
		'Highrise' AS name
	   ,0		   AS LimitTagGroups
	   ,1		   AS IsActive
	   ,368		   AS CreateUserID
	   ,GETDATE()  AS DtCreated
	   ,368		   AS ModifyUserID
	   ,GETDATE()  AS dDtModified
	FROM conversion.ContactTags ct
	WHERE NOT EXISTS (
			SELECT
				1
			FROM [sma_MST_CaseTags] ct
			WHERE ct.name = 'Highrise'
		);
GO

INSERT INTO [dbo].[sma_MST_CaseTags]
	(
	[Name]
   ,[LimitTagGroups]
   ,[IsActive]
   ,[CreateUserID]
   ,[DtCreated]
   ,[ModifyUserID]
   ,[dDtModified]
	)
	SELECT DISTINCT
		Tag
	   ,0		  AS LimitTagGroups
	   ,1		  AS IsActive
	   ,368		  AS CreateUserID
	   ,GETDATE() AS DtCreated
	   ,368		  AS ModifyUserID
	   ,GETDATE() AS dDtModified
	FROM conversion.ContactTags ct
GO

SELECT * FROM sma_MST_CaseTags smct
SELECT * FROM sma_TRN_CaseTags stct

-- Add tags to cases
INSERT INTO [dbo].[sma_TRN_CaseTags]
	(
	[CaseID]
   ,[TagID]
   ,[CreateUserID]
   ,[DtCreated]
   ,[DeleteUserID]
   ,[DtDeleted]
	)
	SELECT
		stc.casnCaseID
	   ,TagID
	   ,368
	   ,GETDATE()
	   ,NULL AS DeleteUserID
	   ,NULL AS DtDeleted
	FROM BaldanteHighriseSA.conversion.ContactTags ct
	JOIN sma_TRN_Cases stc
		ON stc.cassCaseNumber = ct.contact_id
	JOIN sma_MST_CaseTags smct
		ON smct.Name = ct.Tag

SELECT * FROM sma_TRN_CaseTags stct