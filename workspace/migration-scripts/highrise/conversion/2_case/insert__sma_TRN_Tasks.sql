/* =============================================
-- Author:      PWLAW\dsmith
-- Create date: 2025-09-05 10:34:56
-- Database:    SABaldantePracticeMasterConversion
-- Description: 

For contacts with company_id <> null, find the Tabs case (case number = company_name)

-- ============================================= */

use SABaldantePracticeMasterConversion
go

---
alter table [sma_TRN_TaskNew] disable trigger all
go

exec AddBreadcrumbsToTable
	@tableName = N'sma_TRN_TaskNew'

go

---


--select
--	stc.casnCaseID, stc.cassCaseNumber, c.*
--from Baldante_Highrise..contacts c
--join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
--	on stc.cassCaseNumber = c.company_name


-- [4.3] Create tasks from [Task]
insert into [sma_TRN_TaskNew]
	(
		[tskCaseID],
		[tskDueDate],
		[tskStartDate],
		[tskCompletedDt],
		[tskRequestorID],
		[tskAssigneeId],
		[tskReminderDays],
		[tskDescription],
		[tskCreatedDt],
		[tskCreatedUserID],
		[tskModifiedDt],
		[tskModifyUserID],
		[tskMasterID],
		[tskCtgID],
		[tskSummary],
		[tskPriority],
		[tskCompleted],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		stc.casnCaseID  as [tskcaseid],
		null			as [tskduedate],
		null			as [tskstartdate],
		null			as [tskcompleteddt],
		null			as [tskrequestorid],
		null			as [tskassigneeid],
		-- t.author		as [tskassigneeid],
		null			as [tskreminderdays],
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), t.body), '') + CHAR(13), '') +
		''				as [tskdescription],
		GETDATE()		as [tskcreateddt],
		368				as tskcreateduserid,
		--t.author		as tskcreateduserid,
		null			as [tskmodifieddt],
		null			as [tskmodifyuserid],
		(
		 select
			 tskmasterid
		 from sma_mst_Task_Template
		 where tskMasterDetails = 'Custom Task'
		)				as [tskmasterid],
		(
		 select
			 tskctgid
		 from sma_MST_TaskCategory
		 where tskCtgDescription = 'Other'
		)				as [tskctgid],
		'Highrise Task' as [tsksummary],  --task subject--
		3				as [tskpriority], -- Normal priority
		0				as [tskcompleted], -- Not Started
		t.id			as [saga],
		null			as [source_id],
		'highrise'		as [source_db],
		'tasks'			as [source_ref]
	--SELECT *
	from Baldante_Highrise..contacts c
	join Baldante_Highrise..tasks t
		on t.contact_id = c.id
	join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
		on stc.cassCaseNumber = c.company_name
go


---
alter table [sma_TRN_TaskNew] enable trigger all
go
---