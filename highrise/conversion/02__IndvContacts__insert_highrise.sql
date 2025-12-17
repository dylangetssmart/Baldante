use Baldante_Consolidated
go


/* ------------------------------------------------------------------------------
Insert [sma_MST_IndvContacts] from Highrise that don't exist (match on name)
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_MST_IndvContacts'
alter table [sma_MST_IndvContacts] alter column saga INT
go

alter table [sma_MST_IndvContacts] disable trigger all
go

insert into [sma_MST_IndvContacts]
	(
		[cinsPrefix],
		[cinsSuffix],
		[cinsFirstName],
		[cinsMiddleName],
		[cinsLastName],
		[cinsHomePhone],
		[cinsWorkPhone],
		[cinsSSNNo],
		[cindBirthDate],
		[cindDateOfDeath],
		[cinnGender],
		[cinsMobile],
		[cinsComments],
		[cinnContactCtg],
		[cinnContactTypeID],
		[cinnContactSubCtgID],
		[cinnRecUserID],
		[cindDtCreated],
		[cinbStatus],
		[cinbPreventMailing],
		[cinsNickName],
		[cinsPrimaryLanguage],
		[cinsOtherLanguage],
		[cinnRace],
		[saga],
		[source_db],
		[source_ref]
	)
	select
		null								 as [cinsPrefix],
		null								 as [cinsSuffix],
		LEFT(dbo.get_firstword(c.name), 100) as [cinsFirstName],
		null								 as [cinsMiddleName],
		LEFT(dbo.get_lastword(c.name), 100)	 as [cinsLastName],
		null								 as [cinsHomePhone],
		null								 as [cinsWorkPhone],
		null								 as [cinsSSNNo],
		null								 as [cindBirthDate],
		null								 as [cindDateOfDeath],
		3									 as [cinnGender],  -- unknown
		null								 as [cinsMobile],
		--,LEFT(c.[Phone number - Mobile], 20)				AS [cinsMobile]
		null								 as [cinsComments],
		--,REPLACE(c.Background, '|', CHAR(13) + CHAR(10)) AS [cinsComments]
		1									 as [cinnContactCtg],
		(
		 select
			 octnOrigContactTypeID
		 from [sma_MST_OriginalContactTypes]
		 where octsDscrptn = 'General'
			 and octnContactCtgID = 1
		)									 as [cinnContactTypeID],
		(
		 select
			 cscnContactSubCtgID
		 from [sma_MST_ContactSubCategory]
		 where cscsDscrptn = 'Adult'
		)									 as cinnContactSubCtgID,
		368									 as cinnRecUserID,
		GETDATE()							 as cindDtCreated,
		1									 as [cinbStatus],			-- Hardcode Status as ACTIVE 
		0									 as [cinbPreventMailing],
		null								 as [cinsNickName],
		null								 as [cinsPrimaryLanguage],
		null								 as [cinsOtherLanguage],
		null								 as [cinnrace],
		c.id								 as [saga],
		'highrise'							 as [source_db],
		'contacts'							 as [source_ref]
	--select c.*, ioci.*
	from Baldante_Highrise..contacts c
	left join IndvOrgContacts_Indexed ioci
		on c.name = ioci.Name
			and ioci.source_db = 'highrise'
			and ioci.source_ref = 'contacts'
	where
		ioci.TableIndex is null
go

alter table [sma_MST_IndvContacts] enable trigger all
go


/* ------------------------------------------------------------------------------
Insert [sma_MST_Address] for highrise contacts
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_Address';
alter table [sma_MST_Address] disable trigger all
go

-- Home Address
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
		indv.cinnContactID	  as addncontactctgid,
		indv.cinnContactCtg	  as addncontactid,
		t.addnAddTypeID		  as addnaddresstypeid,
		t.addsDscrptn		  as addsaddresstype,
		t.addsCode			  as addsaddtypecode,
		LEFT(a.[address], 75) as addsaddress1,
		null				  as addsaddress2,
		null				  as addsaddress3,
		null				  as addsstatecode,
		null				  as addscity,
		null				  as addnzipid,
		null				  as addszip,
		null				  as addscounty,
		null				  as addscountry,
		null				  as addbisresidence,
		1					  as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		null				  as [addscomments],
		null,
		null,
		368					  as addnrecuserid,
		GETDATE()			  as addddtcreated,
		368					  as addnmodifyuserid,
		GETDATE()			  as addddtmodified,
		null,
		null,
		null,
		null,
		a.id				  as saga,
		null				  as source_id,
		'highrise'			  as source_db,
		'address'			  as source_ref
	from Baldante_Highrise..address a
	join Baldante_Highrise..contacts c
		on c.id = a.contact_id
	join sma_MST_IndvContacts indv
		on c.id = indv.saga
			and indv.[source_db] = 'highrise'
			and indv.[source_ref] = 'contacts'
	join [sma_MST_AddressTypes] as t
		on t.addnContactCategoryID = indv.cinnContactCtg
			and t.addsCode = 'HM'
go

-- add 'Other' address to any contacts with no addresses
insert into [sma_MST_Address]
	(
		addnContactCtgID,
		addnContactID,
		addnAddressTypeID,
		addsAddressType,
		addsAddTypeCode,
		addbPrimary,
		addnRecUserID,
		adddDtCreated
	)
	select
		i.cinnContactCtg as addncontactctgid,
		i.cinnContactID	 as addncontactid,
		(
		 select
			 addnAddTypeID
		 from [sma_MST_AddressTypes]
		 where addsDscrptn = 'Other'
			 and addnContactCategoryID = i.cinnContactCtg
		)				 as addnaddresstypeid,
		'Other'			 as addsaddresstype,
		'OTH'			 as addsaddtypecode,
		1				 as addbprimary,
		368				 as addnrecuserid,
		GETDATE()		 as addddtcreated
	from [sma_MST_IndvContacts] i
	left join [sma_MST_Address] a
		on a.addncontactid = i.cinnContactID
			and a.addncontactctgid = i.cinnContactCtg
	where
		a.addnAddressID is null
go


-- update primary address
-- should not be relevant (highrise contacts either get Home or Other address)

--update [sma_MST_Address]
--set addbPrimary = 1
--from (
-- select
--	 i.cinnContactID															   as cid,
--	 a.addnAddressID															   as aid,
--	 ROW_NUMBER() over (partition by i.cinnContactID order by a.addnAddressID asc) as rownumber
-- from [sma_MST_Indvcontacts] i
-- join [sma_MST_Address] a
--	 on a.addnContactID = i.cinnContactID
--	 and a.addnContactCtgID = i.cinnContactCtg
--	 and a.addbPrimary <> 1
-- where i.cinnContactID not in (
--	  select
--		  i.cinnContactID
--	  from [sma_MST_Indvcontacts] i
--	  join [sma_MST_Address] a
--		  on a.addnContactID = i.cinnContactID
--		  and a.addnContactCtgID = i.cinnContactCtg
--		  and a.addbPrimary = 1
--	 )
--) a
--where a.rownumber = 1
--and a.aid = addnAddressID


alter table [sma_MST_Address] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert [sma_MST_ContactNumbers] for highrise contacts
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
		indv.cinnContactCtg						  as cnnncontactctgid,
		indv.cinnContactID						  as cnnncontactid,
		t.ctynContactNoTypeID					  as cnnnphonetypeid,
		LEFT(dbo.FormatPhone(p.phone_number), 30) as cnnscontactnumber,
		null									  as cnnsextension,
		1										  as cnnbprimary,
		null									  as cnnbvisible,
		a.addnAddressID							  as cnnnaddressid,
		'Home Phone'							  as cnnslabelcaption,
		368										  as cnnnrecuserid,
		GETDATE()								  as cnnddtcreated,
		368										  as cnnnmodifyuserid,
		GETDATE()								  as cnnddtmodified,
		null									  as cnnnlevelno,
		null									  as caseno,
		p.id									  as saga,
		null									  as source_id,
		'highrise'								  as source_db,
		'phone'									  as source_ref
	from Baldante_Highrise..phone as p
	join [sma_MST_IndvContacts] as indv
		on indv.saga = p.contact_id
			and indv.[source_db] = 'highrise'
			and indv.[source_ref] = 'contacts'
	join [sma_MST_Address] as a
		on a.addnContactID = indv.cinnContactID
			and a.addnContactCtgID = indv.cinnContactCtg
			and a.addbPrimary = 1
	join sma_MST_ContactNoType as t
		on t.ctysDscrptn = 'Home Primary Phone'
			and t.ctynContactCategoryID = 1
	where
		ISNULL(p.phone_number, '') <> '';
go


-- Update primary contact numbers
--update [sma_MST_ContactNumbers]
--set cnnbPrimary = 0
--from (
-- select
--	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as rownumber,
--	 cnnnContactNumberID														 as contactnumberid
-- from [sma_MST_ContactNumbers]
-- where cnnnContactCtgID = (
--	  select
--		  ctgnCategoryID
--	  from [dbo].[sma_MST_ContactCtg]
--	  where ctgsDesc = 'Individual'
--	 )
--) a
--where a.rownumber <> 1
--and a.contactnumberid = cnnnContactNumberID
--go


alter table [sma_MST_ContactNumbers] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert [sma_MST_EmailWebsite] for highrise contacts
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_EmailWebsite';
alter table [sma_MST_EmailWebsite] disable trigger all;
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
		indv.cinnContactCtg as cewncontactctgid,
		indv.cinnContactID  as cewncontactid,
		'E'					as cewsemailwebsiteflag,
		e.email_address		as cewsemailwebsite,
		null				as cewbdefault,
		368					as cewnrecuserid,
		GETDATE()			as cewddtcreated,
		368					as cewnmodifyuserid,
		GETDATE()			as cewddtmodified,
		null				as cewnlevelno,
		e.id				as saga,
		null				as source_id,
		'highrise'			as source_db,
		'email_address'		as source_ref
	from Baldante_Highrise..email_address as e
	join [sma_MST_IndvContacts] as indv
		on indv.saga = e.contact_id
			and indv.[source_db] = 'highrise'
			and indv.[source_ref] = 'contacts'
	where
		ISNULL(e.email_address, '') <> '';
go

alter table [sma_MST_EmailWebsite] enable trigger all
go