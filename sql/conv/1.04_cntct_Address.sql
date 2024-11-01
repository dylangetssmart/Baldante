/*
Work
Home
Other


*/


USE BaldanteSA
GO
/*
alter table [sma_MST_Address] disable trigger all
delete from [sma_MST_Address] 
DBCC CHECKIDENT ('[sma_MST_Address]', RESEED, 0);
alter table [sma_MST_Address] enable trigger all
*/
-- select distinct addr_Type from  [JoelBieberNeedles].[dbo].[multi_addresses]
-- select * from  [JoelBieberNeedles].[dbo].[multi_addresses] where addr_type not in ('Home','business', 'other')

ALTER TABLE [sma_MST_Address] DISABLE TRIGGER ALL
GO

-----------------------------------------------------------------------------
----(1)--- CONSTRUCT SMA_MST_ADDRESS FROM EXISTING SMA_MST_INDVCONTACTS
-----------------------------------------------------------------------------

-- Home from IndvContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Home Street],75)	 AS addsAddress1
	   ,null	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Home State],20)		 AS addsStateCode
	   ,left(c.[Address - Home City],50)	 AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Home Zip],10)	 AS addsZip
	   ,null AS addsCounty
	   ,left(c.[Address - Home Country],30) AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,1				AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL			AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Indvcontacts] i
		ON i.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = i.cinnContactCtg
			AND T.addsCode = 'HM'
	WHERE c.[Company or Person] = 'Person'
	AND	(
		ISNULL(c.[Address - Home Street], '') <> ''
		OR ISNULL(c.[Address - Home City], '') <> ''
		OR ISNULL(c.[Address - Home Zip], '') <> ''
		OR ISNULL(c.[Address - Home Country], '') <> ''
		OR ISNULL(c.[Address - Home State], '') <> ''
	)
GO

-- Business from IndvContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Work Street],75)		 AS addsAddress1
	   ,null	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Work State],20)		 AS addsStateCode
	   ,left(c.[Address - Work City],50)		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Work Zip],10)		 AS addsZip
	   ,null	 AS addsCounty
	   ,left(c.[Address - Work Country],30)	 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,0 AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Indvcontacts] i
		ON i.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = i.cinnContactCtg
			AND T.addsCode = 'WORK'
	WHERE c.[Company or Person] = 'Person'
	AND	(
		ISNULL(c.[Address - Work Street], '') <> ''
		OR ISNULL(c.[Address - Work City], '') <> ''
		OR ISNULL(c.[Address - Work Zip], '') <> ''
		OR ISNULL(c.[Address - Work Country], '') <> ''
		OR ISNULL(c.[Address - Work State], '') <> ''
	)
GO

-- Other from IndvContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Other Street],75)	 AS addsAddress1
	   ,null AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Other State],20)		 AS addsStateCode
	   ,left(c.[Address - Other City],50) AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Other Zip],10)		 AS addsZip
	   ,null		 AS addsCounty
	   ,left(c.[Address - Other Country],30)		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,0 AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,null AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Indvcontacts] i
		ON i.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = i.cinnContactCtg
			AND T.addsCode = 'OTH'
	WHERE c.[Company or Person] = 'Person'
	AND	(
		ISNULL(c.[Address - Other Street], '') <> ''
		OR ISNULL(c.[Address - Other City], '') <> ''
		OR ISNULL(c.[Address - Other Zip], '') <> ''
		OR ISNULL(c.[Address - Other Country], '') <> ''
		OR ISNULL(c.[Address - Other State], '') <> ''
	)
GO

-------------------------------------------------------
----(2)---- CONSTRUCT FROM SMA_MST_ORGCONTACTS
-------------------------------------------------------

