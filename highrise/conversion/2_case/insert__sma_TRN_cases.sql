/*-- =============================================
-- Author:      PWLAW\dsmith
-- Create date: 2025-09-12 14:46:59
-- Database:    SABaldantePracticeMasterConversion
-- Description: Insert cases that don't already exists (existing cases came from Tabs)
	- Highrise 'company' = tabs case number
-- ============================================= */

use Baldante_Consolidated
go

---
alter table [sma_TRN_Cases] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_TRN_Cases'
go
---


/* ------------------------------------------------------------------------------
Insert cases that don't exist
[contact].[company_name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
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
		(
		 select
			 [sttnStateID]
		 from [sma_MST_States]
		 where [sttsDescription] = (select StateName from conversion.office)
		)			   as casnstate,
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
		(
		 select
			 [sttnStateID]
		 from [sma_MST_States]
		 where [sttsDescription] = (select StateName from conversion.office)
		)			   as [casnstateid],
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
		 where smct.cstsType = 'Negligence'
		)			   as casnorgcasetypeid				-- actual case type
		,
		''			   as casscaption,
		0			   as cassmdl,
		(
		 select
			 office_id
		 from sma_MST_Offices
		 where office_name = (select OfficeName from conversion.office)
		)			   as office_id,
		null		   as [lip],
		null		   as [casnseriousinj],
		null		   as [casncorpdefn],
		null		   as [casnwebimporter],
		null		   as [casnrecoveryclient],
		null		   as [cas],
		null		   as [ngage],
		null		   as [casnclientrecovereddt],
		null		   as closereason,
		c.id		   as [saga],
		c.company_name as [source_id],
		'highrise'	   as [source_db],
		'contacts'	   as [source_ref]
	--select c.*
	from Baldante_Highrise..contacts c
	left join sma_TRN_Cases cas
		on cas.cassCaseNumber = c.company_name
	where
		cas.casnCaseID is null

---
alter table [sma_TRN_Cases] enable trigger all
go
---