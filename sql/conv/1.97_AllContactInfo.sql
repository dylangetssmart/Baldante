USE BaldanteSA

SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[sma_MST_AllContactInfo] DISABLE TRIGGER ALL
DELETE FROM [dbo].[sma_MST_AllContactInfo]
DBCC CHECKIDENT ('[dbo].[sma_MST_AllContactInfo]', RESEED, 0);
ALTER TABLE [dbo].[sma_MST_AllContactInfo] ENABLE TRIGGER ALL

SET ANSI_PADDING OFF
GO

--insert org contacts

INSERT INTO [dbo].[sma_MST_AllContactInfo]
	(
	[UniqueContactId]
   ,[ContactId]
   ,[ContactCtg]
   ,[Name]
   ,[NameForLetters]
   ,[FirstName]
   ,[LastName]
   ,[OtherName]
   ,[AddressId]
   ,[Address1]
   ,[Address2]
   ,[Address3]
   ,[City]
   ,[State]
   ,[Zip]
   ,[ContactNumber]
   ,[ContactEmail]
   ,[ContactTypeId]
   ,[ContactType]
   ,[Comments]
   ,[DateModified]
   ,[ModifyUserId]
   ,[IsDeleted]
   ,[IsActive]
	)
	SELECT
		CONVERT(BIGINT, ('2' + CONVERT(VARCHAR(30), sma_MST_OrgContacts.connContactID))) AS UniqueContactId
	   ,CONVERT(BIGINT, sma_MST_OrgContacts.connContactID)								 AS ContactId
	   ,2																				 AS ContactCtg
	   ,sma_MST_OrgContacts.consName													 AS [Name]
	   ,sma_MST_OrgContacts.consName													 AS [NameForLetters]
	   ,NULL																			 AS FirstName
	   ,NULL																			 AS LastName
	   ,NULL																			 AS OtherName
	   ,NULL																			 AS AddressId
	   ,NULL																			 AS Address1
	   ,NULL																			 AS Address2
	   ,NULL																			 AS Address3
	   ,NULL																			 AS City
	   ,NULL																			 AS [State]
	   ,NULL																			 AS Zip
	   ,NULL																			 AS ContactNumber
	   ,NULL																			 AS ContactEmail
	   ,sma_MST_OrgContacts.connContactTypeID											 AS ContactTypeId
	   ,sma_MST_OriginalContactTypes.octsDscrptn										 AS ContactType
	   ,sma_MST_OrgContacts.consComments												 AS Comments
	   ,GETDATE()																		 AS DateModified
	   ,347																				 AS ModifyUserId
	   ,0																				 AS IsDeleted
	   ,[conbStatus]
	--select max(len(consName))
	FROM sma_MST_OrgContacts
	LEFT JOIN sma_MST_OriginalContactTypes
		ON sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_OrgContacts.connContactTypeID
GO

