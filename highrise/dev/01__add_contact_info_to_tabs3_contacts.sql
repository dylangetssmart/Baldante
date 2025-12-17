/*
this script adds contact information to Indvidual Contacts matched by name
*/

use Baldante_Consolidated
go


--select
--	*
--from Baldante_Highrise..contacts c
--join SABaldantePracticeMasterConversion..IndvOrgContacts_Indexed ioci
--	on c.name = ioci.Name



/* ------------------------------------------------------------------------------
   Section 1: Insert Home Addresses from Highrise Contacts
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_Address';
alter table [sma_MST_Address] disable trigger all
go

insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		ioci.CTG		as addncontactctgid,
		ioci.CID		as addncontactid,
		t.addnAddTypeID as addnaddresstypeid,
		t.addsDscrptn   as addsaddresstype,
		t.addsCode		as addsaddtypecode,
		a.[address]		as addsaddress1,
		null			as addsaddress2,
		null			as addsaddress3,
		null			as addsstatecode,
		null			as addscity,
		null			as addnzipid,
		null			as addszip,
		null			as addscounty,
		null			as addscountry,
		null			as addbisresidence,
		1				as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		null			as [addscomments],
		null,
		null,
		368				as addnrecuserid,
		GETDATE()		as addddtcreated,
		368				as addnmodifyuserid,
		GETDATE()		as addddtmodified,
		null,
		null,
		null,
		null,
		a.contact_id	as saga,
		null			as source_id,
		'highrise'		as source_db,
		'address'		as source_ref
	--select c.id,c.name,ioci.*,a.*
	from Baldante_Highrise..address a
	join Baldante_Highrise..contacts c
		on c.id = a.contact_id
	join IndvOrgContacts_Indexed ioci
		on c.name = ioci.Name
			and ioci.CTG = 1
			and ioci.source_db = 'Tabs3'
	join [sma_MST_AddressTypes] as t
		on t.addnContactCategoryID = ioci.CTG
			and t.addsCode = 'HM';
go

alter table [sma_MST_Address] enable trigger all
go

/* ------------------------------------------------------------------------------
   Section 2: Insert Home Phone Numbers from Highrise Contacts
   The subquery to get the phone type ID has been replaced with a join
   for better performance and readability.
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_ContactNumbers';
alter table [sma_MST_ContactNumbers] disable trigger all
go

insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseno],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.cinnContactCtg				as cnnncontactctgid,
		c.cinnContactID					as cnnncontactid,
		t.ctynContactNoTypeID			as cnnnphonetypeid,
		dbo.FormatPhone(p.phone_number) as cnnscontactnumber,
		null							as cnnsextension,
		1								as cnnbprimary,
		null							as cnnbvisible,
		a.addnAddressID					as cnnnaddressid,
		'Home Phone'					as cnnslabelcaption,
		368								as cnnnrecuserid,
		GETDATE()						as cnnddtcreated,
		368								as cnnnmodifyuserid,
		GETDATE()						as cnnddtmodified,
		null							as cnnnlevelno,
		null							as caseno,
		c.saga							as saga,
		p.id							as source_id,
		'highrise'						as source_db,
		'phone'							as source_ref
	--select *
	from Baldante_Highrise..phone as p
	join Baldante_Highrise..contacts c
		on c.id = p.contact_id
	join IndvOrgContacts_Indexed ioci
		on c.name = ioci.Name
			and ioci.CTG = 1
			and ioci.source_db = 'Tabs3'
	--join [sma_MST_IndvContacts] as c
	--	on c.saga = p.contact_id
	join [sma_MST_Address] as a
		on a.addnContactID = c.cinnContactID
			and a.addnContactCtgID = c.cinnContactCtg
			and a.addbPrimary = 1
	join sma_MST_ContactNoType as t
		on t.ctysDscrptn = 'Home Primary Phone'
			and t.ctynContactCategoryID = 1
	where
		ISNULL(p.phone_number, '') <> '';
go

alter table [sma_MST_ContactNumbers] enable trigger all;
go

/* ------------------------------------------------------------------------------
   Section 3: Insert Email Addresses from Highrise Contacts
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_EmailWebsite';
alter table [sma_MST_EmailWebsite] disable trigger all
go

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
		e.contact_id	 as saga,
		e.id			 as source_id,
		'highrise'		 as source_db,
		'email_address'	 as source_ref
	--select *
	from Baldante_Highrise..email_address as e
	join Baldante_Highrise..contacts c
		on c.id = e.contact_id
	join IndvOrgContacts_Indexed ioci
		on c.name = ioci.Name
			and ioci.CTG = 1
			and ioci.source_db = 'Tabs3'
	--join [sma_MST_IndvContacts] as c
	--	on c.saga = e.contact_id
	where
		ISNULL(e.email_address, '') <> '';
go

alter table [sma_MST_EmailWebsite] enable trigger all;
go

--/* ------------------------------------------------------------------------------
--Home from IndvContacts
--*/ ------------------------------------------------------------------------------
--insert into [sma_MST_Address]
--	(
--		[addnContactCtgID],
--		[addnContactID],
--		[addnAddressTypeID],
--		[addsAddressType],
--		[addsAddTypeCode],
--		[addsAddress1],
--		[addsAddress2],
--		[addsAddress3],
--		[addsStateCode],
--		[addsCity],
--		[addnZipID],
--		[addsZip],
--		[addsCounty],
--		[addsCountry],
--		[addbIsResidence],
--		[addbPrimary],
--		[adddFromDate],
--		[adddToDate],
--		[addnCompanyID],
--		[addsDepartment],
--		[addsTitle],
--		[addnContactPersonID],
--		[addsComments],
--		[addbIsCurrent],
--		[addbIsMailing],
--		[addnRecUserID],
--		[adddDtCreated],
--		[addnModifyUserID],
--		[adddDtModified],
--		[addnLevelNo],
--		[caseno],
--		[addbDeleted],
--		[addsZipExtn],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select
--		i.cinnContactCtg as addncontactctgid,
--		i.cinnContactID	 as addncontactid,
--		t.addnAddTypeID	 as addnaddresstypeid,
--		t.addsDscrptn	 as addsaddresstype,
--		t.addsCode		 as addsaddtypecode,
--		a.[address]		 as addsaddress1,
--		a.[address_2]	 as addsaddress2,
--		null			 as addsaddress3,
--		a.[state]		 as addsstatecode,
--		a.[city]		 as addscity,
--		null			 as addnzipid,
--		a.[zipcode]		 as addszip,
--		a.[county]		 as addscounty,
--		a.[country]		 as addscountry,
--		null			 as addbisresidence,
--		1		 as addbprimary,
--		null,
--		null,
--		null,
--		null,
--		null,
--		null,
--		null			 as [addscomments],
--		null,
--		null,
--		368				 as addnrecuserid,
--		GETDATE()		 as addddtcreated,
--		368				 as addnmodifyuserid,
--		GETDATE()		 as addddtmodified,
--		null,
--		null,
--		null,
--		null,
--		null			 as [saga],
--		null			 as [source_id],
--		'highrise'		 as [source_db],
--		'address'		 as [source_ref]
--	from [Baldante_Highrise]..address a
--	join [sma_MST_Indvcontacts] i
--		on i.saga = a.contact_id
--	join [sma_MST_AddressTypes] t
--		on t.addnContactCategoryID = i.cinnContactCtg
--			and t.addsCode = 'HM'

--insert into [sma_MST_ContactNumbers]
--	(
--		[cnnnContactCtgID],
--		[cnnnContactID],
--		[cnnnPhoneTypeID],
--		[cnnsContactNumber],
--		[cnnsExtension],
--		[cnnbPrimary],
--		[cnnbVisible],
--		[cnnnAddressID],
--		[cnnsLabelCaption],
--		[cnnnRecUserID],
--		[cnndDtCreated],
--		[cnnnModifyUserID],
--		[cnndDtModified],
--		[cnnnLevelNo],
--		[caseno],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select
--		c.cinnContactCtg				as cnnncontactctgid,
--		c.cinnContactID					as cnnncontactid,
--		(
--		 select
--			 ctynContactNoTypeID
--		 from sma_MST_ContactNoType
--		 where ctysDscrptn = 'Home Primary Phone'
--			 and ctynContactCategoryID = 1
--		)								as cnnnphonetypeid   -- Home Phone 
--		,
--		dbo.FormatPhone(p.phone_number) as cnnscontactnumber,
--		null							as cnnsextension,
--		1								as cnnbprimary,
--		null							as cnnbvisible,
--		a.addnAddressID					as cnnnaddressid,
--		'Home Phone'					as cnnslabelcaption,
--		368								as cnnnrecuserid,
--		GETDATE()						as cnnddtcreated,
--		368								as cnnnmodifyuserid,
--		GETDATE()						as cnnddtmodified,
--		null							as cnnnlevelno,
--		null							as caseno,
--		null							as [saga],
--		null							as [source_id],
--		'highrise'						as [source_db],
--		'phone'							as [source_ref]
--	from Baldante_Highrise..phone p
--	join [sma_MST_IndvContacts] c
--		on c.saga = p.contact_id
--	join [sma_MST_Address] a
--		on a.addnContactID = c.cinnContactID
--			and a.addnContactCtgID = c.cinnContactCtg
--			and a.addbPrimary = 1
--	where
--		ISNULL(p.phone_number, '') <> ''



		
--/* ------------------------------------------------------------------------------
--Email Address
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
--	)
--	select
--		c.cinnContactCtg as cewncontactctgid,
--		c.cinnContactID	 as cewncontactid,
--		'E'				 as cewsemailwebsiteflag,
--		e.email_address	 as cewsemailwebsite,
--		null			 as cewbdefault,
--		368				 as cewnrecuserid,
--		GETDATE()		 as cewddtcreated,
--		368				 as cewnmodifyuserid,
--		GETDATE()		 as cewddtmodified,
--		null			 as cewnlevelno,
--		1				 as saga, -- indicate email
--		null			 as [source_id],
--		'needles'		 as [source_db],
--		'names.email'	 as [source_ref]
--	from Baldante_Highrise..email_address e
--	join [sma_MST_IndvContacts] c
--		on c.saga = e.contact_id
--	where
--		ISNULL(e.email_address, '') <> ''