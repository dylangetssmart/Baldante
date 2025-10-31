/* =============================================
-- Author:      PWLAW\dsmith
-- Create date: 2025-09-05 10:34:56
-- Database:    SABaldantePracticeMasterConversion
-- Description: Insert emails into cases
-- ============================================= */

use SABaldantePracticeMasterConversion
go

---
alter table [sma_TRN_Emails] disable trigger all
go

exec AddBreadcrumbsToTable
	@tableName = N'sma_TRN_Emails'
go

---


insert into [dbo].[sma_TRN_Emails]
	(
		[emlnCaseID],
		[emlnFrom],
		[emlsTableName],
		[emlsColumnName],
		[emlnRecordID],
		[emlsSubject],
		[emlsSentReceived],
		[emlsContents],
		[emlbAcknowledged],
		[emldDate],
		[emlsFromEmailID],
		[emlsOutLookUserEmailID],	-- To
		[emlnTemplateID],
		[emlnPriority],
		[emlnRecUserID],
		[emldDtCreated],
		[emlnModifyUserID],
		[emldDtModified],
		[emlnLevelNo],
		[emlnReviewerContactId],
		[emlnReviewDate],
		[emlnDocumentAnalysisResultId],
		[emlnIsReviewed],
		[emlnToContactID],
		[emlnToContactCtgID],
		[emlnDocPriority],
		[emlnDocumentID],
		[emlnDeleteFlag],
		[emlsCCAddresses],
		[emlsBCCAddresses],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		stc.casnCaseID		   as [emlncaseid],
		iu.SAusrnUserID		   as [emlnfrom],
		''					   as [emlstablename],
		''					   as [emlscolumnname],
		0					   as [emlnrecordid],
		LEFT(e.[subject], 200) as [emlssubject],	--nvarchar 400
		'S'					   as [emlssentreceived],
		null				   as [emlssentreceived],
		CONVERT(TEXT, e.body)  as [emlscontents],
		null				   as [emlbacknowledged],
		case
			when ISDATE(e.written_date) = 1 and
				e.written_date between '1/1/1900' and '6/6/2079'
				then e.written_date
			else null
		end					   as [emlddate],
		iu.SAusrnUserID		   as [emlsfromemailid],	-- From Address (100)
		null				   as [emlsoutlookuseremailid],	-- To Address (4000)
		0					   as [emlntemplateid],
		0					   as [emlnpriority],
		iu.SAusrnUserID		   as [emlnrecuserid],
		case
			when ISDATE(e.written_date) = 1 and
				e.written_date between '1/1/1900' and '6/6/2079'
				then e.written_date
			else null
		end					   as [emlddtcreated],
		null				   as [emlnmodifyuserid],
		null				   as [emlddtmodified],
		null				   as [emlnlevelno],
		null				   as [emlnreviewercontactid],
		null				   as [emlnreviewdate],
		null				   as [emlndocumentanalysisresultid],
		null				   as [emlnisreviewed],
		null				   as [emlntocontactid],
		null				   as [emlntocontactctgid],
		3					   as [emlndocpriority],
		null				   as [emlndocumentid],
		null				   as [emlndeleteflag],
		null				   as [emlsccaddresses],
		null				   as [emlsbccaddresses],
		e.id				   as [saga],
		null				   as [source_id],
		'HR'				   as [source_db],
		'emails'			   as [source_ref]
	-- SELECT c.*
	from Baldante_Highrise..contacts c
	join Baldante_Highrise..emails e
		on e.contact_id = c.id
	join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
		on stc.cassCaseNumber = c.company_name
	join SABaldantePracticeMasterConversion..implementation_users iu
		on iu.Staff = e.author
			and iu.Syst = 'HR'
go


---
alter table sma_trn_emails enable trigger all
go
---