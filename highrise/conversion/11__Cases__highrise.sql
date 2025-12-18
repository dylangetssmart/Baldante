use Baldante_Consolidated
go

/* ------------------------------------------------------------------------------
Create Highrise case group
*/ ------------------------------------------------------------------------------
insert into [sma_MST_CaseGroup]
	(
		[cgpsCode],
		[cgpsDscrptn],
		[cgpnRecUserId],
		[cgpdDtCreated],
		[cgpnModifyUserID],
		[cgpdDtModified],
		[cgpnLevelNo],
		[IncidentTypeID],
		[LimitGroupStatuses]
	)
	select
		null	   as [cgpsCode],
		'Highrise' as [cgpsDscrptn],
		368		   as [cgpnRecUserId],
		GETDATE()  as [cgpdDtCreated],
		null	   as [cgpnModifyUserID],
		null	   as [cgpdDtModified],
		null	   as [cgpnLevelNo],
		(
		 select
			 IncidentTypeID
		 from [sma_MST_IncidentTypes]
		 where Description = 'General Negligence'
		)		   as [IncidentTypeID],
		null	   as [LimitGroupStatuses]
	where
		not exists (
		 select
			 1
		 from [sma_MST_CaseGroup] cg
		 where cg.cgpsDscrptn = 'Highrise'
		);
go

/* ------------------------------------------------------------------------------
Create Highrise case type
*/ ------------------------------------------------------------------------------
insert into [sma_MST_CaseType]
	(
		[cstsCode],
		[cstsType],
		[cstsSubType],
		[cstnWorkflowTemplateID],
		[cstnExpectedResolutionDays],
		[cstnRecUserID],
		[cstdDtCreated],
		[cstnModifyUserID],
		[cstdDtModified],
		[cstnLevelNo],
		[cstbTimeTracking],
		[cstnGroupID],
		[cstnGovtMunType],
		[cstnIsMassTort],
		[cstnStatusID],
		[cstnStatusTypeID],
		[cstbActive],
		[cstbUseIncident1],
		[cstsIncidentLabel1],
		[VenderCaseType]
	)
	select
		null				as [cstsCode],
		'Highrise'			as [cstsType],
		null				as [cstsSubType],
		null				as [cstnWorkflowTemplateID],
		720					as [cstnExpectedResolutionDays],
		368					as [cstnRecUserID],
		GETDATE()			as [cstdDtCreated],
		368					as [cstnModifyUserID],
		GETDATE()			as [cstdDtModified],
		0					as [cstnLevelNo],
		null				as [cstbTimeTracking],
		(
		 select
			 cgpnCaseGroupID
		 from sma_MST_caseGroup
		 where cgpsDscrptn = 'General Negligence'
		)					as [cstnGroupID],
		null				as [cstnGovtMunType],
		null				as [cstnIsMassTort],
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)					as [cstnStatusID],
		(
		 select
			 stpnStatusTypeID
		 from [sma_MST_CaseStatusType]
		 where stpsStatusType = 'Status'
		)					as [cstnStatusTypeID],
		1					as [cstbActive],
		1					as [cstbUseIncident1],
		'Incident 1'		as [cstsIncidentLabel1],
		'Baldante_Highrise' as [VenderCaseType]
	where
		not exists (
		 select
			 1
		 from [sma_MST_CaseType] CST
		 where CST.cstsType = 'Highrise'
		);
go



-- [sma_MST_CaseSubType]
insert into [sma_MST_CaseSubType]
	(
		[cstsCode],
		[cstnGroupID],
		[cstsDscrptn],
		[cstnRecUserId],
		[cstdDtCreated],
		[cstnModifyUserID],
		[cstdDtModified],
		[cstnLevelNo],
		[cstbDefualt],
		[saga],
		[cstnTypeCode]
	)
	select
		null		   as [cstscode],
		cstnCaseTypeID as [cstngroupid],
		'Unknown'	   as [cstsdscrptn],
		368			   as [cstnrecuserid],
		GETDATE()	   as [cstddtcreated],
		null		   as [cstnmodifyuserid],
		null		   as [cstddtmodified],
		null		   as [cstnlevelno],
		1			   as [cstbdefualt],
		null		   as [saga],
		(
		 select
			 stcnCodeId
		 from [sma_MST_CaseSubTypeCode]
		 where stcsDscrptn = 'Unknown'
		)			   as [cstntypecode]
	from [sma_MST_CaseType] cst
	where
		cst.cstsType = 'Highrise'
		and
		not exists (
		 select
			 1
		 from [sma_MST_CaseSubType] st
		 where st.cstnGroupID = (
			  select
				  ct.cstnCaseTypeID
			  from sma_MST_CaseType ct
			  where ct.cstsType = 'Highrise'
			 )
			 and st.cstsDscrptn = 'Unknown'
		);

