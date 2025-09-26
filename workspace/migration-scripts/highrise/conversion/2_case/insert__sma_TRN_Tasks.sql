/* =============================================
-- Author:      PWLAW\dsmith
-- Create date: 2025-09-05 10:34:56
-- Database:    SABaldantePracticeMasterConversion
-- Description: Insert notes into cases
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
		iu.SAusrnUserID as [tskassigneeid],
		null			as [tskreminderdays],
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), t.body), '') + CHAR(13), '') +
		''				as [tskdescription],
		case
			when ISDATE(t.written_date) = 1 and
				t.written_date between '1/1/1900' and '6/6/2079'
				then t.written_date
			else null
		end				as [tskcreateddt],
		iu.SAusrnUserID as tskcreateduserid,
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
		'HR'		as [source_db],
		'tasks'			as [source_ref]
	--SELECT *
	from Baldante_Highrise..contacts c
	join Baldante_Highrise..tasks t
		on t.contact_id = c.id
	join SABaldantePracticeMasterConversion..sma_TRN_Cases stc
		on stc.cassCaseNumber = c.company_name
	join SABaldantePracticeMasterConversion..implementation_users iu
		on iu.Staff = t.author
			and iu.Syst = 'HR'
go


---
alter table [sma_TRN_TaskNew] enable trigger all
go
---