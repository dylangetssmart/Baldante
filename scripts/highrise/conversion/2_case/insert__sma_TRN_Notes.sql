-- =============================================
-- Author:      PWLAW\dsmith
-- Create date: 2025-09-12 14:16:30
-- Database:    SABaldantePracticeMasterConversion
-- Description: insert notes into cases
-- =============================================

use SABaldantePracticeMasterConversion
go

---
alter table [sma_TRN_Notes] disable trigger all
go

exec AddBreadcrumbsToTable
	@tableName = N'sma_TRN_Notes'
go

---

----(0)----
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

---
alter table [sma_TRN_Notes] disable trigger all
go

---

----(1)----
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
		casnCaseID		as [notnCaseID],
		(
		 select
			 MIN(nttnNoteTypeID)
		 from [sma_MST_NoteTypes]
		 where nttsDscrptn = 'General Comments'
		)				as [notnNoteTypeID],
		CONCAT(
		COALESCE('Author: ' + n.author, '') + CHAR(10) + CHAR(13),
		COALESCE('About: ' + n.about, '') + CHAR(10) + CHAR(13),
		n.body)			
		as [notmDescription],
		CONCAT(
		COALESCE('Author: ' + n.author, '') + '<br>',
		COALESCE('About: ' + n.about, '') + '<br>',
		n.body)			as [notmPlainText],
		0				as [notnContactCtgID],
		null			as [notnContactId],
		null			as [notsPriority],
		null			as [notnFormID],
		iu.SAusrnUserID as [notnRecUserID],
		case
			when n.written_date between '1900-01-01' and '2079-06-06'
				then n.written_date
			else GETDATE()
		end				as notdDtCreated,
		null			as [notnModifyUserID],
		null			as notdDtModified,
		null			as [notnLevelNo],
		null			as [notdDtInserted],
		null			as [WorkPlanItemId],
		null			as [notnSubject],
		n.id			[saga],
		null			as [source_id],
		'HR'			as [source_db],
		'emails'		as [source_ref]
	-- SELECT *
	from Baldante_Highrise..contacts c
	join Baldante_Highrise..notes n
		on n.contact_id = c.id
	join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
		on stc.cassCaseNumber = c.company_name
	join SABaldantePracticeMasterConversion..implementation_users iu
		on iu.Staff = n.author
			and iu.Syst = 'HR'
go


---
alter table [sma_TRN_Notes] enable trigger all
go
---