--join [CaseTypeMap] map
--	on map.[SmartAdvocate Case Type] = cst.cststype
--left join [sma_MST_CaseSubType] sub
--	on sub.[cstngroupid] = cstnCaseTypeID
--		and sub.[cstsdscrptn] = [SmartAdvocate Case Sub Type]
--where
--	sub.cstnCaseSubTypeID is null
--	and
--	ISNULL([SmartAdvocate Case Sub Type], '') <> ''
go


/* ------------------------------------------------------------------------------
Create default SubRoleCodes
*/ ------------------------------------------------------------------------------
insert into [sma_MST_SubRoleCode]
	(
		srcsDscrptn,
		srcnRoleID
	)
	(
	-- Default Roles
	select
		'(P)-Default Role',
		4
	union all
	select
		'(D)-Default Role',
		5
	)

	except

	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode];
go


/* ------------------------------------------------------------------------------
Create Highrise SubRoles
*/ ------------------------------------------------------------------------------
insert into sma_MST_SubRole
	(
		sbrnRoleID,
		sbrsDscrptn,
		sbrnCaseTypeID,
		sbrnTypeCode
	)
	select
		src.srcnRoleID	  as sbrnRoleID,
		src.srcsDscrptn	  as sbrsDscrptn,
		ct.cstnCaseTypeID as sbrnCaseTypeID,
		src.srcnCodeID	  as sbrnTypeCode
	from sma_MST_SubRoleCode src
	cross join sma_MST_CaseType ct
	where
		ct.cstsType = 'Highrise'
		and
		src.srcsDscrptn in
		(
		'(P)-Default Role',
		'(D)-Default Role'
		)
		and
		not exists (
		 select
			 1
		 from sma_MST_SubRole sr
		 where sr.sbrnRoleID = src.srcnRoleID
			 and sr.sbrnCaseTypeID = ct.cstnCaseTypeID
		);
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Cases] that don't yet exist from [contacts]
- [contact].[company_name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_Cases'
alter table [sma_TRN_Cases] disable trigger all
go

;
with
	cte_cases
	as (
		 select
			 c.id,
			 c.company_name as case_number,
			 c.filename,
			 'contacts'		as ref
		 from Baldante_Highrise..contacts c
		 left join sma_TRN_Cases cas
			 on cas.cassCaseNumber = c.company_name
			 and cas.source_db = 'Tabs3'
		 where cas.casnCaseID is null

		 union all
		 select
			 com.id,
			 com.name  as case_number,
			 com.filename,
			 'company' as ref
		 from Baldante_Highrise..company com
		 left join sma_TRN_Cases cas
			 on cas.cassCaseNumber = com.name
			 and cas.source_db = 'Tabs3'
		 where cas.casnCaseID is null
		)

insert into [sma_TRN_Cases]
	(
		[cassCaseNumber],
		[casbAppName],
		[cassCaseName],
		[casnCaseTypeID],
		[casnState],
		[casdStatusFromDt],
		[casnStatusValueID],
		[casdsubstatusfromdt],
		[casnSubStatusValueID],
		[casdOpeningDate],
		[casdClosingDate],
		[casnCaseValueID],
		[casnCaseValueFrom],
		[casnCaseValueTo],
		[casnCurrentCourt],
		[casnCurrentJudge],
		[casnCurrentMagistrate],
		[casnCaptionID],
		[cassCaptionText],
		[casbMainCase],
		[casbCaseOut],
		[casbSubOut],
		[casbWCOut],
		[casbPartialOut],
		[casbPartialSubOut],
		[casbPartiallySettled],
		[casbInHouse],
		[casbAutoTimer],
		[casdExpResolutionDate],
		[casdIncidentDate],
		[casnTotalLiability],
		[cassSharingCodeID],
		[casnStateID],
		[casnLastModifiedBy],
		[casdLastModifiedDate],
		[casnRecUserID],
		[casdDtCreated],
		[casnModifyUserID],
		[casdDtModified],
		[casnLevelNo],
		[cassCaseValueComments],
		[casbRefIn],
		[casbDelete],
		[casbIntaken],
		[casnOrgCaseTypeID],
		[CassCaption],
		[cassMdl],
		[office_id],
		[LIP],
		[casnSeriousInj],
		[casnCorpDefn],
		[casnWebImporter],
		[casnRecoveryClient],
		[cas],
		[ngage],
		[casnClientRecoveredDt],
		[CloseReason],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		LEFT(c.case_number, 50) as casscasenumber,
		''						as casbappname,
		null					as casscasename,
		null					as casncasetypeid,
		--(
		-- select
		--	 [sttnStateID]
		-- from [sma_MST_States]
		-- where [sttsDescription] = (select StateName from conversion.office)
		--)			   as casnstate,
		2						as casnstate,
		GETDATE()				as casdstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						as casnstatusvalueid,
		GETDATE()				as casdsubstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						as casnsubstatusvalueid,
		'01-01-1922'			as casdopeningdate,
		null					as casdclosingdate,
		null					as [casncasevalueid],
		null					as [casncasevaluefrom],
		null					as [casncasevalueto],
		null					as [casncurrentcourt],
		null					as [casncurrentjudge],
		null					as [casncurrentmagistrate],
		0						as [casncaptionid],
		null					as casscaptiontext,
		1						as [casbmaincase],
		0						as [casbcaseout],
		0						as [casbsubout],
		0						as [casbwcout],
		0						as [casbpartialout],
		0						as [casbpartialsubout],
		0						as [casbpartiallysettled],
		1						as [casbinhouse],
		null					as [casbautotimer],
		null					as [casdexpresolutiondate],
		null					as [casdincidentdate],
		0						as [casntotalliability],
		0						as [casssharingcodeid],
		--(
		-- select
		--	 [sttnStateID]
		-- from [sma_MST_States]
		-- where [sttsDescription] = (select StateName from conversion.office)
		--)			   as [casnstateid],
		2						as [casnstateid],
		null					as [casnlastmodifiedby],
		null					as [casdlastmodifieddate],
		368						as [casnrecuserid],
		GETDATE()				as casddtcreated,
		null					as casnmodifyuserid,
		null					as casddtmodified,
		''						as casnlevelno,
		''						as casscasevaluecomments,
		null					as casbrefin,
		null					as casbdelete,
		null					as casbintaken,
		(
		 select
			 smct.cstnCaseTypeID
		 from sma_MST_CaseType smct
		 where smct.cstsType = 'Highrise'
		)						as casnorgcasetypeid,
		''						as casscaption,
		0						as cassmdl,
		--(
		-- select
		--	 office_id
		-- from sma_MST_Offices	
		-- where office_name = (select OfficeName from conversion.office)
		--)			   as office_id,
		4						as office_id,
		null					as [lip],
		null					as [casnseriousinj],
		null					as [casncorpdefn],
		null					as [casnwebimporter],
		null					as [casnrecoveryclient],
		null					as [cas],
		null					as [ngage],
		null					as [casnclientrecovereddt],
		null					as closereason,
		null					as [saga],
		c.id					as [source_id],
		'highrise'				as [source_db],
		c.ref					as [source_ref]	-- 'contacts' or 'company'
	--select distinct *
	from cte_cases c


--from Baldante_Highrise..contacts c
--left join sma_TRN_Cases cas
--	on cas.cassCaseNumber = c.company_name
--where
--	cas.casnCaseID is null
go

alter table [sma_TRN_Cases] enable trigger all
go


/* ------------------------------------------------------------------------------
Populate blank case numbers
*/ ------------------------------------------------------------------------------

select
	c.id,
	IDENTITY(int, 1, 1) as rowID
into #update_case_numbers
from Baldante_Highrise..contacts c
where
	ISNULL(c.company_name, '') = ''

select * from #update_case_numbers

update cas
set cassCaseNumber = RIGHT('00000' + CAST(rowID as VARCHAR(5)), 5)
from sma_trn_cases cas
join #update_case_numbers tmp
	on tmp.id = cas.source_id
	and cas.source_db = 'highrise'


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Cases] that don't yet exist from [company]
- [company].[name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
--alter table [sma_TRN_Cases] disable trigger all
--go

--insert into [sma_TRN_Cases]
--	(
--		[cassCaseNumber],
--		[casbAppName],
--		[cassCaseName],
--		[casnCaseTypeID],
--		[casnState],
--		[casdStatusFromDt],
--		[casnStatusValueID],
--		[casdsubstatusfromdt],
--		[casnSubStatusValueID],
--		[casdOpeningDate],
--		[casdClosingDate],
--		[casnCaseValueID],
--		[casnCaseValueFrom],
--		[casnCaseValueTo],
--		[casnCurrentCourt],
--		[casnCurrentJudge],
--		[casnCurrentMagistrate],
--		[casnCaptionID],
--		[cassCaptionText],
--		[casbMainCase],
--		[casbCaseOut],
--		[casbSubOut],
--		[casbWCOut],
--		[casbPartialOut],
--		[casbPartialSubOut],
--		[casbPartiallySettled],
--		[casbInHouse],
--		[casbAutoTimer],
--		[casdExpResolutionDate],
--		[casdIncidentDate],
--		[casnTotalLiability],
--		[cassSharingCodeID],
--		[casnStateID],
--		[casnLastModifiedBy],
--		[casdLastModifiedDate],
--		[casnRecUserID],
--		[casdDtCreated],
--		[casnModifyUserID],
--		[casdDtModified],
--		[casnLevelNo],
--		[cassCaseValueComments],
--		[casbRefIn],
--		[casbDelete],
--		[casbIntaken],
--		[casnOrgCaseTypeID],
--		[CassCaption],
--		[cassMdl],
--		[office_id],
--		[LIP],
--		[casnSeriousInj],
--		[casnCorpDefn],
--		[casnWebImporter],
--		[casnRecoveryClient],
--		[cas],
--		[ngage],
--		[casnClientRecoveredDt],
--		[CloseReason],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select
--		com.name	 as casscasenumber,
--		''			 as casbappname,
--		com.Name	 as casscasename,
--		null		 as casncasetypeid,
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as casnstate,
--		null		 as casnstate,
--		GETDATE()	 as casdstatusfromdt,
--		(
--		 select
--			 cssnStatusID
--		 from [sma_MST_CaseStatus]
--		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)			 as casnstatusvalueid,
--		GETDATE()	 as casdsubstatusfromdt,
--		(
--		 select
--			 cssnStatusID
--		 from [sma_MST_CaseStatus]
--		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)			 as casnsubstatusvalueid,
--		'01-01-1922' as casdopeningdate,
--		null		 as casdclosingdate,
--		null		 as [casncasevalueid],
--		null		 as [casncasevaluefrom],
--		null		 as [casncasevalueto],
--		null		 as [casncurrentcourt],
--		null		 as [casncurrentjudge],
--		null		 as [casncurrentmagistrate],
--		0			 as [casncaptionid],
--		null		 as casscaptiontext,
--		1			 as [casbmaincase],
--		0			 as [casbcaseout],
--		0			 as [casbsubout],
--		0			 as [casbwcout],
--		0			 as [casbpartialout],
--		0			 as [casbpartialsubout],
--		0			 as [casbpartiallysettled],
--		1			 as [casbinhouse],
--		null		 as [casbautotimer],
--		null		 as [casdexpresolutiondate],
--		null		 as [casdincidentdate],
--		0			 as [casntotalliability],
--		0			 as [casssharingcodeid],
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as [casnstateid],
--		2			 as [casnstateid],
--		null		 as [casnlastmodifiedby],
--		null		 as [casdlastmodifieddate],
--		368			 as [casnrecuserid],
--		GETDATE()	 as casddtcreated,
--		null		 as casnmodifyuserid,
--		null		 as casddtmodified,
--		''			 as casnlevelno,
--		''			 as casscasevaluecomments,
--		null		 as casbrefin,
--		null		 as casbdelete,
--		null		 as casbintaken,
--		(
--		 select
--			 smct.cstnCaseTypeID
--		 from sma_MST_CaseType smct
--		 where smct.cstsType = 'Highrise'
--		)			 as casnorgcasetypeid,
--		''			 as casscaption,
--		0			 as cassmdl,
--		--(
--		-- select
--		--	 office_id
--		-- from sma_MST_Offices	
--		-- where office_name = (select OfficeName from conversion.office)
--		--)			   as office_id,
--		4			 as office_id,
--		null		 as [lip],
--		null		 as [casnseriousinj],
--		null		 as [casncorpdefn],
--		null		 as [casnwebimporter],
--		null		 as [casnrecoveryclient],
--		null		 as [cas],
--		null		 as [ngage],
--		null		 as [casnclientrecovereddt],
--		null		 as closereason,
--		null		 as [saga],
--		com.id		 as [source_id],
--		'highrise'	 as [source_db],
--		'company'	 as [source_ref]
--	--select *
--	from Baldante_Highrise..company com
--	left join sma_TRN_Cases cas
--		on cas.cassCaseNumber = com.name
--	where
--		cas.casnCaseID is null
--go

--alter table [sma_TRN_Cases] enable trigger all
--go