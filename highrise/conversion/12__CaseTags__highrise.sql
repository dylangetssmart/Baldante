use Baldante_Consolidated
go


-- Set compatibility level for STRING_SPLIT, if not already set.
--declare @compatibility_level INT;
--select
--	@compatibility_level = compatibility_level
--from sys.databases
--where
--	name = 'SABaldantePracticeMasterConversion';

--if @compatibility_level < 130
--begin
--	alter database SABaldantePracticeMasterConversion set compatibility_level = 160;
--end

--go


/* ------------------------------------------------------------------------------
Insert [sma_MST_CaseTags]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_MST_CaseTags'
go

insert into sma_MST_CaseTags
	(
		[Name],
		[LimitTagGroups],
		[IsActive],
		[CreateUserID],
		[DtCreated],
		[ModifyUserID],
		[dDtModified],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		TRIM(ss.value) as [Name],
		0			   as LimitTagGroups,
		1			   as IsActive,
		368			   as CreateUserID,
		GETDATE()	   as DtCreated,
		368			   as ModifyUserID,
		GETDATE()	   as dDtModified,
		null		   as [source_id],
		'highrise'	   as [source_db],
		'contacts'	   as [source_ref]
	from Baldante_Highrise..contacts c
	cross apply STRING_SPLIT(c.tags, ',') ss
	where
		ISNULL(c.tags, '') <> ''
		and
		not exists (
		 select
			 1
		 from dbo.sma_MST_CaseTags t
		 where t.Name = TRIM(ss.value)
		);
go

/* ------------------------------------------------------------------------------
Insert [sma_TRN_CaseTags]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_CaseTags'
alter table sma_TRN_CaseTags disable trigger all;
go

insert into sma_TRN_CaseTags
	(
		[CaseID],
		[TagID],
		[CreateUserID],
		[DtCreated],
		[DeleteUserID],
		[DtDeleted],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		cas.casnCaseID,
		t.TagID,
		368		   as CreateUserID,
		GETDATE()  as DtCreated,
		null	   as DeleteUserID,
		null	   as DtDeleted,
		c.id	   as [source_id],
		'highrise' as [source_db],
		'contacts' as [source_ref]
	from Baldante_Highrise..contacts c
	join sma_TRN_Cases cas
		--on stc.cassCaseNumber = c.company_name
		on cas.source_id = c.id
			and [source_db] = 'highrise'
	cross apply STRING_SPLIT(c.tags, ',') ss
	join dbo.sma_MST_CaseTags t
		on t.Name = TRIM(ss.value)
	where
		ISNULL(c.tags, '') <> '';
go

alter table dbo.sma_TRN_CaseTags enable trigger all;
go
