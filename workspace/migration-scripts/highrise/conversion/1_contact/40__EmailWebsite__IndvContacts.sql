/*---
description: Individual Contact Email Addresses

steps: >
  - Disable triggers on [sma_MST_EmailWebsite]
  - Add breadcrumb columns to [sma_MST_EmailWebsite]
  - Insert Email Address from [names].[email]
  - Insert Work Email from [names].[email_work]
  - Insert Other Email from [names].[other_email]
  - Insert Website from [names].[website]
  - Insert Email for staff users from [staff].[email]
  - Enable triggers on [sma_MST_EmailWebsite]

dependencies:
  - \conversion\1_contact\01__IndvContacts__names.sql

notes: >
  - [saga] = 
  - [source_id] = null
  - [source_db] = 'needles'
  - [source_ref] = 'names'
  
---*/

use [Baldante_SA_Highrise]
go

---
alter table [sma_MST_EmailWebsite] disable trigger all
go

exec AddBreadcrumbsToTable
	'sma_MST_EmailWebsite';
---


/* ------------------------------------------------------------------------------
Email Address
*/ ------------------------------------------------------------------------------
insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		e.email_address	 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		1				 as saga, -- indicate email
		null			 as [source_id],
		'needles'		 as [source_db],
		'names.email'	 as [source_ref]
	from Baldante_Highrise..email_address e
	join [sma_MST_IndvContacts] c
		on c.saga = e.contact_id
	where
		ISNULL(e.email_address, '') <> ''

--/* ------------------------------------------------------------------------------
--Work Email
--*/ ------------------------------------------------------------------------------
--insert into [sma_MST_EmailWebsite]
--	(
--		[cewnContactCtgID],
--		[cewnContactID],
--		[cewsEmailWebsiteFlag],
--		[cewsEmailWebSite],
--		[cewbDefault],
--		[cewnRecUserID],
--		[cewdDtCreated],
--		[cewnModifyUserID],
--		[cewdDtModified],
--		[cewnLevelNo],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	) select
--		c.cinnContactCtg   as cewncontactctgid,
--		c.cinnContactID	   as cewncontactid,
--		'E'				   as cewsemailwebsiteflag,
--		n.email_work	   as cewsemailwebsite,
--		null			   as cewbdefault,
--		368				   as cewnrecuserid,
--		GETDATE()		   as cewddtcreated,
--		368				   as cewnmodifyuserid,
--		GETDATE()		   as cewddtmodified,
--		null			   as cewnlevelno,
--		2				   as saga, -- indicate email_work
--		null			   as [source_id],
--		'needles'		   as [source_db],
--		'names.email_work' as [source_ref]
--	from [Needles].[dbo].[names] n
--	join [sma_MST_IndvContacts] c
--		on c.saga = n.names_id
--	where
--		ISNULL(email_work, '') <> ''

--/* ------------------------------------------------------------------------------
--Other Email
--*/ ------------------------------------------------------------------------------
--insert into [sma_MST_EmailWebsite]
--	(
--		[cewnContactCtgID],
--		[cewnContactID],
--		[cewsEmailWebsiteFlag],
--		[cewsEmailWebSite],
--		[cewbDefault],
--		[cewnRecUserID],
--		[cewdDtCreated],
--		[cewnModifyUserID],
--		[cewdDtModified],
--		[cewnLevelNo],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	) select
--		c.cinnContactCtg	as cewncontactctgid,
--		c.cinnContactID		as cewncontactid,
--		'E'					as cewsemailwebsiteflag,
--		n.other_email		as cewsemailwebsite,
--		null				as cewbdefault,
--		368					as cewnrecuserid,
--		GETDATE()			as cewddtcreated,
--		368					as cewnmodifyuserid,
--		GETDATE()			as cewddtmodified,
--		null				as cewnlevelno,
--		3					as saga, -- indicate other_email
--		null				as [source_id],
--		'needles'			as [source_db],
--		'names.other_email' as [source_ref]
--	from [Needles].[dbo].[names] n
--	join [sma_MST_IndvContacts] c
--		on c.saga = n.names_id
--	where
--		ISNULL(other_email, '') <> ''

--/* ------------------------------------------------------------------------------
--Website
--*/ ------------------------------------------------------------------------------
--insert into [sma_MST_EmailWebsite]
--	(
--		[cewnContactCtgID],
--		[cewnContactID],
--		[cewsEmailWebsiteFlag],
--		[cewsEmailWebSite],
--		[cewbDefault],
--		[cewnRecUserID],
--		[cewdDtCreated],
--		[cewnModifyUserID],
--		[cewdDtModified],
--		[cewnLevelNo],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	) select
--		c.cinnContactCtg as cewncontactctgid,
--		c.cinnContactID	 as cewncontactid,
--		'W'				 as cewsemailwebsiteflag,
--		n.website		 as cewsemailwebsite,
--		null			 as cewbdefault,
--		368				 as cewnrecuserid,
--		GETDATE()		 as cewddtcreated,
--		368				 as cewnmodifyuserid,
--		GETDATE()		 as cewddtmodified,
--		null			 as cewnlevelno,
--		4				 as saga, -- indicate website
--		null			 as [source_id],
--		'needles'		 as [source_db],
--		'names.website'	 as [source_ref]
--	from [Needles].[dbo].[names] n
--	join [sma_MST_IndvContacts] c
--		on c.saga = n.names_id
--	where
--		ISNULL(website, '') <> ''

-----------------------------------------
---- Insert [sma_MST_EmailWebsite] from [staff]
-----------------------------------------
--insert into [sma_MST_EmailWebsite]
--	(
--		[cewnContactCtgID],
--		[cewnContactID],
--		[cewsEmailWebsiteFlag],
--		[cewsEmailWebSite],
--		[cewbDefault],
--		[cewnRecUserID],
--		[cewdDtCreated],
--		[cewnModifyUserID],
--		[cewdDtModified],
--		[cewnLevelNo],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	) select
--		ic.cinnContactCtg as cewncontactctgid,
--		ic.cinnContactID  as cewncontactid,
--		'E'				  as cewsemailwebsiteflag,
--		s.email			  as cewsemailwebsite,
--		null			  as cewbdefault,
--		368				  as cewnrecuserid,
--		GETDATE()		  as cewddtcreated,
--		368				  as cewnmodifyuserid,
--		GETDATE()		  as cewddtmodified,
--		null,
--		1				  as saga, -- indicate email
--		null			  as [source_id],
--		'needles'		  as [source_db],
--		'staff.email'	  as [source_ref]
--	from [Needles].[dbo].[staff] s
--	join [sma_MST_IndvContacts] ic
--		on ic.source_id = s.staff_code
--			and ic.source_ref = 'staff'
--	--on c.cinsGrade = s.staff_code
--	where
--		ISNULL(email, '') <> ''