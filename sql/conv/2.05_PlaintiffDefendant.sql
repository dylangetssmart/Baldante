USE BaldanteSA
GO
/*
alter table [sma_TRN_Defendants] disable trigger all
delete from [sma_TRN_Defendants] 
DBCC CHECKIDENT ('[sma_TRN_Defendants]', RESEED, 0);
alter table [sma_TRN_Defendants] enable trigger all

alter table [sma_TRN_Plaintiff] disable trigger all
delete from [sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[sma_TRN_Plaintiff]', RESEED, 0);
alter table [sma_TRN_Plaintiff] enable trigger all

select * from [sma_TRN_Plaintiff] enable trigger all
*/

-------------------------------------------------------------------------------
-- Initialize #################################################################
-- Add [saga_party] to [sma_TRN_Plaintiff]and [sma_TRN_Defendants]
-------------------------------------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
BEGIN
	ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] INT NULL;
END

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
BEGIN
	ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] INT NULL;
END

-- Disable table triggers
ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Defendants] DISABLE TRIGGER ALL
GO

-------------------------------------------------------------------------------
-- Construct sma_TRN_Plaintiff ################################################
-- 
-------------------------------------------------------------------------------

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID]
   ,[plnnContactCtg]
   ,[plnnContactID]
   ,[plnnAddressID]
   ,[plnnRole]
   ,[plnbIsPrimary]
   ,[plnbWCOut]
   ,[plnnPartiallySettled]
   ,[plnbSettled]
   ,[plnbOut]
   ,[plnbSubOut]
   ,[plnnSeatBeltUsed]
   ,[plnnCaseValueID]
   ,[plnnCaseValueFrom]
   ,[plnnCaseValueTo]
   ,[plnnPriority]
   ,[plnnDisbursmentWt]
   ,[plnbDocAttached]
   ,[plndFromDt]
   ,[plndToDt]
   ,[plnnRecUserID]
   ,[plndDtCreated]
   ,[plnnModifyUserID]
   ,[plndDtModified]
   ,[plnnLevelNo]
   ,[plnsMarked]
   ,[saga]
   ,[plnnNoInj]
   ,[plnnMissing]
   ,[plnnLIPBatchNo]
   ,[plnnPlaintiffRole]
   ,[plnnPlaintiffGroup]
   ,[plnnPrimaryContact]
   ,[saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368				AS [plnnRecUserID]
	   ,GETDATE()		AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL			AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1				AS [plnnPrimaryContact]
	   ,NULL			AS [saga_party]
	--SELECT cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	FROM Baldante..contacts c
	JOIN [sma_TRN_Cases] CAS
		ON CAS.saga = c.Id
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.SAGA = CONVERT(VARCHAR, c.ID)
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = '(P)-Plaintiff'
			AND S.sbrnRoleID = 4

--FROM TestNeedles.[dbo].[party_indexed] P
--	JOIN [sma_TRN_Cases] CAS
--		on CAS.cassCaseNumber = P.case_id  
--	JOIN IndvOrgContacts_Indexed CIO
--		on CIO.SAGA = P.party_id
--	JOIN [PartyRoles] pr
--		on pr.[Needles Roles] = p.[role]
--	JOIN [sma_MST_SubRole] S
--		on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
--			and s.sbrsDscrptn = [sa roles]
--			and  S.sbrnRoleID=4
--WHERE pr.[sa party] = 'Plaintiff' 
GO


/*
-------------------------------------------------------------------------------
-- sma_TRN_Defendants ###############################################

-------------------------------------------------------------------------------
*/

--insert into [sma_TRN_Defendants] (
--	[defnCaseID]
--	,[defnContactCtgID]
--	,[defnContactID]
--	,[defnAddressID]
--	,[defnSubRole]
--	,[defbIsPrimary]
--	,[defbCounterClaim]
--	,[defbThirdParty]
--	,[defsThirdPartyRole]
--	,[defnPriority]
--	,[defdFrmDt]
--	,[defdToDt]
--	,[defnRecUserID]
--	,[defdDtCreated]
--	,[defnModifyUserID]
--	,[defdDtModified]
--	,[defnLevelNo]
--	,[defsMarked]
--	,[saga]
--	,[saga_party]
--	)
--select casnCaseID								as [defnCaseID]
--	,CIO.CTG									as [defnContactCtgID]
--	,CIO.CID									as [defnContactID]
--	,CIO.AID									as [defnAddressID]
--	,sbrnSubRoleId								as [defnSubRole]
--	,1											as [defbIsPrimary]
--	,null
--	,null
--	,null
--	,null
--	,null
--	,null
--	,368										as [defnRecUserID]
--	,GETDATE()									as [defdDtCreated]
--	,null										as [defnModifyUserID]
--	,null										as [defdDtModified]
--	,null										as [defnLevelNo]
--	,null
--	,null
--	,NULL										as [saga_party]
--from Baldante..contacts c
--	JOIN [sma_TRN_Cases] CAS
--		on CAS.saga = c.ID
--	JOIN IndvOrgContacts_Indexed CIO
--		on CIO.SAGA = c.ID
--	JOIN [sma_MST_SubRole] S
--		on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
--			and s.sbrsDscrptn = '(D)-Defendant'
--			and  S.sbrnRoleID = 5


--from TestNeedles.[dbo].[party_indexed] P
--	join [sma_TRN_Cases] CAS
--		on CAS.cassCaseNumber = P.case_id
--	join IndvOrgContacts_Indexed ACIO
--		on ACIO.SAGA = P.party_id
--	join [PartyRoles] pr
--		on pr.[Needles Roles] = p.[role]
--	join [sma_MST_SubRole] S
--		on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
--			and s.sbrsDscrptn = [sa roles]
--			and S.sbrnRoleID = 5
--where pr.[sa party] = 'Defendant'
GO



/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID]
   ,[plnnContactCtg]
   ,[plnnContactID]
   ,[plnnAddressID]
   ,[plnnRole]
   ,[plnbIsPrimary]
   ,[plnbWCOut]
   ,[plnnPartiallySettled]
   ,[plnbSettled]
   ,[plnbOut]
   ,[plnbSubOut]
   ,[plnnSeatBeltUsed]
   ,[plnnCaseValueID]
   ,[plnnCaseValueFrom]
   ,[plnnCaseValueTo]
   ,[plnnPriority]
   ,[plnnDisbursmentWt]
   ,[plnbDocAttached]
   ,[plndFromDt]
   ,[plndToDt]
   ,[plnnRecUserID]
   ,[plndDtCreated]
   ,[plnnModifyUserID]
   ,[plndDtModified]
   ,[plnnLevelNo]
   ,[plnsMarked]
   ,[saga]
   ,[plnnNoInj]
   ,[plnnMissing]
   ,[plnnLIPBatchNo]
   ,[plnnPlaintiffRole]
   ,[plnnPlaintiffGroup]
   ,[plnnPrimaryContact]
	)
	SELECT
		casnCaseID AS [plnnCaseID]
	   ,1		   AS [plnnContactCtg]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Plaintiff'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [plnnContactID]
	   ,-- Unidentified Plaintiff
		NULL	   AS [plnnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(P)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS plnnRole
	   ,1		   AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368		   AS [plnnRecUserID]
	   ,GETDATE()  AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1		   AS [plnnPrimaryContact]
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Plaintiff] T
		ON T.plnnCaseID = CAS.casnCaseID
	WHERE plnnCaseID IS NULL
