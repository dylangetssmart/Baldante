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

/* ------------------------------------------------------------------------------
Insert [sma_TRN_Cases] that don't yet exist
- [contact].[company_name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_Cases'
alter table [sma_TRN_Cases] disable trigger all
go

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
	select
		c.company_name as casscasenumber,
		''			   as casbappname,
		c.Name		   as casscasename,
		null		   as casncasetypeid,
		--(
		-- select
		--	 [sttnStateID]
		-- from [sma_MST_States]
		-- where [sttsDescription] = (select StateName from conversion.office)
		--)			   as casnstate,
		null		   as casnstate,
		GETDATE()	   as casdstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   as casnstatusvalueid,
		GETDATE()	   as casdsubstatusfromdt,
		(
		 select
			 cssnStatusID
		 from [sma_MST_CaseStatus]
		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   as casnsubstatusvalueid,
		'01-01-1922'   as casdopeningdate,
		null		   as casdclosingdate,
		null		   as [casncasevalueid],
		null		   as [casncasevaluefrom],
		null		   as [casncasevalueto],
		null		   as [casncurrentcourt],
		null		   as [casncurrentjudge],
		null		   as [casncurrentmagistrate],
		0			   as [casncaptionid],
		null		   as casscaptiontext,
		1			   as [casbmaincase],
		0			   as [casbcaseout],
		0			   as [casbsubout],
		0			   as [casbwcout],
		0			   as [casbpartialout],
		0			   as [casbpartialsubout],
		0			   as [casbpartiallysettled],
		1			   as [casbinhouse],
		null		   as [casbautotimer],
		null		   as [casdexpresolutiondate],
		null		   as [casdincidentdate],
		0			   as [casntotalliability],
		0			   as [casssharingcodeid],
		--(
		-- select
		--	 [sttnStateID]
		-- from [sma_MST_States]
		-- where [sttsDescription] = (select StateName from conversion.office)
		--)			   as [casnstateid],
		2			   as [casnstateid],
		null		   as [casnlastmodifiedby],
		null		   as [casdlastmodifieddate],
		368			   as [casnrecuserid],
		GETDATE()	   as casddtcreated,
		null		   as casnmodifyuserid,
		null		   as casddtmodified,
		''			   as casnlevelno,
		''			   as casscasevaluecomments,
		null		   as casbrefin,
		null		   as casbdelete,
		null		   as casbintaken,
		(
		 select
			 smct.cstnCaseTypeID
		 from sma_MST_CaseType smct
		 where smct.cstsType = 'Highrise'
		)			   as casnorgcasetypeid,
		''			   as casscaption,
		0			   as cassmdl,
		--(
		-- select
		--	 office_id
		-- from sma_MST_Offices	
		-- where office_name = (select OfficeName from conversion.office)
		--)			   as office_id,
		4			   as office_id,
		null		   as [lip],
		null		   as [casnseriousinj],
		null		   as [casncorpdefn],
		null		   as [casnwebimporter],
		null		   as [casnrecoveryclient],
		null		   as [cas],
		null		   as [ngage],
		null		   as [casnclientrecovereddt],
		null		   as closereason,
		null		   as [saga],
		c.id		   as [source_id],
		'highrise'	   as [source_db],
		'contacts'	   as [source_ref]
	--select c.*
	from Baldante_Highrise..contacts c
	left join sma_TRN_Cases cas
		on cas.cassCaseNumber = c.company_name
	where
		cas.casnCaseID is null
go

alter table [sma_TRN_Cases] enable trigger all
go