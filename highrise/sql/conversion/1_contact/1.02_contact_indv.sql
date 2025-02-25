/* ###################################################################################
description: Create individual contacts
steps:
	- insert [sma_MST_IndvContacts] from [needles].[names]
usage_instructions:
	-
dependencies:
	- 
notes:
	- 
saga:
	- saga
source:
	- [names]
target:
	- [sma_MST_IndvContacts]
######################################################################################
*/

use BaldanteHighriseSA
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
		--  ,CASE
		--	WHEN Dates LIKE '%birthday%'
		--		THEN CASE
		--				WHEN TRY_CAST(SUBSTRING(Dates, CHARINDEX(': ', Dates) + 2, LEN(Dates)) AS DATE)
		--					BETWEEN '1900-01-01' AND '2079-12-31'
		--					THEN TRY_CAST(SUBSTRING(Dates, CHARINDEX(': ', Dates) + 2, LEN(Dates)) AS DATE)
		--				ELSE GETDATE()
		--			END
		--	ELSE NULL
		--END												AS [cindBirthDate]
		--  ,CASE
		--	WHEN Dates LIKE '%Date of death:%'
		--		THEN CASE
		--				WHEN TRY_CAST(SUBSTRING(Dates, CHARINDEX('Date of death: ', Dates) + 15, LEN(Dates)) AS DATE)
		--					BETWEEN '1900-01-01' AND '2079-12-31'
		--					THEN TRY_CAST(SUBSTRING(Dates, CHARINDEX('Date of death: ', Dates) + 15, LEN(Dates)) AS DATE)
		--				ELSE NULL
		--			END
		--	ELSE NULL
		--END												AS [cindDateOfDeath]
		null								 as [cinnGender],
		--case
		--	when N.[sex]='M' then 1
		--	when N.[sex]='F' then 2
		--		else 0
		--	end										as [cinnGender],
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
		c.ID								 as [saga],
		'highrise'							 as [source_db],
		'contacts'							 as [source_ref]
	from Baldante..contacts c

--WHERE c.[Company or Person] = 'Person'
go

alter table [sma_MST_IndvContacts] enable trigger all
go

--SELECT COLUMN_NAME, DATA_TYPE
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'sma_MST_IndvContacts' AND DATA_TYPE = 'tinyint';