-- Home from OrgContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
		,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Home Street],75)	 AS addsAddress1
	   ,null	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Home State],20)		 AS addsStateCode
	   ,left(c.[Address - Home City],50)	 AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Home Zip],10)	 AS addsZip
	   ,null AS addsCounty
	   ,left(c.[Address - Home Country],30) AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,1				AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL			AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Orgcontacts] O
		ON o.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'HO'
	WHERE c.[Company or Person] = 'Company'
	AND	(
		ISNULL(c.[Address - Home Street], '') <> ''
		OR ISNULL(c.[Address - Home City], '') <> ''
		OR ISNULL(c.[Address - Home Zip], '') <> ''
		OR ISNULL(c.[Address - Home Country], '') <> ''
		OR ISNULL(c.[Address - Home State], '') <> ''
	)
	--FROM [JoelBieberNeedles].[dbo].[multi_addresses] A
	--JOIN [sma_MST_Orgcontacts] O
	--	ON O.saga = A.names_id
	--JOIN [sma_MST_AddressTypes] T
	--	ON T.addnContactCategoryID = O.connContactCtg
	--		AND T.addsCode = 'HO'
	--WHERE (A.[addr_type] = 'Home'
	--	AND (ISNULL(A.[address], '') <> ''
	--	OR ISNULL(A.[address_2], '') <> ''
	--	OR ISNULL(A.[city], '') <> ''
	--	OR ISNULL(A.[state], '') <> ''
	--	OR ISNULL(A.[zipcode], '') <> ''
	--	OR ISNULL(A.[county], '') <> ''
	--	OR ISNULL(A.[country], '') <> ''))
GO


-- Business from OrgContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Work Street],75)		 AS addsAddress1
	   ,null	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Work State],20)		 AS addsStateCode
	   ,left(c.[Address - Work City],50)		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Work Zip],10)		 AS addsZip
	   ,null	 AS addsCounty
	   ,left(c.[Address - Work Country],30)	 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,0 AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Orgcontacts] O
		ON o.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'WORK'
	WHERE c.[Company or Person] = 'Company'
	AND	(
		ISNULL(c.[Address - Work Street], '') <> ''
		OR ISNULL(c.[Address - Work City], '') <> ''
		OR ISNULL(c.[Address - Work Zip], '') <> ''
		OR ISNULL(c.[Address - Work Country], '') <> ''
		OR ISNULL(c.[Address - Work State], '') <> ''
	)
GO

