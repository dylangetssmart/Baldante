use Baldante_Consolidated
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Emails] into highrise cases

emaisl

*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_Notes'
alter table [sma_TRN_Notes] disable trigger all
go

;
with
	cte_emails
	as (
		 /* ------------------------------------------------------------------
	  	   Emails linked directly to CONTACT
	  	------------------------------------------------------------------ */
		 select
			 e.id as email_id,
			 e.subject,
			 e.body,
			 e.written_date,
			 e.author,
			 cas.casnCaseID
		 --cts.id as contact_id
		 from Baldante_Highrise..emails e
		 join Baldante_Highrise..contacts cts
			 on e.contact_id = cts.id
		 join sma_TRN_Cases cas
			 on cas.source_id = cts.id
			 and cas.source_db = 'highrise'
		 --			 and cas.source_ref = 'contacts'

		 union all

		 /* ------------------------------------------------------------------
	  	   Emails linked to COMPANY -> CONTACT -> CASE
	  	------------------------------------------------------------------ */
		 select
			 e.id as email_id,
			 e.subject,
			 e.body,
			 e.written_date,
			 e.author,
			 cas.casnCaseID
		 --cts.id as contact_id
		 from Baldante_Highrise..emails e
		 join Baldante_Highrise..company com
			 on e.company_id = com.id
		 --join Baldante_Highrise..contacts cts
		 -- on cts.company_id = com.id
		 join sma_TRN_Cases cas
			 on cas.source_id = com.id
			 and cas.source_db = 'highrise'
		--			 and cas.source_ref = 'contacts'
		)

insert into [dbo].[sma_TRN_Notes]
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
		c.casnCaseID		   as [emlncaseid],
		iu.SAusrnUserID		   as [emlnfrom],
		''					   as [emlstablename],
		''					   as [emlscolumnname],
		0					   as [emlnrecordid],
		LEFT(c.[subject], 200) as [emlssubject],	--nvarchar 400
		'S'					   as [emlssentreceived],
		null				   as [emlssentreceived],
		CONVERT(TEXT, c.body)  as [emlscontents],
		null				   as [emlbacknowledged],
		case
			when ISDATE(c.written_date) = 1 and
				c.written_date between '1/1/1900' and '6/6/2079' then e.written_date
			else null
		end					   as [emlddate],
		iu.SAusrnUserID		   as [emlsfromemailid],	-- From Address (100)
		null				   as [emlsoutlookuseremailid],	-- To Address (4000)
		0					   as [emlntemplateid],
		0					   as [emlnpriority],
		iu.SAusrnUserID		   as [emlnrecuserid],
		case
			when ISDATE(c.written_date) = 1 and
				c.written_date between '1/1/1900' and '6/6/2079' then e.written_date
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
		null				   as [saga],
		--e.id				   as [source_id],	-- method 2
		c.email_id			   as [source_id],
		'highrise'			   as [source_db],
		'emails'			   as [source_ref]
	--select *
	-- method 1 - ctec
	from cte_emails c
	join Baldante_SATenantConsolidated_20251027..implementation_users iu
		on iu.Staff = c.author
			and iu.Syst = 'HR';

---- method 2 - outer joins
---- jump to case:
---- [emails] -> [company] -> [contacts] -> [sma_TRN_Cases]
--from Baldante_Highrise..emails e
--join Baldante_Highrise..company com
--	on e.company_id = com.id
--join Baldante_Highrise..contacts cts
--	on cts.company_id = com.id
--join sma_TRN_Cases cas
--	on cas.[source_id] = cts.id
--		and cas.[source_db] = 'highrise'
--		and cas.[source_ref] = 'contacts'
---- implementation users from tanya
--join Baldante_SATenantConsolidated_20251027..implementation_users iu
--	on iu.Staff = e.author
--		and iu.Syst = 'HR'



--SELECT * FROM Baldante_Highrise..emails where contact_id = 342986010
--SELECT * FROM Baldante_Highrise..contacts where id = 342986010





--left join Baldante_Highrise..contacts c
--	on e.contact_id = c.id
--left join Baldante_Highrise..company com
--	on e.company_id = com.id
--join Baldante_SATenantConsolidated_20251027..implementation_users iu
--	on iu.Staff = e.author
--		and iu.Syst = 'HR'

--from Baldante_Highrise..contacts c
--join Baldante_Highrise..emails e
--	on e.contact_id = c.id
--join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
--	on stc.cassCaseNumber = c.company_name
--join SABaldantePracticeMasterConversion..implementation_users iu
--	on iu.Staff = e.author
--		and iu.Syst = 'HR'
go


---
alter table sma_trn_emails enable trigger all
go
---