-------------------------------------
--INSERT INDIVIDUAL CONTACTS
-------------------------------------
INSERT INTO [dbo].[sma_MST_AllContactInfo]
	(
	[UniqueContactId]
   ,[ContactId]
   ,[ContactCtg]
   ,[Name]
   ,[NameForLetters]
   ,[FirstName]
   ,[LastName]
   ,[OtherName]
   ,[AddressId]
   ,[Address1]
   ,[Address2]
   ,[Address3]
   ,[City]
   ,[State]
   ,[Zip]
   ,[ContactNumber]
   ,[ContactEmail]
   ,[ContactTypeId]
   ,[ContactType]
   ,[Comments]
   ,[DateModified]
   ,[ModifyUserId]
   ,[IsDeleted]
   ,[DateOfBirth]
   ,[SSNNo]
   ,[IsActive]
	)
	SELECT
		CONVERT(BIGINT, ('1' + CONVERT(VARCHAR(30), sma_MST_IndvContacts.cinnContactID))) AS UniqueContactId
	   ,CONVERT(BIGINT, sma_MST_IndvContacts.cinnContactID)								  AS ContactId
	   ,1																				  AS ContactCtg
	   ,CASE ISNULL(cinsLastName, '')
			WHEN ''
				THEN ''
			ELSE cinsLastName + ', '
		END
		+
		CASE ISNULL([cinsFirstName], '')
			WHEN ''
				THEN ''
			ELSE [cinsFirstName]
		END
		+
		CASE ISNULL(cinsMiddleName, '')
			WHEN ''
				THEN ''
			ELSE ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		END
		+
		CASE ISNULL(cinsSuffix, '')
			WHEN ''
				THEN ''
			ELSE ', ' + cinsSuffix
		END																				  AS [Name]
	   ,CASE ISNULL([cinsFirstName], '')
			WHEN ''
				THEN ''
			ELSE [cinsFirstName]
		END
		+
		CASE ISNULL(cinsMiddleName, '')
			WHEN ''
				THEN ''
			ELSE ' ' + SUBSTRING(cinsMiddleName, 1, 1) + '.'
		END
		+
		CASE ISNULL(cinsLastName, '')
			WHEN ''
				THEN ''
			ELSE ' ' + cinsLastName
		END
		+
		CASE ISNULL(cinsSuffix, '')
			WHEN ''
				THEN ''
			ELSE ', ' + cinsSuffix
		END																				  AS [NameForLetters]
	   ,ISNULL(sma_MST_IndvContacts.cinsFirstName, '')									  AS FirstName
	   ,ISNULL(sma_MST_IndvContacts.cinsLastName, '')									  AS LastName
	   ,ISNULL(sma_MST_IndvContacts.cinsNickName, '')									  AS OtherName
	   ,NULL																			  AS AddressId
	   ,NULL																			  AS Address1
	   ,NULL																			  AS Address2
	   ,NULL																			  AS Address3
	   ,NULL																			  AS City
	   ,NULL																			  AS [State]
	   ,NULL																			  AS Zip
	   ,NULL																			  AS ContactNumber
	   ,NULL																			  AS ContactEmail
	   ,sma_MST_IndvContacts.cinnContactTypeID											  AS ContactTypeId
	   ,sma_MST_OriginalContactTypes.octsDscrptn										  AS ContactType
	   ,sma_MST_IndvContacts.cinsComments												  AS Comments
	   ,GETDATE()																		  AS DateModified
	   ,347																				  AS ModifyUserId
	   ,0																				  AS IsDeleted
	   ,[cindBirthDate]
	   ,[cinsSSNNo]
	   ,[cinbStatus]
	--select max(len([cinsSSNNo]))
	FROM sma_MST_IndvContacts
	LEFT JOIN sma_MST_OriginalContactTypes
		ON sma_MST_OriginalContactTypes.octnOrigContactTypeID = sma_MST_IndvContacts.cinnContactTypeID
GO

--FILL OUT ADDRESS INFORMATION FOR ALL CONTACT TYPES
UPDATE [dbo].[sma_MST_AllContactInfo]
SET [AddressId] = Addrr.addnAddressID
   ,[Address1] = Addrr.addsAddress1
   ,[Address2] = Addrr.addsAddress2
   ,[Address3] = Addrr.addsAddress3
   ,[City] = Addrr.addsCity
   ,[State] = Addrr.addsStateCode
   ,[Zip] = Addrr.addsZip
   ,[County] = Addrr.addsCounty
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_Address Addrr
	ON (AllInfo.ContactId = Addrr.addnContactID)
	AND (AllInfo.ContactCtg = Addrr.addnContactCtgID)
GO

--fill out address information for all contact types, overwriting with primary addresses
UPDATE [dbo].[sma_MST_AllContactInfo]
SET [AddressId] = Addrr.addnAddressID
   ,[Address1] = Addrr.addsAddress1
   ,[Address2] = Addrr.addsAddress2
   ,[Address3] = Addrr.addsAddress3
   ,[City] = Addrr.addsCity
   ,[State] = Addrr.addsStateCode
   ,[Zip] = Addrr.addsZip
   ,[County] = Addrr.addsCounty
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_Address Addrr
	ON (AllInfo.ContactId = Addrr.addnContactID)
	AND (AllInfo.ContactCtg = Addrr.addnContactCtgID)
	AND Addrr.addbPrimary = 1