GO



--UPDATE sma_TRN_Plaintiff set plnbIsPrimary=0

--UPDATE sma_TRN_Plaintiff set plnbIsPrimary=1
--FROM
--(
--SELECT DISTINCT 
--	   T.plnnCaseID, ROW_NUMBER() OVER (Partition BY T.plnnCaseID order by P.record_num) as RowNumber,
--	   T.plnnPlaintiffID as ID  
--    FROM sma_TRN_Plaintiff T
--    LEFT JOIN TestNeedles.[dbo].[party_indexed] P on P.TableIndex=T.saga_party
--) A
--WHERE A.RowNumber=1
--and plnnPlaintiffID = A.ID



/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix B)-- every case need at least one defendant
*/

INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID]
   ,[defnContactCtgID]
   ,[defnContactID]
   ,[defnAddressID]
   ,[defnSubRole]
   ,[defbIsPrimary]
   ,[defbCounterClaim]
   ,[defbThirdParty]
   ,[defsThirdPartyRole]
   ,[defnPriority]
   ,[defdFrmDt]
   ,[defdToDt]
   ,[defnRecUserID]
   ,[defdDtCreated]
   ,[defnModifyUserID]
   ,[defdDtModified]
   ,[defnLevelNo]
   ,[defsMarked]
   ,[saga]
	)
	SELECT
		casnCaseID AS [defnCaseID]
	   ,1		   AS [defnContactCtgID]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Defendant'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [defnContactID]
	   ,NULL	   AS [defnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(D)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS [defnSubRole]
	   ,1		   AS [defbIsPrimary]
	   ,-- reexamine??
		NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368		   AS [defnRecUserID]
	   ,GETDATE()  AS [defdDtCreated]
	   ,368		   AS [defnModifyUserID]
	   ,GETDATE()  AS [defdDtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Defendants] D
		ON D.defnCaseID = CAS.casnCaseID
	WHERE D.defnCaseID IS NULL

----
--UPDATE sma_TRN_Defendants SET defbIsPrimary=0

--UPDATE sma_TRN_Defendants SET defbIsPrimary=1
--FROM (
--    SELECT DISTINCT 
--		D.defnCaseID, 
--		ROW_NUMBER() OVER (Partition BY D.defnCaseID order by P.record_num) as RowNumber,
--		D.defnDefendentID as ID  
--    FROM sma_TRN_Defendants D
--    LEFT JOIN TestNeedles.[dbo].[party_indexed] P on P.TableIndex=D.saga_party
--) A
--WHERE A.RowNumber=1
--and defnDefendentID = A.ID

GO

---
ALTER TABLE [sma_TRN_Defendants] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO
