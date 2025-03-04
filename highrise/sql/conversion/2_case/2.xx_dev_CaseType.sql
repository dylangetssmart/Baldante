-- Author: Dylan Smith
-- Date: 2024-09-09
-- Description: Brief description of the script's purpose

/*
This script performs the following tasks:
  - [Task 1]
  - [Task 2]
  - ...

Notes:
	- Because batch separators (GO) are required due to schema changes (adding columns),
	we use a temporary table instead of variables, which are locally scoped
	see: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16#variable-scope
	see also: https://stackoverflow.com/a/56370223
	- After making schema changes (e.g. adding a new column to an existing table) statements using the new schema must be compiled separately in a different batch.
	- For example, you cannot ALTER a table to add a column, then select that column in the same batch - because while compiling the execution plan, that column does not exist for selecting.
*/

USE BaldanteHighriseSA
GO

-- Create a temporary table to store variable values
DROP TABLE IF EXISTS #TempVariables;

CREATE TABLE #TempVariables (
	OfficeName NVARCHAR(255)
   ,StateName NVARCHAR(100)
   ,PhoneNumber NVARCHAR(50)
   ,CaseGroup NVARCHAR(100)
   ,VenderCaseType NVARCHAR(25)
);

-- Insert values into the temporary table
INSERT INTO #TempVariables
	(
	OfficeName
   ,StateName
   ,PhoneNumber
   ,CaseGroup
   ,VenderCaseType
	)
VALUES (
'Baldante & Rubenstein', 'Pennsylvania', '2157351616', 'Highrise', 'BaldanteCaseType'
);


-- (0.1) sma_MST_CaseGroup -----------------------------------------------------
-- Create a default case group for data that does not neatly fit elsewhere
--IF NOT EXISTS
--( 
--	select *
--	from [sma_MST_CaseGroup]
--	where [cgpsDscrptn] = (SELECT CaseGroup FROM #TempVariables)
--)
--BEGIN
--	INSERT INTO [sma_MST_CaseGroup]
--	(
--		[cgpsCode]
--		,[cgpsDscrptn]
--		,[cgpnRecUserId]
--		,[cgpdDtCreated]
--		,[cgpnModifyUserID]
--		,[cgpdDtModified]
--		,[cgpnLevelNo]
--		,[IncidentTypeID]
--		,[LimitGroupStatuses]
--	)
--	SELECT 
--		'FORCONVERSION'			as [cgpsCode]
--		,(
--			SELECT CaseGroup
--			FROM #TempVariables
--		)						as [cgpsDscrptn]
--		,368					as [cgpnRecUserId]
--		,getdate()				as [cgpdDtCreated]
--		,null					as [cgpnModifyUserID]
--		,null					as [cgpdDtModified]
--		,null					as [cgpnLevelNo]
--		,(
--			select IncidentTypeID
--			from [sma_MST_IncidentTypes]
--			where Description = 'General Negligence'
--		)						as [IncidentTypeID]
--		,null					as [LimitGroupStatuses]
--END
--GO


-- (0.2) sma_MST_Offices -----------------------------------------------------
-- Create an office for conversion client
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_mst_offices]
		WHERE office_name = (
				SELECT
					OfficeName
				FROM #TempVariables
			)
	)
BEGIN
	INSERT INTO [sma_mst_offices]
		(
		[office_status]
	   ,[office_name]
	   ,[state_id]
	   ,[is_default]
	   ,[date_created]
	   ,[user_created]
	   ,[date_modified]
	   ,[user_modified]
	   ,[Letterhead]
	   ,[UniqueContactId]
	   ,[PhoneNumber]
		)
		SELECT
			1					AS [office_status]
		   ,(
				SELECT
					OfficeName
				FROM #TempVariables
			)					
			AS [office_name]
		   ,(
				SELECT
					sttnStateID
				FROM sma_MST_States
				WHERE sttsDescription = (
						SELECT
							StateName
						FROM #TempVariables
					)
			)					
			AS [state_id]
		   ,1					AS [is_default]
		   ,GETDATE()			AS [date_created]
		   ,'rdoshi'			AS [user_created]
		   ,GETDATE()			AS [date_modified]
		   ,'dbo'				AS [user_modified]
		   ,'LetterheadUt.docx' AS [Letterhead]
		   ,NULL				AS [UniqueContactId]
		   ,(
				SELECT
					PhoneNumber
				FROM #TempVariables
			)					
			AS [PhoneNumber]
END
GO


-- (1) sma_MST_CaseType -----------------------------------------------------
-- (1.1) - Add a case type field that acts as conversion flag
-- for future reference: "VenderCaseType"
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'VenderCaseType'
			AND object_id = OBJECT_ID(N'sma_MST_CaseType')
	)
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType VARCHAR(100)
END
GO

-- (1.2) - Create case types from CaseTypeMixtures
INSERT INTO [sma_MST_CaseType]
	(
	[cstsCode]
   ,[cstsType]
   ,[cstsSubType]
   ,[cstnWorkflowTemplateID]
   ,[cstnExpectedResolutionDays]
   ,[cstnRecUserID]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbTimeTracking]
   ,[cstnGroupID]
   ,[cstnGovtMunType]
   ,[cstnIsMassTort]
   ,[cstnStatusID]
   ,[cstnStatusTypeID]
   ,[cstbActive]
   ,[cstbUseIncident1]
   ,[cstsIncidentLabel1]
   ,[VenderCaseType]
	)
	SELECT
		NULL
	   ,  -- cstsCode
		'Highrise'
	   ,  -- cstsType
		NULL
	   ,  -- cstsSubType
		NULL
	   ,  -- cstnWorkflowTemplateID
		720
	   ,  -- cstnExpectedResolutionDays (Hardcode 2 years)
		368
	   ,  -- cstnRecUserID
		GETDATE()
	   ,  -- cstdDtCreated
		368
	   ,  -- cstnModifyUserID
		GETDATE()
	   ,  -- cstdDtModified
		0
	   ,  -- cstnLevelNo
		NULL
	   ,  -- cstbTimeTracking
		(  -- Subquery for cstnGroupID
			SELECT
				cgpnCaseGroupID
			FROM sma_MST_caseGroup
			WHERE cgpsDscrptn = 'General Negligence'
		)
	   ,NULL
	   ,  -- cstnGovtMunType
		NULL
	   ,  -- cstnIsMassTort
		(  -- Subquery for cstnStatusID
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)
	   ,(  -- Subquery for cstnStatusTypeID
			SELECT
				stpnStatusTypeID
			FROM [sma_MST_CaseStatusType]
			WHERE stpsStatusType = 'Status'
		)
	   ,1
	   ,  -- cstbActive
		1
	   ,  -- cstbUseIncident1
		'Incident 1'
	   ,  -- cstsIncidentLabel1
		(  -- Subquery for VenderCaseType
			SELECT
				VenderCaseType
			FROM #TempVariables
		)
	WHERE NOT EXISTS (
			SELECT
				1
			FROM [sma_MST_CaseType] CST
			WHERE CST.cstsType = 'Highrise'
		);


--FROM [CaseTypeMixture] MIX 
--LEFT JOIN [sma_MST_CaseType] ct
--	on ct.cststype = mix.[SmartAdvocate Case Type]
--WHERE ct.cstncasetypeid IS NULL
GO

-- (1.3) - Add conversion flag to case types created above
--UPDATE [sma_MST_CaseType] 
--SET	VenderCaseType = (SELECT VenderCaseType FROM #TempVariables)
--FROM [CaseTypeMixture] MIX 
--JOIN [sma_MST_CaseType] ct
--	on ct.cststype = mix.[SmartAdvocate Case Type]
--WHERE isnull(VenderCaseType,'') = ''
--GO

-- (2) sma_MST_CaseSubType -----------------------------------------------------
-- (2.1) - sma_MST_CaseSubTypeCode
-- For non-null values of SA Case Sub Type from CaseTypeMixture,
-- add distinct values to CaseSubTypeCode and populate stcsDscrptn
--INSERT INTO [dbo].[sma_MST_CaseSubTypeCode]
--(
--	stcsDscrptn 
--)
--SELECT DISTINCT MIX.[SmartAdvocate Case Sub Type]
--FROM [CaseTypeMixture] MIX 
--WHERE isnull(MIX.[SmartAdvocate Case Sub Type],'') <> ''
--EXCEPT
--SELECT
--	stcsDscrptn
--	from [dbo].[sma_MST_CaseSubTypeCode]
--GO

---- (2.2) - sma_MST_CaseSubType
---- Construct CaseSubType using CaseTypes
--INSERT INTO [sma_MST_CaseSubType]
--(
--	[cstsCode], 
--	[cstnGroupID], 
--	[cstsDscrptn], 
--	[cstnRecUserId], 
--	[cstdDtCreated], 
--	[cstnModifyUserID], 
--	[cstdDtModified], 
--	[cstnLevelNo], 
--	[cstbDefualt], 
--	[saga], 
--	[cstnTypeCode]
--)
--SELECT  
--	null								as [cstsCode]
--	,cstncasetypeid						as [cstnGroupID]
--	,[SmartAdvocate Case Sub Type]		as [cstsDscrptn]
--	,368 								as [cstnRecUserId]
--	,getdate()							as [cstdDtCreated]
--	,null								as [cstnModifyUserID]
--	,null								as [cstdDtModified]
--	,null								as [cstnLevelNo]
--	,1									as [cstbDefualt]
--	,null								as [saga]
--	,(
--		select stcnCodeId
--		from [sma_MST_CaseSubTypeCode]
--		where stcsDscrptn = [SmartAdvocate Case Sub Type]
--	)									as [cstnTypeCode] 
--FROM [sma_MST_CaseType] CST
--JOIN [CaseTypeMixture] MIX
--	on MIX.[SmartAdvocate Case Type] = CST.cststype
--LEFT JOIN [sma_MST_CaseSubType] sub
--	on sub.[cstnGroupID] = cstncasetypeid
--	and sub.[cstsDscrptn] = [SmartAdvocate Case Sub Type]
--WHERE sub.cstncasesubtypeID is null
--and isnull([SmartAdvocate Case Sub Type],'') <> ''
--Go

/*
---(2.2) sma_MST_CaseSubType
insert into [sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
select  	null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		MIX.[SmartAdvocate Case Sub Type] as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1				as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=MIX.[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cstncasetypeid and sub.[cstsDscrptn] = MIX.[SmartAdvocate Case Sub Type]
WHERE isnull(MIX.[SmartAdvocate Case Type],'')<>''
and sub.cstncasesubtypeID is null
*/


-- insert into subrolecode, p and d
-- insert into subrole

-- Insert Plaintiff SubRole
INSERT INTO [sma_MST_SubRole]
	(
	[sbrsCode]
   ,[sbrnRoleID]
   ,[sbrsDscrptn]
   ,[sbrnCaseTypeID]
   ,[sbrnPriority]
   ,[sbrnRecUserID]
   ,[sbrdDtCreated]
   ,[sbrnModifyUserID]
   ,[sbrdDtModified]
   ,[sbrnLevelNo]
   ,[sbrbDefualt]
   ,[saga]
   ,[sbrnTypeCode]
	)
	SELECT
		'P'				   AS [sbrsCode]
	   ,4				   AS [sbrnRoleID]
	   ,'(P)-Plaintiff'	   AS [sbrsDscrptn]
	   ,CST.cstnCaseTypeID AS [sbrnCaseTypeID]
	   ,NULL			   AS [sbrnPriority]
	   ,368				   AS [sbrnRecUserID]
	   ,GETDATE()		   AS [sbrdDtCreated]
	   ,368				   AS [sbrnModifyUserID]
	   ,GETDATE()		   AS [sbrdDtModified]
	   ,NULL			   AS [sbrnLevelNo]
	   ,NULL			   AS [sbrbDefualt]
	   ,NULL			   AS [saga]
	   ,(
			SELECT
				smsrc.srcnCodeId
			FROM sma_mst_SubRoleCode smsrc
			WHERE smsrc.srcsDscrptn = '(D)-Plaintiff'
		)				   
		AS [sbrnTypeCode]
	FROM [sma_MST_CaseType] CST
	WHERE CST.cstsType = 'Highrise'
		AND NOT EXISTS (
			SELECT
				1
			FROM [sma_MST_SubRole] SR
			WHERE SR.sbrsCode = 'P'
				AND SR.sbrnCaseTypeID = CST.cstnCaseTypeID
		);

-- Insert Defendant SubRole
INSERT INTO [sma_MST_SubRole]
	(
	[sbrsCode]
   ,[sbrnRoleID]
   ,[sbrsDscrptn]
   ,[sbrnCaseTypeID]
   ,[sbrnPriority]
   ,[sbrnRecUserID]
   ,[sbrdDtCreated]
   ,[sbrnModifyUserID]
   ,[sbrdDtModified]
   ,[sbrnLevelNo]
   ,[sbrbDefualt]
   ,[saga]
   ,[sbrnTypeCode]
	)
	SELECT
		'D'				   AS [sbrsCode]
	   ,5				   AS [sbrnRoleID]
	   ,'(D)-Defendant'	   AS [sbrsDscrptn]
	   ,CST.cstnCaseTypeID AS [sbrnCaseTypeID]
	   ,NULL			   AS [sbrnPriority]
	   ,368				   AS [sbrnRecUserID]
	   ,GETDATE()		   AS [sbrdDtCreated]
	   ,368				   AS [sbrnModifyUserID]
	   ,GETDATE()		   AS [sbrdDtModified]
	   ,NULL			   AS [sbrnLevelNo]
	   ,NULL			   AS [sbrbDefualt]
	   ,NULL			   AS [saga]
	   ,(
			SELECT
				smsrc.srcnCodeId
			FROM sma_mst_SubRoleCode smsrc
			WHERE smsrc.srcsDscrptn = '(D)-Defendant'
		)				   
		AS [sbrnTypeCode]
	FROM [sma_MST_CaseType] CST
	WHERE CST.cstsType = 'Highrise'
		AND NOT EXISTS (
			SELECT
				1
			FROM [sma_MST_SubRole] SR
			WHERE SR.sbrsCode = 'D'
				AND SR.sbrnCaseTypeID = CST.cstnCaseTypeID
		);
GO

-- (3.0) sma_MST_SubRole -----------------------------------------------------
--INSERT INTO [sma_MST_SubRole]
--(
--	[sbrsCode]
--	,[sbrnRoleID]
--	,[sbrsDscrptn]
--	,[sbrnCaseTypeID]
--	,[sbrnPriority]
--	,[sbrnRecUserID]
--	,[sbrdDtCreated]
--	,[sbrnModifyUserID]
--	,[sbrdDtModified]
--	,[sbrnLevelNo]
--	,[sbrbDefualt]
--	,[saga]
--)
--SELECT 
--	[sbrsCode]					as [sbrsCode]
--	,[sbrnRoleID]				as [sbrnRoleID]
--	,[sbrsDscrptn]				as [sbrsDscrptn]
--	,CST.cstnCaseTypeID			as [sbrnCaseTypeID]
--	,[sbrnPriority]				as [sbrnPriority]
--	,[sbrnRecUserID]			as [sbrnRecUserID]
--	,[sbrdDtCreated]			as [sbrdDtCreated]
--	,[sbrnModifyUserID]			as [sbrnModifyUserID]
--	,[sbrdDtModified]			as [sbrdDtModified]
--	,[sbrnLevelNo]				as [sbrnLevelNo]
--	,[sbrbDefualt]				as [sbrbDefualt]
--	,[saga]						as [saga] 
--FROM sma_MST_CaseType CST
--where CST.cstsType = 'Highrise'
--LEFT JOIN sma_mst_subrole S
--	on CST.cstnCaseTypeID = S.sbrnCaseTypeID or S.sbrnCaseTypeID = 1
----JOIN [CaseTypeMixture] MIX
----	on MIX.matcode = CST.cstsCode  
----WHERE VenderCaseType = (SELECT VenderCaseType FROM #TempVariables)
----and isnull(MIX.[SmartAdvocate Case Type],'') = ''

-- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
--UPDATE sma_MST_SubRole
--SET sbrnTypeCode = A.CodeId
--FROM
--(
--	SELECT
--		S.sbrsDscrptn		as sbrsDscrptn
--		,S.sbrnSubRoleId	as SubRoleId
--		,(
--			select max(srcnCodeId)
--			from sma_MST_SubRoleCode
--			where srcsDscrptn = S.sbrsDscrptn
--		) 					as CodeId
--	FROM sma_MST_SubRole S
--	JOIN sma_MST_CaseType CST
--		on CST.cstnCaseTypeID = S.sbrnCaseTypeID
--		and CST.VenderCaseType = (SELECT VenderCaseType FROM #TempVariables)
--) A
--WHERE A.SubRoleId = sbrnSubRoleId


---- (4) specific plaintiff and defendant party roles ----------------------------------------------------
--INSERT INTO [sma_MST_SubRoleCode]
--(
--	srcsDscrptn
--	,srcnRoleID 
--)
--(
--	SELECT '(P)-Default Role', 4

--	UNION ALL

--	SELECT '(D)-Default Role', 5

--	UNION ALL

--	SELECT [SA Roles], 4
--	FROM [PartyRoles]
--	WHERE [SA Party] = 'Plaintiff'

--	UNION ALL

--	SELECT [SA Roles], 5
--	FROM [PartyRoles]
--	WHERE [SA Party]='Defendant'
--)
--EXCEPT
--SELECT
--	srcsDscrptn
--	,srcnRoleID
--FROM [sma_MST_SubRoleCode]


-- (4.1) Not already in sma_MST_SubRole-----
--INSERT INTO sma_MST_SubRole
--(
--	sbrnRoleID
--	,sbrsDscrptn
--	,sbrnCaseTypeID
--	,sbrnTypeCode
--)
--SELECT
--	T.sbrnRoleID
--	,T.sbrsDscrptn
--	,T.sbrnCaseTypeID
--	,T.sbrnTypeCode
--FROM 
--(
--	SELECT 
--		R.PorD			   		as sbrnRoleID,
--		R.[role]			    as sbrsDscrptn,
--		CST.cstnCaseTypeID	    as sbrnCaseTypeID,
--		(select srcnCodeId from sma_MST_SubRoleCode where srcsDscrptn = R.role and srcnRoleID = R.PorD) as sbrnTypeCode
--	FROM sma_MST_CaseType CST
--CROSS JOIN 
--(
--	SELECT '(P)-Default Role' as role, 4 as PorD
--		UNION ALL
--	SELECT '(D)-Default Role' as role, 5 as PorD
--		UNION ALL
--	SELECT [SA Roles]  as role, 4 as PorD from [PartyRoles] where [SA Party]='Plaintiff'
--		UNION ALL
--	SELECT [SA Roles]  as role, 5 as PorD from [PartyRoles] where [SA Party]='Defendant'
--) R
--WHERE CST.VenderCaseType = (SELECT VenderCaseType FROM #TempVariables)
--) T
--EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole



/* 
---Checking---
SELECT CST.cstnCaseTypeID,CST.cstsType,sbrsDscrptn
FROM sma_MST_SubRole S
INNER JOIN sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID
WHERE CST.VenderCaseType='SLFCaseType'
and sbrsDscrptn='(D)-Default Role'
ORDER BY CST.cstnCaseTypeID
*/


-------- (5) sma_TRN_cases ----------------------
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

ALTER TABLE sma_TRN_Cases
ALTER COLUMN [saga] INT
GO

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_db'
			AND Object_ID = OBJECT_ID(N'sma_trn_Cases')
	)
BEGIN
	ALTER TABLE sma_trn_Cases ADD [saga_db] VARCHAR(5);
END
GO

INSERT INTO [sma_TRN_Cases]
	(
	[cassCaseNumber]
   ,[casbAppName]
   ,[cassCaseName]
   ,[casnCaseTypeID]
   ,[casnState]
   ,[casdStatusFromDt]
   ,[casnStatusValueID]
   ,[casdsubstatusfromdt]
   ,[casnSubStatusValueID]
   ,[casdOpeningDate]
   ,[casdClosingDate]
   ,[casnCaseValueID]
   ,[casnCaseValueFrom]
   ,[casnCaseValueTo]
   ,[casnCurrentCourt]
   ,[casnCurrentJudge]
   ,[casnCurrentMagistrate]
   ,[casnCaptionID]
   ,[cassCaptionText]
   ,[casbMainCase]
   ,[casbCaseOut]
   ,[casbSubOut]
   ,[casbWCOut]
   ,[casbPartialOut]
   ,[casbPartialSubOut]
   ,[casbPartiallySettled]
   ,[casbInHouse]
   ,[casbAutoTimer]
   ,[casdExpResolutionDate]
   ,[casdIncidentDate]
   ,[casnTotalLiability]
   ,[cassSharingCodeID]
   ,[casnStateID]
   ,[casnLastModifiedBy]
   ,[casdLastModifiedDate]
   ,[casnRecUserID]
   ,[casdDtCreated]
   ,[casnModifyUserID]
   ,[casdDtModified]
   ,[casnLevelNo]
   ,[cassCaseValueComments]
   ,[casbRefIn]
   ,[casbDelete]
   ,[casbIntaken]
   ,[casnOrgCaseTypeID]
   ,[CassCaption]
   ,[cassMdl]
   ,[office_id]
   ,[saga]
   ,[LIP]
   ,[casnSeriousInj]
   ,[casnCorpDefn]
   ,[casnWebImporter]
   ,[casnRecoveryClient]
   ,[cas]
   ,[ngage]
   ,[casnClientRecoveredDt]
   ,[CloseReason]
   ,[saga_db]
	)
	SELECT
		c.ID	  AS cassCaseNumber
	   ,''		  AS casbAppName
	   ,c.Name	  AS cassCaseName
	   ,NULL	  AS casnCaseTypeID
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = (
					SELECT
						StateName
					FROM #TempVariables
				)
		)		  
		AS casnState
	   ,GETDATE() AS casdStatusFromDt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)		  
		AS casnStatusValueID
	   ,GETDATE() AS casdsubstatusfromdt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)		  
		AS casnSubStatusValueID
	   ,GETDATE() AS casdOpeningDate
	   ,NULL	  AS casdClosingDate
	   ,NULL	  AS [casnCaseValueID]
	   ,NULL	  AS [casnCaseValueFrom]
	   ,NULL	  AS [casnCaseValueTo]
	   ,NULL	  AS [casnCurrentCourt]
	   ,NULL	  AS [casnCurrentJudge]
	   ,NULL	  AS [casnCurrentMagistrate]
	   ,0		  AS [casnCaptionID]
	   ,''		  AS cassCaptionText
	   ,1		  AS [casbMainCase]
	   ,0		  AS [casbCaseOut]
	   ,0		  AS [casbSubOut]
	   ,0		  AS [casbWCOut]
	   ,0		  AS [casbPartialOut]
	   ,0		  AS [casbPartialSubOut]
	   ,0		  AS [casbPartiallySettled]
	   ,1		  AS [casbInHouse]
	   ,NULL	  AS [casbAutoTimer]
	   ,NULL	  AS [casdExpResolutionDate]
	   ,NULL	  AS [casdIncidentDate]
	   ,0		  AS [casnTotalLiability]
	   ,0		  AS [cassSharingCodeID]
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = (
					SELECT
						StateName
					FROM #TempVariables
				)
		)		  
		AS [casnStateID]
	   ,NULL	  AS [casnLastModifiedBy]
	   ,NULL	  AS [casdLastModifiedDate]
	   ,368		  AS casnRecUserID
	   ,GETDATE() AS casdDtCreated
	   ,NULL	  AS casnModifyUserID
	   ,NULL	  AS casdDtModified
	   ,''		  AS casnLevelNo
	   ,''		  AS cassCaseValueComments
	   ,NULL	  AS casbRefIn
	   ,NULL	  AS casbDelete
	   ,NULL	  AS casbIntaken
	   ,(
			SELECT
				smct.cstnCaseTypeID
			FROM sma_MST_CaseType smct
			WHERE smct.cstsType = 'Highrise'
		)		  
		AS casnOrgCaseTypeID -- case type
	   ,''		  AS CassCaption
	   ,0		  AS cassMdl
	   ,(
			SELECT
				office_id
			FROM sma_MST_Offices
			WHERE office_name = (
					SELECT
						OfficeName
					FROM #TempVariables
				)
		)		  
		AS office_id
	   ,c.ID	  AS [saga]
	   ,NULL	  AS [LIP]
	   ,NULL	  AS [casnSeriousInj]
	   ,NULL	  AS [casnCorpDefn]
	   ,NULL	  AS [casnWebImporter]
	   ,NULL	  AS [casnRecoveryClient]
	   ,NULL	  AS [cas]
	   ,NULL	  AS [ngage]
	   ,NULL	  AS [casnClientRecoveredDt]
	   ,0		  AS CloseReason
	   ,'HR' AS [saga_db]
	FROM Baldante..contacts c
--FROM [JoelBieberNeedles].[dbo].[cases_Indexed] C
--LEFT JOIN [JoelBieberNeedles].[dbo].[user_case_data] U
--	on U.casenum = C.casenum
--JOIN caseTypeMixture mix
--	on mix.matcode = c.matcode
--LEFT JOIN sma_MST_CaseType CST
--	on CST.cststype = mix.[smartadvocate Case Type]
--	and VenderCaseType = (SELECT VenderCaseType FROM #TempVariables)
--ORDER BY C.casenum
GO

---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
---
