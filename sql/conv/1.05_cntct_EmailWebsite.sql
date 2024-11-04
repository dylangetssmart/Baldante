USE BaldanteSA
GO
/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
ALTER TABLE [sma_MST_EmailWebsite] DISABLE TRIGGER ALL
GO
---------------------------------------------------------------------
----- (1/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR INDIVIDUAL -
---------------------------------------------------------------------

-- Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	i.cinnContactCtg		as cewnContactCtgID
	,i.cinnContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,left(c.[Email address - Home],255)				as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,1						as saga -- indicate email
from Baldante..contacts_csv c
JOIN [sma_MST_IndvContacts] i
	on i.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Home],'') <> ''


-- Work Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	i.cinnContactCtg		as cewnContactCtgID
	,i.cinnContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,c.[Email address - Work]			as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,2						as saga -- indicate email_work
from Baldante..contacts_csv c
JOIN [sma_MST_IndvContacts] i
	on i.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Work],'') <> ''


-- Other Email
 INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
 SELECT 
	i.cinnContactCtg		as cewnContactCtgID
	,i.cinnContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,c.[Email address - Other]			as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,3						as saga -- indicate other_email
from Baldante..contacts_csv c
JOIN [sma_MST_IndvContacts] i
	on i.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Other],'') <> ''


-- Website
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	i.cinnContactCtg		as cewnContactCtgID
	,i.cinnContactID		as cewnContactID
	,'W'					as cewsEmailWebsiteFlag
	,c.[Web address - Personal]				as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,4						as saga -- indicate website
from Baldante..contacts_csv c
JOIN [sma_MST_IndvContacts] i
	on i.saga = c.[Highrise ID]
WHERE isnull(c.[Web address - Personal],'') <> ''

--------------------------------------------------------------------
----- (2/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR ORGANIZATION ------
--------------------------------------------------------------------

-- Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	o.connContactCtg		as cewnContactCtgID
	,o.connContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,c.[Email address - Home]				as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,1						as saga -- indicate email
from Baldante..contacts_csv c
JOIN [sma_MST_OrgContacts] o
	on o.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Home],'') <> ''

-- Work Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	o.connContactCtg		as cewnContactCtgID
	,o.connContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,c.[Email address - Work]			as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,2						as saga -- indicate email_work
from Baldante..contacts_csv c
JOIN [sma_MST_OrgContacts] o
	on o.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Work],'') <> ''

-- Other Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	o.connContactCtg		as cewnContactCtgID
	,o.connContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,c.[Email address - Other]		as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,3						as saga -- indicate other_email
from Baldante..contacts_csv c
JOIN [sma_MST_OrgContacts] o
	on o.saga = c.[Highrise ID]
WHERE isnull(c.[Email address - Other],'') <> ''

-- Website
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	o.connContactCtg		as cewnContactCtgID
	,o.connContactID		as cewnContactID
	,'W'					as cewsEmailWebsiteFlag
	,c.[Web address - Work]			as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,4						as saga -- indicate website
from Baldante..contacts_csv c
JOIN [sma_MST_OrgContacts] o
	on o.saga = c.[Highrise ID]
WHERE isnull(c.[Web address - Work],'') <> ''

 ---
 ALTER TABLE [sma_MST_EmailWebsite] ENABLE TRIGGER ALL
 GO
 ---


 /*
---- (3/3 set default)

update [sma_MST_EmailWebsite] set cewbDefault=0  
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewsEmailWebsiteFlag='W'

declare @cewnContactID int;
declare @email_Count int;
declare @email_work_Count int;
declare @other_email_Count int;

declare @email_cewnEmlWSID int;
declare @email_work_cewnEmlWSID int;
declare @other_email_cewnEmlWSID int;
 
DECLARE EmailWebsite_cursor CURSOR FOR 
select distinct cewnContactID from [sma_MST_EmailWebsite]

OPEN EmailWebsite_cursor 

FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

WHILE @@FETCH_STATUS = 0
BEGIN

select @email_Count=count(*),@email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=1 
select @email_work_Count=count(*),@email_work_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=2
select @other_email_Count=count(*),@other_email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=3

if ( @email_Count != 0 )
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count != 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_work_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count = 0 and @other_email_Count <> 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@other_email_cewnEmlWSID
end


FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

END 

CLOSE EmailWebsite_cursor;
DEALLOCATE EmailWebsite_cursor;

*/


