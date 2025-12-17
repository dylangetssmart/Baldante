/*
Add details to Tabs3 cases
[contact].[company_name] -> [sma_TRN_Cases].[cassCaseNumber]
-- tasks
-- emails
-- notes
-- tags
*/

/* ------------------------------------------------------------------------------
Insert Notes
*/ ------------------------------------------------------------------------------
--INSERT INTO [sma_MST_NoteTypes]
--	(
--	nttsDscrptn
--   ,nttsNoteText
--	)
--	SELECT DISTINCT
--		topic AS nttsDscrptn
--	   ,topic AS nttsNoteText
--	FROM TestNeedles.[dbo].[case_notes_Indexed]
--	EXCEPT
--	SELECT
--		nttsDscrptn
--	   ,nttsNoteText
--	FROM [sma_MST_NoteTypes]
--GO

exec AddBreadcrumbsToTable 'sma_TRN_Notes'
alter table [sma_TRN_Notes] disable trigger all
go

;
with
	cte
	as (

		 select
			 n.id,
			 n.contact_id,
			 n.company_id,
			 n.author,
			 n.written_date,
			 n.about,
			 n.body,
			 c.id			as contact_id,
			 c.company_id   as company_id,
			 c.company_name as company_name,
			 cas.casnCaseID,
			 cas.cassCaseNumber
		 --n.*, c.id, c.company_id, c.company_name, cas.casnCaseID, cas.cassCaseNumber
		 from Baldante_Highrise..notes n
		 join Baldante_Highrise..contacts c
			 on n.contact_id = c.id
		 join sma_TRN_cases cas
			 on cas.cassCaseNumber = c.company_name

		 union all

		 select
			 n.id,
			 n.contact_id,
			 n.company_id,
			 n.author,
			 n.written_date,
			 n.about,
			 n.body,
			 null	  as contact_id,
			 com.id	  as company_id,
			 com.name as company_name,
			 cas.casnCaseID,
			 cas.cassCaseNumber
		 --n.*, c.id, c.company_id, c.company_name, cas.casnCaseID, cas.cassCaseNumber
		 from Baldante_Highrise..notes n
		 join Baldante_Highrise..company com
			 on n.company_id = com.id
		 join sma_TRN_cases cas
			 on cas.cassCaseNumber = com.name

		)
insert into [sma_TRN_Notes]
	(
		[notnCaseID],
		[notnNoteTypeID],
		[notmDescription],
		[notmPlainText],
		[notnContactCtgID],
		[notnContactId],
		[notsPriority],
		[notnFormID],
		[notnRecUserID],
		[notdDtCreated],
		[notnModifyUserID],
		[notdDtModified],
		[notnLevelNo],
		[notdDtInserted],
		[WorkPlanItemId],
		[notnSubject],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		cte.casnCaseID  as [notnCaseID],
		(
		 select
			 MIN(nttnNoteTypeID)
		 from [sma_MST_NoteTypes]
		 where nttsDscrptn = 'General Comments'
		)				as [notnNoteTypeID],
		CONCAT(
		COALESCE('Author: ' + cte.author, '') + CHAR(10) + CHAR(13),
		COALESCE('About: ' + cte.about, '') + CHAR(10) + CHAR(13),
		n.body)			
		as [notmDescription],
		CONCAT(
		COALESCE('Author: ' + cte.author, '') + '<br>',
		COALESCE('About: ' + cte.about, '') + '<br>',
		cte.body)		as [notmPlainText],
		0				as [notnContactCtgID],
		null			as [notnContactId],
		null			as [notsPriority],
		null			as [notnFormID],
		iu.SAusrnUserID as [notnRecUserID],
		case
			when n.written_date between '1900-01-01' and '2079-06-06' then n.written_date
			else GETDATE()
		end				as notdDtCreated,
		null			as [notnModifyUserID],
		null			as notdDtModified,
		null			as [notnLevelNo],
		null			as [notdDtInserted],
		null			as [WorkPlanItemId],
		null			as [notnSubject],
		cte.id			as [saga],
		null			as [source_id],
		'highrise'		as [source_db],
		'notes'			as [source_ref]
	-- SELECT *
	from cte
--from Baldante_Highrise..notes n
--join Baldante_Highrise..contacts c
--	on c.id = n.contact_id
--join Baldante_Highrise..company com
--	on c.company_id = com.id

--join sma_TRN_Cases cas
--	on cas.cassCaseNumber = c.company_name

--join SABaldantePracticeMasterConversion..implementation_users iu
--	on iu.Staff = n.author
--		and iu.Syst = 'HR'
go


---
alter table [sma_TRN_Notes] enable trigger all
go
---