-- Other from OrgContacts
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID]
   ,[addnContactID]
   ,[addnAddressTypeID]
   ,[addsAddressType]
   ,[addsAddTypeCode]
   ,[addsAddress1]
   ,[addsAddress2]
   ,[addsAddress3]
   ,[addsStateCode]
   ,[addsCity]
   ,[addnZipID]
   ,[addsZip]
   ,[addsCounty]
   ,[addsCountry]
   ,[addbIsResidence]
   ,[addbPrimary]
   ,[adddFromDate]
   ,[adddToDate]
   ,[addnCompanyID]
   ,[addsDepartment]
   ,[addsTitle]
   ,[addnContactPersonID]
   ,[addsComments]
   ,[addbIsCurrent]
   ,[addbIsMailing]
   ,[addnRecUserID]
   ,[adddDtCreated]
   ,[addnModifyUserID]
   ,[adddDtModified]
   ,[addnLevelNo]
   ,[caseno]
   ,[addbDeleted]
   ,[addsZipExtn]
   ,[saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(c.[Address - Other Street],75)	 AS addsAddress1
	   ,null AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,left(c.[Address - Other State],20)		 AS addsStateCode
	   ,left(c.[Address - Other City],50) AS addsCity
	   ,NULL			 AS addnZipID
	   ,left(c.[Address - Other Zip],10)		 AS addsZip
	   ,null		 AS addsCounty
	   ,left(c.[Address - Other Country],30)		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,0 AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,null AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM Baldante..contacts_csv c
	JOIN [sma_MST_Orgcontacts] O
		ON o.saga = c.[Highrise ID]
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'BR'
	WHERE c.[Company or Person] = 'Company'
	AND	(
		ISNULL(c.[Address - Other Street], '') <> ''
		OR ISNULL(c.[Address - Other City], '') <> ''
		OR ISNULL(c.[Address - Other Zip], '') <> ''
		OR ISNULL(c.[Address - Other Country], '') <> ''
		OR ISNULL(c.[Address - Other State], '') <> ''
	)
GO

---(APPENDIX)---
---(A.0)
INSERT INTO [sma_MST_Address]
	(
	addnContactCtgID
   ,addnContactID
   ,addnAddressTypeID
   ,addsAddressType
   ,addsAddTypeCode
   ,addbPrimary
   ,addnRecUserID
   ,adddDtCreated
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,(
			SELECT
				addnAddTypeID
			FROM [sma_MST_AddressTypes]
			WHERE addsDscrptn = 'Other'
				AND addnContactCategoryID = I.cinnContactCtg
		)				 
		AS addnAddressTypeID
	   ,'Other'			 AS addsAddressType
	   ,'OTH'			 AS addsAddTypeCode
	   ,1				 AS addbPrimary
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	FROM [sma_MST_IndvContacts] I
	LEFT JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
			AND A.addnContactCtgID = I.cinnContactCtg
	WHERE A.addnAddressID IS NULL

---(A.1)
INSERT INTO [sma_MST_AddressTypes]
	(
	addsCode
   ,addsDscrptn
   ,addnContactCategoryID
   ,addbIsWork
	)
	SELECT
		'OTH_O'
	   ,'Other'
	   ,2
	   ,0
	EXCEPT
	SELECT
		addsCode
	   ,addsDscrptn
	   ,addnContactCategoryID
	   ,addbIsWork
	FROM [sma_MST_AddressTypes]


INSERT INTO [sma_MST_Address]
	(
	addnContactCtgID
   ,addnContactID
   ,addnAddressTypeID
   ,addsAddressType
   ,addsAddTypeCode
   ,addbPrimary
   ,addnRecUserID
   ,adddDtCreated
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,(
			SELECT
				addnAddTypeID
			FROM [sma_MST_AddressTypes]
			WHERE addsDscrptn = 'Other'
				AND addnContactCategoryID = O.connContactCtg
		)				 
		AS addnAddressTypeID
	   ,'Other'			 AS addsAddressType
	   ,'OTH_O'			 AS addsAddTypeCode
	   ,1				 AS addbPrimary
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	FROM [sma_MST_OrgContacts] O
	LEFT JOIN [sma_MST_Address] A
		ON A.addnContactID = O.connContactID
			AND A.addnContactCtgID = O.connContactCtg
	WHERE A.addnAddressID IS NULL

----(APPENDIX)----
UPDATE [sma_MST_Address]
SET addbPrimary = 1
FROM (
	SELECT
		I.cinnContactID AS CID
	   ,A.addnAddressID AS AID
	   ,ROW_NUMBER() OVER (PARTITION BY I.cinnContactID ORDER BY A.addnAddressID ASC) AS RowNumber
	FROM [sma_MST_Indvcontacts] I
	JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
		AND A.addnContactCtgID = I.cinnContactCtg
		AND A.addbPrimary <> 1
	WHERE I.cinnContactID NOT IN (
			SELECT
				I.cinnContactID
			FROM [sma_MST_Indvcontacts] I
			JOIN [sma_MST_Address] A
				ON A.addnContactID = I.cinnContactID
				AND A.addnContactCtgID = I.cinnContactCtg
				AND A.addbPrimary = 1
		)
) A
WHERE A.RowNumber = 1
AND A.AID = addnAddressID

UPDATE [sma_MST_Address]
SET addbPrimary = 1
FROM (
	SELECT
		O.connContactID AS CID
	   ,A.addnAddressID AS AID
	   ,ROW_NUMBER() OVER (PARTITION BY O.connContactID ORDER BY A.addnAddressID ASC) AS RowNumber
	FROM [sma_MST_OrgContacts] O
	JOIN [sma_MST_Address] A
		ON A.addnContactID = O.connContactID
		AND A.addnContactCtgID = O.connContactCtg
		AND A.addbPrimary <> 1
	WHERE O.connContactID NOT IN (
			SELECT
				O.connContactID
			FROM [sma_MST_OrgContacts] O
			JOIN [sma_MST_Address] A
				ON A.addnContactID = O.connContactID
				AND A.addnContactCtgID = O.connContactCtg
				AND A.addbPrimary = 1
		)
) A
WHERE A.RowNumber = 1
AND A.AID = addnAddressID


---
ALTER TABLE [sma_MST_Address] ENABLE TRIGGER ALL
GO
---



------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [SA].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [SA].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