GO
--fill out email information
UPDATE [dbo].[sma_MST_AllContactInfo]
SET [ContactEmail] = Email.cewsEmailWebSite
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_EmailWebsite Email
	ON (AllInfo.ContactId = Email.cewnContactID)
	AND (AllInfo.ContactCtg = Email.cewnContactCtgID)
	AND Email.cewsEmailWebsiteFlag = 'E'
GO

--fill out default email information
UPDATE [dbo].[sma_MST_AllContactInfo]
SET [ContactEmail] = Email.cewsEmailWebSite
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_EmailWebsite Email
	ON (AllInfo.ContactId = Email.cewnContactID)
	AND (AllInfo.ContactCtg = Email.cewnContactCtgID)
	AND Email.cewsEmailWebsiteFlag = 'E'
	AND Email.cewbDefault = 1
GO
--fill out phone information
UPDATE [dbo].[sma_MST_AllContactInfo]
SET ContactNumber = Phones.cnnsContactNumber + (CASE
	WHEN Phones.[cnnsExtension] IS NULL
		THEN ''
	WHEN Phones.[cnnsExtension] = ''
		THEN ''
	ELSE ' x' + Phones.[cnnsExtension] + ''
END)
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_ContactNumbers Phones
	ON (AllInfo.ContactId = Phones.cnnnContactID)
	AND (AllInfo.ContactCtg = Phones.cnnnContactCtgID)
GO

--fill out default phone information
UPDATE [dbo].[sma_MST_AllContactInfo]
SET ContactNumber = Phones.cnnsContactNumber + (CASE
	WHEN Phones.[cnnsExtension] IS NULL
		THEN ''
	WHEN Phones.[cnnsExtension] = ''
		THEN ''
	ELSE ' x' + Phones.[cnnsExtension] + ''
END)
FROM sma_MST_AllContactInfo AllInfo
INNER JOIN sma_MST_ContactNumbers Phones
	ON (AllInfo.ContactId = Phones.cnnnContactID)
	AND (AllInfo.ContactCtg = Phones.cnnnContactCtgID)
	AND Phones.cnnbPrimary = 1
GO
GO
DELETE FROM [sma_MST_ContactTypesForContact]
INSERT INTO [sma_MST_ContactTypesForContact]
	(
	[ctcnContactCtgID]
   ,[ctcnContactID]
   ,[ctcnContactTypeID]
   ,[ctcnRecUserID]
   ,[ctcdDtCreated]
	)
	SELECT DISTINCT
		advnSrcContactCtg
	   ,advnSrcContactID
	   ,71
	   ,368
	   ,GETDATE()
	FROM sma_TRN_PdAdvt
	UNION
	SELECT DISTINCT
		2
	   ,lwfnLawFirmContactID
	   ,9
	   ,368
	   ,GETDATE()
	FROM sma_TRN_LawFirms
	UNION
	SELECT DISTINCT
		1
	   ,lwfnAttorneyContactID
	   ,7
	   ,368
	   ,GETDATE()
	FROM sma_TRN_LawFirms
	UNION
	SELECT DISTINCT
		2
	   ,incnInsContactID
	   ,11
	   ,368
	   ,GETDATE()
	FROM sma_TRN_InsuranceCoverage
	UNION
	SELECT DISTINCT
		1
	   ,incnAdjContactId
	   ,8
	   ,368
	   ,GETDATE()
	FROM sma_TRN_InsuranceCoverage
	UNION
	SELECT DISTINCT
		1
	   ,pornPOContactID
	   ,86
	   ,368
	   ,GETDATE()
	FROM sma_TRN_PoliceReports
	UNION
	SELECT DISTINCT
		1
	   ,usrncontactid
	   ,44
	   ,368
	   ,GETDATE()
	FROM sma_mst_users
GO